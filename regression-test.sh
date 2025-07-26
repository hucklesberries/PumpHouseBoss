#!/usr/bin/env bash
# ===============================================================================
#  File:         regression-test.sh
#  File Type:    bash script
#  Purpose:      Project regression test runner for ESPHome-based device management
#  Version:      0.7.0
#  Date:         2025-07-24
#  Author:       Roland Tembo Hendel <rhendel@nexuslogic.com>
#
#  Description:  Runs a suite of checks and utility targets for all project variants,
#                logging results and printing a summary. Designed to be called from
#                the Makefile or directly from the shell. All output is logged to
#                regression-test.log.
#
#  Features:     - Validates required files and YAML syntax
#                - Runs Makefile utility, build, docs, and clean targets per variant
#                - Colorized output in terminal, plain in logfile
#                - Progress dots for long-running tests (interactive only)
#                - Robust cleanup of background tasks on interruption
#                - Elapsed time and summary reporting
#  Usage:        ./regression-test.sh [logfile] [options]
#                   Options:
#                     -h, --help     Show this help message and exit
#                     -v, --version  Show script version and exit
#                     logfile        (Optional) Path to log file (default: regression-test.log)
#                   Example:
#                     ./regression-test.sh custom.log
#
#  Note:         Spawns a background task for progress indication when run
#                interactively. Background task is killed on exit or interruption (trap).
#
#  License:      GNU General Public License v3.0
#                SPDX-License-Identifier: GPL-3.0-or-later
#  Copyright:    (c) 2025 Roland Tembo Hendel
#                This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License.
# ===============================================================================

set -uo pipefail


# ------------------------------------------------------------------------------
#  Configuration
# ------------------------------------------------------------------------------


# List of targets to check (matches Makefile)
UTILITY_TARGETS="help version buildvars"
BUILD_TARGETS="build docs-esphome docs-mkdoc docs"
CLEAN_TARGETS="clean clean-cache clean-docs clobber distclean"
SRC_DIRECTORIES=(./ common)

# Dynamically find all .yaml files in SRC_DIRECTORIES
SRC_FILES=()
for dir in "${SRC_DIRECTORIES[@]}"; do
    while IFS= read -r -d $'\0' file; do
        SRC_FILES+=("$file")
    done < <(find "$dir" -maxdepth 1 -type f -name '*.yaml' -print0 2>/dev/null)
done
# Collect .yaml files recursively in variants/
if [ -d "variants" ]; then
    while IFS= read -r -d $'\0' file; do
        SRC_FILES+=("$file")
    done < <(find variants -type f -name '*.yaml' -print0 2>/dev/null)
fi

# Log file for all output (set in parse_command_line)
TEST_LOGFILE="regression-test.log"

# Key project files to check
SECRETS_FILE="./common/secrets.yaml"

# Detect if terminal supports color
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ $(tput colors) -ge 8 ]; then
    COLOR_SUPPORT=1
    GREEN="\033[0;32m"
    RED="\033[0;31m"
    YELLOW="\033[0;33m"
    NC="\033[0m"
else
    COLOR_SUPPORT=0
    GREEN=""
    RED=""
    YELLOW=""
    NC=""
fi

# Output tags
PASSED="${GREEN}[PASSED]${NC}"
WARN="${YELLOW}[-WARN-]${NC}"
FAIL="${RED}[-FAIL-]${NC}"


# Results counters
COUNTER_FAIL=0
COUNTER_TOTAL=0


