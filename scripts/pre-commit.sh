#!/usr/bin/env bash
# ===============================================================================
#  File:         pre-commit.sh
#  File Type:    Bash script
#
#  Purpose:      Master pre-commit check/report automation script for PumpHouseBoss
#  Version:      0.8.0d
#  Date:         2025-07-31
#  Author:       Roland Tembo Hendel <rhendel@nexuslogic.com>
#
#  Description:
#    - Runs all pre-commit check/report scripts for the PumpHouseBoss project.
#    - Executes all scripts listed in the PCO_SCRIPTS array (see below).
#    - Populates arrays of all YAML, Bash, and Makefile files in the project (excluding .gitignored files).
#    - This framework and all included scripts are strictly non-destructive: they only check and report, and do NOT update or modify any files.
#
#  Features:
#    - Interactive or silent (QUIET) mode
#    - Explicit script selection via command-line arguments
#    - Skips and warns for any missing or non-executable scripts in PCO_SCRIPTS
#    - Populates YAML_FILES, SCRIPT_FILES, and MAKEFILES arrays for use by op scripts
#    - Colorful output and logging (via smartprint and color helpers)
#    - Progress spinner for long-running operations
#    - Robust error handling and exit code propagation
#    - Modular, maintainable, and DRY: shared helpers sourced from .common.sh
#    - All output is robustly logged to ${LOGFILE}
#
#  Usage:
#    ./pre-commit.sh [options] [script1 [script2 ...]]
#      Options:
#        -h, --help             Show this help message and exit
#        -v, --version          Show script version and exit
#        -q, --quiet            Run in silent mode (no prompts)
#        --logfile <file>       Set custom log file (default: logs/pre-commit.log)
#        script1 [script2 ...]  Run only the specified script(s) (by name or path)
#      Example:
#        ./pre-commit.sh -q
#        ./pre-commit.sh _pco_myScript.sh
#        ./pre-commit.sh _pco_test_pass.sh _pco_test_warn.sh
#        ./pre-commit.sh --logfile mylog.txt _pco_test_pass.sh
#
#  NOTE:
#    - This script and all pre-commit operation scripts it runs are for checking and reporting only.
#    - No files are ever updated or modified by this framework.
#    - All color output is robustly handled and can be disabled via COLOR_SUPPORT=0.
#    - Spinner is used for progress indication and hides the cursor during operation.
#    - All shared logic (color, spinner, output helpers) is sourced from .common.sh for maintainability.
#
#  License:      GNU General Public License v3.0
#                SPDX-License-Identifier: GPL-3.0-or-later
#  Copyright:    (c) 2025 Roland Tembo Hendel
#                This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License.
# ===============================================================================

set -uo pipefail


# -------------------------------------------------------------------------------
#  Project root and script directory setup
# -------------------------------------------------------------------------------
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_DIR="${PROJECT_ROOT}/scripts"

# Source shared helpers (color, spinner, output, file discovery)
if [ -f "${SCRIPT_DIR}/.common.sh" ]; then
    source "${SCRIPT_DIR}/.common.sh"
else
    echo "Error: .common.sh not found in ${SCRIPT_DIR}" >&2
    exit 1
fi

# -------------------------------------------------------------------------------
#  List of pre-commit operation scripts (must match actual filenames)
# -------------------------------------------------------------------------------
PCO_SCRIPTS=(
    "_pco_version_check.sh"   # Version string check/report
    "_pco_test_pass.sh"       # Example: always passes
    "_pco_test_warn.sh"       # Example: always warns
    "_pco_test_fail.sh"       # Example: always fails
)

# Prepend SCRIPT_DIR to each element in PCO_SCRIPTS (robust to spaces)
for i in "${!PCO_SCRIPTS[@]}"; do
    PCO_SCRIPTS[$i]="${SCRIPT_DIR}/${PCO_SCRIPTS[$i]}"
done

SCRIPTS_DIR="$(dirname \"$0\")"

# Default logfile location (can be overridden by --logfile)
LOGFILE="${PROJECT_ROOT}/logs/pre-commit.log"

# QUIET mode: 0=interactive, 1=silent (set by -q/--quiet or explicit script selection)
QUIET=0

# Results counters (updated by run_op)
COUNTER_PASS=0
COUNTER_FAIL=0
COUNTER_WARN=0
COUNTER_TOTAL=0


