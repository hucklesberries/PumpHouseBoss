#!/usr/bin/env bash
# ------------------------------------------------------------------------------
#  file        regression-test.sh
#  brief       Project regression test runner for ESPHome-based device management
#  details     Runs a suite of checks and utility targets, logging results and
#              printing a summary. Designed to be called from the Makefile or
#              directly from the shell. All output is logged to TEST_LOGFILE.
#
#  author      Roland Tembo Hendel
#  email       rhendel@nexuslogic.com
#
#  license     GNU General Public License v3.0
#              SPDX-License-Identifier: GPL-3.0-or-later
#  copyright   Copyright (c) 2025 Roland Tembo Hendel
#              This program is free software: you can redistribute it and/or
#              modify it under the terms of the GNU General Public License
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
#  Configuration
# ------------------------------------------------------------------------------

# List of targets to check (matches Makefile)
UTILITY_TARGETS="${TEST_TARGETS:-help version buildvars}"
BUILD_TARGETS="${BUILD_TARGETS:-build docs-esphome docs-mkdoc}"
YAML_DIRECTORIES=(./ common)

# Dynamically find all .yaml files in YAML_DIRECTORIES
YAML_FILES=()
for dir in "${YAML_DIRECTORIES[@]}"; do
    while IFS= read -r -d $'\0' file; do
        YAML_FILES+=("$file")
    done < <(find "$dir" -maxdepth 1 -type f -name '*.yaml' -print0 2>/dev/null)
done

# Log file for all output
TEST_LOGFILE="${TEST_LOGFILE:-regression-test.log}"

# Key project files to check
CONFIG_SCRIPT="${CONFIG_SCRIPT:-./configure.sh}"
MAIN="${MAIN:-./main.yaml}"
SECRETS_FILE="${SECRETS_FILE:-./common/secrets.yaml}"

# Color codes for output
GREEN="${GREEN:-\033[0;32m}"
RED="${RED:-\033[0;31m}"
YELLOW="${YELLOW:-\033[0;33m}"
NC="${NC:-\033[0m}"

# Output tags
OK="${GREEN}[OK]${NC}"
WARN="${YELLOW}[WARN]${NC}"
FAIL="${RED}[FAIL]${NC}"


# ----------------------------------------------------------------------------
#  Command line options:
# ----------------------------------------------------------------------------

# Show version information and exit
show_help() {
    echo "Usage: $0 [output_file] [-h|--help] [-v|--version]"
    echo "  -h, --help     Show this help message and exit."
    echo "  -v, --version  Show script version and exit"
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

# Parse command line options
for arg in "$@"; do
    case "$arg" in
        -h|--help)
            show_help
            exit 0
            ;;
        -v|--version)
            show_version
            exit 0
            ;;
        *)
            show_help
            exit -1
            ;;
    esac
done


# ------------------------------------------------------------------------------
#  Main regression test logic
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
#  run_test: Run a shell command, log output, and print summary line
#   $1: Command to run
#   $2: Description for summary
#   $3: Name of failures variable (by reference)
#   $4: Name of total variable (by reference)
run_test() {
    local cmd="$1"
    local desc="$2"
    local -n failures_ref=$3
    local -n total_ref=$4
    local tmp_output
    tmp_output=$(mktemp)
    if eval "$cmd" >> "$tmp_output" 2>&1; then
        if grep -Eiq '(warn|error|fail)' "$tmp_output"; then
            echo -e "${WARN} $desc" | tee -a "$TEST_LOGFILE"
        else
            echo -e "${OK}   $desc" | tee -a "$TEST_LOGFILE"
        fi
    else
        echo -e "${FAIL} $desc" | tee -a "$TEST_LOGFILE"
        ((failures_ref++))
    fi
    cat "$tmp_output" >> "$TEST_LOGFILE"
    rm -f "$tmp_output"
    ((total_ref++))
}

# Start the log file with a banner and timestamp
{
    echo "==============================================================================="
    echo "  Regression Test Log"
    echo "  Date: $(date)"
    echo "==============================================================================="
} > "$TEST_LOGFILE"

# Initialize counters
failures=0
total=0

# Check for required files
run_test '[ -f VERSION ]' "VERSION file exists" failures total
run_test "[ -f $CONFIG_SCRIPT ]" "CONFIG_SCRIPT exists" failures total
run_test "[ -f $MAIN ]" "MAIN YAML exists" failures total
run_test "[ -f $SECRETS_FILE ]" "SECRETS_FILE exists" failures total

# YAML validation for all YAML files in root and common/
if command -v yamllint >/dev/null 2>&1; then
    for yf in "${YAML_FILES[@]}"; do
        run_test "yamllint $yf" "YAML validation: $yf (yamllint)" failures total
    done
elif command -v python >/dev/null 2>&1; then
    for yf in "${YAML_FILES[@]}"; do
        run_test "python -c 'import sys, yaml; yaml.safe_load(open(\"$yf\"))'" "YAML validation: $yf (python/yaml)" failures total
    done
else
    echo -e "${YELLOW}[WARN]${NC} YAML validation skipped: no yamllint or python found" | tee -a "$TEST_LOGFILE"
fi

# Run each utility target and log the result
for t in $UTILITY_TARGETS; do
    run_test "make $t" "Utility Target: $t" failures total
done

# Run each build target and log the result
for t in $BUILD_TARGETS; do
    run_test "make $t" "Build Target  : $t" failures total
done

# Print final summary with color-coded result
if [ "$failures" -eq 0 ]; then
    echo -e "${GREEN}All regression tests passed ($total/$total)${NC}"
else
    echo -e "${RED}Regression tests failed: ${failures} of ${total} tests failed.${NC}"
    echo -e "${RED}See ${TEST_LOGFILE} for results."
fi
