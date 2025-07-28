#!/usr/bin/env bash
# ===============================================================================
#  File:         regression-test.sh
#  File Type:    bash script
#  Purpose:      Project regression test runner for ESPHome-based device management
#  Version:      0.7.1
#  Date:         2025-07-24
#  Author:       Roland Tembo Hendel <rhendel@nexuslogic.com>
#
#  Description:  Runs a suite of checks and utility targets for all project variants,
#                echoing results and a summary report. Designed to be called from
#                the Makefile or directly from the shell.
#
#  Features:     - Validates required files and YAML syntax
#                - Runs Makefile utility, build, docs, and clean targets per variant
#                - Colorized output in terminal, plain in logfile
#                - Progress dots for long-running tests (interactive only)
#                - Robust cleanup of background tasks on interruption
#                - Elapsed time and summary reporting
#
#  Usage:        ./regression-test.sh [logfile] [options]
#                   Options:
#                     -h, --help     Show this help message and exit
#                     -v, --version  Show script version and exit
#                     logfile        (Optional) Path to log file
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

# include common definitions, macros, and functions
source "$(dirname "$0")/.common.sh"


# ------------------------------------------------------------------------------
#  Configuration
# ------------------------------------------------------------------------------

# List of targets to check (matches Makefile)
UTILITY_TARGETS="help version buildvars"
BUILD_TARGETS="build"
DOC_TARGETS="docs-esphome docs-mkdoc docs"
CLEAN_TARGETS="clean clean-cache clean-docs"

# Find all test config files under config/
TEST_CONFIGS=()
while IFS= read -r -d $'\0' file; do
    TEST_CONFIGS+=("$file")
done < <(find "${PROJECT_ROOT}/config" -type f -name '*-test.mk' -print0 2>/dev/null)

# Dynamically find all YAML files in PROJECT_ROOT
SRC_FILES=()
while IFS= read -r -d $'\0' file; do
    SRC_FILES+=("$file")
done < <(find "$PROJECT_ROOT" -type f -name '*.yaml' -print0 2>/dev/null)

# Key project files to check
SECRETS_FILE="${PROJECT_ROOT}/common/secrets.yaml"

# Log file for all output (set in parse_command_line)
LOGFILE="${PROJECT_ROOT}/logs/regression-test.log"

# Output tags
PASSED="${GREEN}[PASSED]${NC}"
WARN="${YELLOW}[-WARN-]${NC}"
FAIL="${RED}[-FAIL-]${NC}"

# Results counters
COUNTER_PASS=0
COUNTER_FAIL=0
COUNTER_WARN=0
COUNTER_TOTAL=0


# ------------------------------------------------------------------------------
#  Main dispatch
# ------------------------------------------------------------------------------

main() {

    # scan for invocation options
    parse_command_line "$@"

    # prepare for logging
    mkdir -p "${PROJECT_ROOT}/logs"
    : > "${LOGFILE}"

    # fancy output to get us started
    print_start_banner

    # test for presence of mandatory files
    test_required_files

    # validate all source files
    test_yaml_validation

    # Robust globbing for test variants
    local nullglob_was_set=0
    if shopt -q nullglob; then
        nullglob_was_set=1
    else
        shopt -s nullglob
    fi

    # test make targets across test variants
    for VARIANT in "${TEST_CONFIGS[@]}"; do
        test_utility_targets "${VARIANT}"
        test_build_targets "${VARIANT}"
        test_doc_targets "${VARIANT}"
        test_clean_targets "${VARIANT}"
    done

    # Restore nullglob to previous state
    if [ "$nullglob_was_set" -eq 0 ]; then
        shopt -u nullglob
    fi

    # issue test report
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
        LOGFILE="${positional[0]}"
    fi
}

# Show help information and exit
show_help() {
    echo "Usage: $0 [options] [logfile]"
    echo "  -h, --help     Show this help message and exit"
    echo "  -v, --version  Show script version and exit"
    echo "  logfile        (Optional) Path to log file (default: ${0%.*}.log)"
    echo "Examples:"
    echo "  $0 -h"
    echo "  $0 custom.log"
}