# -------------------------------------------------------------------------------
#  Main dispatch: parses arguments, runs selected scripts, handles banners/spinner
# -------------------------------------------------------------------------------
main() {

    # Collect CLAs, exit early if requested
    parse_command_line "$@"

    local overall_exit=0
    local scripts_to_run=()

    # Determine which scripts to run
    if [[ ${#EXPLICIT_SCRIPTS[@]} -gt 0 ]]; then
        if [[ -z "$QUIET_EXPLICITLY_SET" ]]; then
            QUIET=1
        fi
        scripts_to_run=("${EXPLICIT_SCRIPTS[@]}")
    else
        scripts_to_run=("${PCO_SCRIPTS[@]}")
    fi

    # Print start banner if running multiple scripts or default set
    if [[ ${#scripts_to_run[@]} -gt 1 || ${#EXPLICIT_SCRIPTS[@]} -eq 0 ]]; then
        print_start_banner
    fi

    # Run all selected scripts
    for script in "${scripts_to_run[@]}"; do
        run_op "$script"
        local rc=$?
        if (( rc > overall_exit )); then overall_exit=$rc; fi
    done

    # Print summary banner if more than one script was run or default set
    if [[ ${#scripts_to_run[@]} -gt 1 || ${#EXPLICIT_SCRIPTS[@]} -eq 0 ]]; then
        print_summary_banner
    fi

    exit $overall_exit
}

# Parse command line options
parse_command_line() {
    EXPLICIT_SCRIPTS=()
    QUIET_EXPLICITLY_SET=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            -q|--quiet)
                QUIET=1
                QUIET_EXPLICITLY_SET=1
                ;;
            --logfile)
                shift
                if [ $# -gt 0 ]; then
                    LOGFILE="$1"
                else
                    echo "Error: --logfile requires a filename argument" >&2
                    exit 1
                fi
                ;;
            *)
                # treat all other args as explicit scripts to run (relative or absolute)
                if [[ -f "$1" ]]; then
                    EXPLICIT_SCRIPTS+=("$1")
                elif [[ -f "$SCRIPT_DIR/$1" ]]; then
                    EXPLICIT_SCRIPTS+=("$SCRIPT_DIR/$1")
                else
                    echo "Warning: Script not found: $1" >&2
                fi
                ;;
        esac
        shift
    done
}

# Show help information and exit
show_help() {
    echo "Usage: $0 [options] [script1 [script2 ...]]"
    echo "  -h, --help             Show this help message and exit"
    echo "  -v, --version          Show script version and exit"
    echo "  -q, --quiet            Run in silent mode (no prompts)"
    echo "  --logfile <file>       Set custom log file (default: logs/pre-commit.log)"
    echo "  script1 [script2 ...]  Run only the specified script(s) (by name or path)"
    echo "Notes:"
    echo "  - If you specify one or more script names or paths as arguments, only those scripts are run (in order)."
    echo "  - Only scripts listed in the PCO_SCRIPTS array are run unless you specify scripts explicitly."
    echo "  - Any missing or non-executable scripts are skipped with a warning."
    echo "Examples:"
    echo "  $0 -h"
    echo "  $0 -q"
    echo "  $0 _pco_test_pass.sh"
    echo "  $0 _pco_test_pass.sh _pco_test_warn.sh"
    echo "  $0 --logfile mylog.txt _pco_test_pass.sh"
}

# Show version information and exit
show_version() {
    local version_file="${PROJECT_ROOT}/VERSION"
    local version="unknown"
    if [ -f "$version_file" ]; then
        read -r version < "$version_file"
    fi
    printf "%s\n" "$version"
}

# Run a pre-commit operation script, update statistics, and provide output
run_op() {
    local script="$1"
    local name TMP_OUTPUT PCO_DESCRIPTION prompt_cleared=0
    name="$(basename -- "$script")"
    TMP_OUTPUT=$(mktemp)

    # Shebang check: ensure script starts with #! and sh or bash
    if ! head -n1 -- "$script" | grep -qE '^#!.*(sh|bash)'; then
        printf "[SKIP] %s (missing or invalid shebang)\n" "$name"
        return 0
    fi

    # Extract PCO_DESCRIPTION from the script (robust to quotes and whitespace)
    PCO_DESCRIPTION=$(grep -E '^PCO_DESCRIPTION[[:space:]]*=' "$script" | head -n1 | sed -e 's/^PCO_DESCRIPTION[[:space:]]*=[[:space:]]*//;s/^"//;s/"$//;s/^\x27//;s/\x27$//')
    if [[ -z "$PCO_DESCRIPTION" ]]; then
        PCO_DESCRIPTION="$name"
    fi

    if [[ $QUIET -eq 0 ]]; then
        local prompt yn
        prompt="Run $name? [Y/n] "
        read -r -p "$prompt" yn
        case $yn in
            [Nn]*) printf "[SKIP] %s\n" "$name"; return 0;;
        esac
        # Move cursor up and clear the prompt+input line
        printf '\033[1A\r\033[2K'
        prompt_cleared=1
    fi

    # Print progress line with spinner (replaces [*])
    pco_spinner_start "Running: $PCO_DESCRIPTION"
    COLOR_SUPPORT=1 bash "$script" > "$TMP_OUTPUT" 2>&1
    local exit_code=$?
    pco_spinner_stop
    local RESULT_LINE
    if [[ $exit_code -eq 0 ]]; then
        RESULT_LINE="${PASS} $PCO_DESCRIPTION"
        ((COUNTER_PASS++))
    elif [[ $exit_code -eq 255 ]]; then
        RESULT_LINE="${WARN} $PCO_DESCRIPTION"
        ((COUNTER_WARN++))
    else
        RESULT_LINE="${FAIL} $PCO_DESCRIPTION"
        ((COUNTER_FAIL++))
    fi

    # Remove any trailing quote from PCO_DESCRIPTION (if present)
    local CLEAN_RESULT_LINE
    CLEAN_RESULT_LINE=$(printf "%s" "$RESULT_LINE" | sed 's/"$//')

    # Overwrite the progress line with the result, clear the rest of the line
    printf -- "\r%-80b\n" "$CLEAN_RESULT_LINE"

    # Strip color codes for logfile output
    local RESULT_LINE_PLAIN
    RESULT_LINE_PLAIN=$(printf "%s" "$CLEAN_RESULT_LINE" | sed -E 's/\\033\[[0-9;]*m//g')
    printf -- "%s\n" "$RESULT_LINE_PLAIN" >> "$LOGFILE"
    if [ -s "$TMP_OUTPUT" ]; then
        # Prefix each output line with a right arrow, but only if it doesn't already start with one
        while IFS= read -r line; do
            if [[ "$line" =~ ^[[:space:]]*→ ]]; then
                printf -- "%s\n" "$line"
                printf -- "%s\n" "$line" >> "$LOGFILE"
            else
                printf -- "→ %s\n" "$line"
                printf -- "→ %s\n" "$line" >> "$LOGFILE"
            fi
        done < "$TMP_OUTPUT"
    fi
    rm -f -- "$TMP_OUTPUT"
    ((COUNTER_TOTAL++))
    return $exit_code
}

# Print start banner to both stdout and logfile, and record start time
print_start_banner() {
    smartprint "${GREEN}" "${HORIZONTAL_DELIMETER}"
    smartprint "${GREEN}" "  Starting Pre-commit Operations:"
    smartprint "${GREEN}" "${HORIZONTAL_DELIMETER}"
}

# Print stop banner to both stdout and logfile, and record end time
print_summary_banner() {
    local banner_color
    local summary_message

    # define content and colors based on aggregate results
    if [ "$COUNTER_FAIL" -ne 0 ]; then
        banner_color="${RED}"
        summary_message="Some checks failed."
    elif [ "$COUNTER_WARN" -ne 0 ]; then
        banner_color="${YELLOW}"
        summary_message="Checks passed, but with warnings."
    else
        banner_color="${GREEN}"
        summary_message="All checks passed."
    fi

    # print summary banner
    smartprint "${banner_color}" "${HORIZONTAL_DELIMETER}"
    smartprint "${banner_color}" "  Pre-commit Operations Complete."
    smartprint "${banner_color}" "    TOTAL CHECKS    : ${COUNTER_TOTAL}"
    smartprint "${banner_color}" "  ${summary_message}"
    smartprint "${banner_color}" "      Checks PASSED : ${COUNTER_PASS}"
    smartprint "${banner_color}" "      Checks WARNED : ${COUNTER_WARN}"
    smartprint "${banner_color}" "      Checks FAILED : ${COUNTER_FAIL}"
    smartprint "${banner_color}" "${HORIZONTAL_DELIMETER}"
}

# Trap to ensure spinner is stopped and cursor restored on exit or interrupt
trap 'pco_spinner_stop' EXIT INT TERM

# Call main
main "$@"