# ------------------------------------------------------------------------------
#  Main dispatch
# ------------------------------------------------------------------------------
main() {
    parse_command_line "$@"
    print_start_banner
    test_required_files
    test_yaml_validation
    # Robust globbing for test variants
    local nullglob_was_set=0
    if shopt -q nullglob; then
        nullglob_was_set=1
    else
        shopt -s nullglob
    fi
    for VARIANT in config/*-test.mk; do
        test_utility_targets "${VARIANT}"
        test_build_targets "${VARIANT}"
        test_doc_targets "${VARIANT}"
        test_clean_targets "${VARIANT}"
    done
    # Restore nullglob to previous state
    if [ "$nullglob_was_set" -eq 0 ]; then
        shopt -u nullglob
    fi
    print_summary_banner
}


# ----------------------------------------------------------------------------
#  Command Line Operations
# ----------------------------------------------------------------------------

# Parse command line options
parse_command_line() {
    # Defaults
    local positional=()
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
            --)
                shift; break
                ;;
            -*)
                echo "Unknown option: $1" >&2
                show_help
                exit 1
                ;;
            *)
                positional+=("$1")
                ;;
        esac
        shift
    done
    # If first positional arg is present and not an option, treat as logfile
    if [ ${#positional[@]} -gt 0 ]; then
        TEST_LOGFILE="${positional[0]}"
    fi
}

# Show help information and exit
show_help() {
    echo "Usage: $0 [options] [logfile]"
    echo "  -h, --help     Show this help message and exit"
    echo "  -v, --version  Show script version and exit"
    echo "  logfile        (Optional) Path to log file (default: regression-test.log)"
    echo "Examples:"
    echo "  $0 -h"
    echo "  $0 custom.log"
}

# Show version information and exit
show_version() {
    local version_file="VERSION"
    if [ -f "$version_file" ]; then
        version=$(cat "$version_file" | head -n1)
    else
        version="unknown"
    fi
    echo "v$version"
}


# ------------------------------------------------------------------------------
#  Regression Test Logic
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
#  run_test: Run a shell command, log output, and print summary line
#   $1: Command to run
#   $2: Description for summary
#   $3: Name of COUNTER_FAIL variable (by reference)
#   $4: Name of COUNTER_TOTAL variable (by reference)
run_test() {
    local CMD="$1"
    local DESC="$2"
    local -n LOCAL_FAIL=$3
    local -n LOCAL_TOTAL=$4
    local TMP_OUTPUT
    TMP_OUTPUT=$(mktemp)


    # Only show dot progress if running interactively
    if [ -t 1 ]; then
        # Print running message (no newline)
        printf "Running %s ..." "${DESC}"
        (
            while true; do
                sleep 3
                printf "."
            done
        ) &
        PROGRESS_UPDATE_PID=$!
    fi

    # Run the test command
    if eval "${CMD}" >> "${TMP_OUTPUT}" 2>&1; then
        if grep -Eiq '(warn|error|fail)' "${TMP_OUTPUT}"; then
            local RESULT_LINE="${WARN} ${DESC}"
        else
            local RESULT_LINE="${PASSED}   ${DESC}"
        fi
    else
        local RESULT_LINE="${FAIL} ${DESC}"
        ((LOCAL_FAIL++))
    fi

    # Stop the dot printer if running
    if [ -n "${PROGRESS_UPDATE_PID:-}" ]; then
        # clean-up
        kill "${PROGRESS_UPDATE_PID}" 2>/dev/null || true
        wait "${PROGRESS_UPDATE_PID}" 2>/dev/null || true
        PROGRESS_UPDATE_PID=""

        # Overwrite the progress line
        local COLS=$(tput cols 2>/dev/null || echo 80)
        printf "\r%*s\r" "${COLS}" ""
    fi

    # Overwrite the line with the result (stdout only)
    echo -e "${RESULT_LINE}"

    # Log the result (no color)
    echo "${RESULT_LINE}" >> "${TEST_LOGFILE}"
    cat "${TMP_OUTPUT}" >> "${TEST_LOGFILE}"
    rm -f "${TMP_OUTPUT}"
    ((LOCAL_TOTAL++))
}


# ----------------------------------------------------------------------------
#  Start and Summary banners
# ----------------------------------------------------------------------------

# Print start banner to both stdout and logfile, and record start time
BANNER="========================================================================================"
print_start_banner() {
    START_TIME=$(date +%s)
    START_TIME_HUMAN=$(date)

    fancy_echo "${GREEN}" "$BANNER"
    fancy_echo "${GREEN}" "  Starting Regression Testing:"
    fancy_echo "${GREEN}" "    Start Time: ${START_TIME_HUMAN}"
    fancy_echo "${GREEN}" "$BANNER"
}

# Print summary banner to both stdout and logfile, and show elapsed time
print_summary_banner() {
    END_TIME=$(date +%s)
    END_TIME_HUMAN=$(date)
    ELAPSED=$((END_TIME-START_TIME))
    ELAPSED_MIN=$((ELAPSED/60))
    ELAPSED_SEC=$((ELAPSED%60))
    ELAPSED_FMT="${ELAPSED_MIN}m, ${ELAPSED_SEC}s"

    if [ "$COUNTER_FAIL" -eq 0 ]; then
        fancy_echo "${GREEN}" "$BANNER"
        fancy_echo "${GREEN}" "  Congratulations! All tests passed: (${COUNTER_TOTAL}/${COUNTER_TOTAL})"
        fancy_echo "${GREEN}" "    End Time    :  ${END_TIME_HUMAN}"
        fancy_echo "${GREEN}" "    Elapsed Time:  ${ELAPSED_FMT}"
        fancy_echo "${GREEN}" "$BANNER"
    else
        fancy_echo "${RED}" "$BANNER"
        fancy_echo "${RED}" "  Oh Oh! Regression tests failed: (${COUNTER_FAIL}/${COUNTER_TOTAL}), see ${TEST_LOGFILE} for results."
        fancy_echo "${RED}" "    End Time    :  ${END_TIME_HUMAN}"
        fancy_echo "${RED}" "    Elapsed Time:  ${ELAPSED_FMT}"
        fancy_echo "${RED}" "$BANNER"
    fi
}


# ------------------------------------------------------------------------------
#  Global Test Counters (initialized in main)
# ------------------------------------------------------------------------------

# Test: required files
test_required_files() {
    run_test '[ -f VERSION ]' "VERSION file exists" COUNTER_FAIL COUNTER_TOTAL
    run_test "[ -f \"${SECRETS_FILE}\" ]" "SECRETS_FILE exists" COUNTER_FAIL COUNTER_TOTAL
}

# Test: YAML validation
test_yaml_validation() {
    if command -v yamllint >/dev/null 2>&1; then
        for YF in "${SRC_FILES[@]}"; do
            run_test "yamllint ${YF}" "YAML validation: ${YF} (yamllint)" COUNTER_FAIL COUNTER_TOTAL
        done
    elif command -v python >/dev/null 2>&1; then
        for YF in "${SRC_FILES[@]}"; do
            run_test "python -c 'import sys, yaml; yaml.safe_load(open(\"${YF}\"))'" "YAML validation: ${YF} (python/yaml)" COUNTER_FAIL COUNTER_TOTAL
        done
    else
        echo -e "${YELLOW}[WARN]${NC} YAML validation skipped: no yamllint or python found" | tee -a "${TEST_LOGFILE}"
    fi
}

# Test: utility targets
test_utility_targets() {
    for T in ${UTILITY_TARGETS}; do
        run_test "make ${T} CONFIG=\"${1}\"" "Variant $(basename \"${1}\") - make ${T}" COUNTER_FAIL COUNTER_TOTAL
    done
}

# Test: build with each test.mk in config/
test_build_targets() {
run_test "make build CONFIG=\"${1}\"" "Variant $(basename \"${1}\") - make build" COUNTER_FAIL COUNTER_TOTAL
}

# Test: docs targets
test_doc_targets() {
run_test "make docs CONFIG=\"${1}\"" "Variant $(basename \"${1}\") - make docs" COUNTER_FAIL COUNTER_TOTAL
}

# Test: clean targets
test_clean_targets() {
    for T in ${CLEAN_TARGETS}; do
        run_test "make ${T} CONFIG=\"${1}\"" "Variant $(basename \"${1}\") - make ${T}" COUNTER_FAIL COUNTER_TOTAL
    done
}


# ----------------------------------------------------------------------------
#  Utility Functions
# ----------------------------------------------------------------------------

# Print a line in color to stdout and plain to logfile
fancy_echo() {
    if [ "$COLOR_SUPPORT" -eq 1 ]; then
        echo -e "$1$2${NC}"
    else
        echo "$2"
    fi
    echo "$2" >> "$TEST_LOGFILE"
}


# ----------------------------------------------------------------------------
#  Main invocation
# ----------------------------------------------------------------------------
# Track background dot printer PID globally
PROGRESS_UPDATE_PID=""

# Cleanup function to kill background dot printer on exit or interrupt
cleanup() {
    if [ -n "${PROGRESS_UPDATE_PID:-}" ]; then
        kill "${PROGRESS_UPDATE_PID}" 2>/dev/null || true
        wait "${PROGRESS_UPDATE_PID}" 2>/dev/null || true
        PROGRESS_UPDATE_PID=""
    fi
}

# Trap INT (CTRL-C) and TERM to cleanup (not EXIT, to avoid premature exit under set -e)
trap cleanup INT TERM

# Call main
main "$@"