# Show version information and exit
show_version() {
    local version_file="VERSION"
    if [ -f "$version_file" ]; then
        version=$(head -n1 "$version_file")
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
#   $3: Name of COUNTER_PASS variable (by reference)
#   $4: Name of COUNTER_WARN variable (by reference)
#   $5: Name of COUNTER_FAIL variable (by reference)
#   $6: Name of COUNTER_TOTAL variable (by reference)
run_test() {
    local CMD="$1"
    local DESC="$2"
    local -n LOCAL_PASS=$3
    local -n LOCAL_WARN=$4
    local -n LOCAL_FAIL=$5
    local -n LOCAL_TOTAL=$6
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
        if grep -Eiq 'fail|error' "${TMP_OUTPUT}"; then
            local RESULT_LINE="${FAIL} ${DESC}"
            ((LOCAL_FAIL++))
        elif grep -Eiq 'warn' "${TMP_OUTPUT}"; then
            local RESULT_LINE="${WARN} ${DESC}"
            ((COUNTER_WARN++))
        else
            local RESULT_LINE="${PASSED}   ${DESC}"
            ((COUNTER_PASS++))
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
    echo "${RESULT_LINE}" >> "${LOGFILE}"
    cat "${TMP_OUTPUT}" >> "${LOGFILE}"
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

    # set banner defaults
    BANNER_COLOR=${GREEN}
    SUMMARY_MSG="Congratulations! All tests passed."

    # update banner
    if [ "$COUNTER_FAIL" -ne 0 ]; then
        # Red: errors present
        BANNER_COLOR=${RED}
        SUMMARY_MSG="Oh Oh! Regression tests failed."
    elif [ "$COUNTER_WARN" -ne 0 ]; then
        # Yellow: warnings but no errors
        BANNER_COLOR=${YELLOW}
        SUMMARY_MSG="All tests passed, but with warnings."
    fi

    # echo banner
    fancy_echo "${BANNER_COLOR}" "${BANNER}"
    fancy_echo "${BANNER_COLOR}" "  ${SUMMARY_MSG}"
    fancy_echo "${BANNER_COLOR}" "    TOTAL TESTS    : ${COUNTER_TOTAL}"
    fancy_echo "${BANNER_COLOR}" "      Tests PASSED : ${COUNTER_PASS}"
    fancy_echo "${BANNER_COLOR}" "      Tests WARNED : ${COUNTER_WARN}"
    fancy_echo "${BANNER_COLOR}" "      Tests FAILED : ${COUNTER_FAIL}"
    fancy_echo "${BANNER_COLOR}" "    End Time       : ${END_TIME_HUMAN}"
    fancy_echo "${BANNER_COLOR}" "    Elapsed Time   : ${ELAPSED_FMT}"
    fancy_echo "${BANNER_COLOR}" "${BANNER}"
}


# ------------------------------------------------------------------------------
#  Regression Test Procedures
# ------------------------------------------------------------------------------

# Test: required files
test_required_files() {
    run_test '[ -f VERSION ]' "VERSION file exists" COUNTER_PASS COUNTER_WARN COUNTER_FAIL COUNTER_TOTAL
    run_test "[ -f \"${SECRETS_FILE}\" ]" "SECRETS_FILE exists" COUNTER_PASS COUNTER_WARN COUNTER_FAIL COUNTER_TOTAL
}

# Test: YAML validation
test_yaml_validation() {
    if command -v yamllint >/dev/null 2>&1; then
        for YF in "${SRC_FILES[@]}"; do
            run_test "yamllint ${YF}" "YAML validation: ${YF} (yamllint)" COUNTER_PASS COUNTER_WARN COUNTER_FAIL COUNTER_TOTAL
        done
    elif command -v python >/dev/null 2>&1; then
        for YF in "${SRC_FILES[@]}"; do
            run_test "python -c 'import sys, yaml; yaml.safe_load(open(\"${YF}\"))'" "YAML validation: ${YF} (python/yaml)" COUNTER_PASS COUNTER_WARN COUNTER_FAIL COUNTER_TOTAL
        done
    else
        echo -e "${YELLOW}[WARN]${NC} YAML validation skipped: no yamllint or python found" | tee -a "${LOGFILE}"
    fi
}

# Test: utility targets
test_utility_targets() {
    local config="$1"
    local variant
    variant=$(basename "$config" | sed 's/-test\.mk$//')
    for T in ${UTILITY_TARGETS}; do
        run_test "make ${T} VARIANT=${variant} CONFIG=\"${config}\" VERBOSE=1" "Variant ${variant} - make ${T}" COUNTER_PASS COUNTER_WARN COUNTER_FAIL COUNTER_TOTAL
    done
}

# Test: build targets
test_build_targets() {
    local config="$1"
    local variant
    variant=$(basename "$config" | sed 's/-test\.mk$//')
    for T in ${BUILD_TARGETS}; do
        run_test "make ${T} VARIANT=${variant} CONFIG=\"${config}\"" "Variant ${variant} - make ${T}" COUNTER_PASS COUNTER_WARN COUNTER_FAIL COUNTER_TOTAL
    done
}

# Test: docs targets
test_doc_targets() {
    local config="$1"
    local variant
    variant=$(basename "$config" | sed 's/-test\.mk$//')
    for T in ${DOC_TARGETS}; do
        run_test "make ${T} VARIANT=${variant} CONFIG=\"${config}\"" "Variant ${variant} - make ${T}" COUNTER_PASS COUNTER_WARN COUNTER_FAIL COUNTER_TOTAL
    done
}

# Test: clean targets
test_clean_targets() {
    local config="$1"
    local variant
    variant=$(basename "$config" | sed 's/-test\.mk$//')
    for T in ${CLEAN_TARGETS}; do
        run_test "make ${T} VARIANT=${variant} CONFIG=\"${config}\"" "Variant ${variant} - make ${T}" COUNTER_PASS COUNTER_WARN COUNTER_FAIL COUNTER_TOTAL
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
    echo "$2" >> "$LOGFILE"
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
