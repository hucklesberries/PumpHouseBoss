#!/usr/bin/env bash
# ===============================================================================
#  File:         _pco_version_check.sh
#  File Type:    bash script (pre-commit op)
#  Purpose:      Check for embedded version string mismatches in project files (report-only)
#  Version:      0.8.0d
#  Date:         2025-07-31
#  Author:       Roland Tembo Hendel <rhendel@nexuslogic.com>
#
#  Description:
#    This script scans all YAML, Bash, Markdown, and Makefile project files for embedded
#    version strings and reports any mismatches with the version specified in the VERSION file.
#    It skips historical references (e.g., changelogs, history sections) and reports
#    all mismatches and skipped lines using color-coded output via pco_report.
#    This script is strictly non-destructive: it does NOT update or modify any files.
#
#  Policy:
#    If a version string is found, and the previous line or the same line contains
#    the phrase 'static version identifier' (case-insensitive), that version string
#    is considered historical/static and is ignored by this script.
#
#  Features:
#    - Reports version string mismatches in all project files
#    - Skips and reports historical references (changelog/history/old version)
#    - Reports all mismatches and skipped lines with color
#    - Uses robust regex patterns for version detection
#    - Uses pco_report for consistent output
#    - Staged approach for speed and maintainability
#
#  Usage:
#    ./_pco_version_check.sh
#
#  NOTE:
#    This script only checks and reports version mismatches. No files are ever updated or modified.
#
#  License:      GNU General Public License v3.0
#                SPDX-License-Identifier: GPL-3.0-or-later
#  Copyright:    (c) 2025 Roland Tembo Hendel
#                This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License.
# ===============================================================================

set -euo pipefail


# ------------------------------------------------------------------------------
#  Setup project paths and import shared logic
# ------------------------------------------------------------------------------
# Set PROJECT_ROOT to the parent directory of this script's directory
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SCRIPT_DIR="${PROJECT_ROOT}/scripts"

# Set Description string (used by pre-commit.sh in formatted output)
PCO_DESCRIPTION="Embedded Version String Check"

# Source PCO common declarations, definitions, and functions
source "${SCRIPT_DIR}/.common.sh"


# ------------------------------------------------------------------------------
#  Read current project version from VERSION file
# ------------------------------------------------------------------------------
VERSION_FILE="$PROJECT_ROOT/VERSION"

if [ ! -f "$VERSION_FILE" ]; then
    pco_report "VERSION file not found: $VERSION_FILE" "$RED"
    exit 1
fi
read -r NEW_VERSION < "$VERSION_FILE"


# ------------------------------------------------------------------------------
#  Version String Patterns (customize as needed)
# ------------------------------------------------------------------------------
# Matches: 1-2 digit X/Y/Z, optional single trailing lowercase letter (a-z)
VERSION_PATTERNS=(
    "([0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}[a-z]?)"
)
GREP_PATTERN='[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}[a-z]?'
today="$(date +%Y-%m-%d)"


# ------------------------------------------------------------------------------
#  Staged approach for fast version string checking
# ------------------------------------------------------------------------------

# --- Stage 1: Grep for all version string candidates ---
# Finds all lines in project files that contain a version string matching the pattern.
grep -EnH -- "$GREP_PATTERN" "${ALL_FILES[@]}" | 

# --- Stage 2: Awk to filter mismatches only ---
# Scans each line for version string matches using the regex.
# For each version string found, if it does not match the current project version,
# it prints the file, line number, found version, and the line text for further processing.
# Parameters:
#   new_version - The current project version (from VERSION file)
# Input format:
#   file:line_num:line_text
awk -F: -v new_version="$NEW_VERSION" '
{
    file=$1; line_num=$2; text=substr($0, index($0,$3));
    # Scan for all version strings in the line
    while (match(text, /([0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}[a-z]?)/, arr)) {
        version=arr[1];
        # Only print if version does not match the current project version
        if (version != new_version) {
            print file":"line_num":"version":"text;
        }
        # Continue scanning for additional matches in the same line
        text=substr(text, RSTART+RLENGTH);
    }
}
' | 

# --- Stage 3: Awk to skip static/historical lines and print results ---
# Determines whether each mismatched version string should be reported
# as a historical/static reference or a true mismatch. It uses the following logic:
# - If the line or the previous line contains 'static version identifier', or if the line
#   contains a date in the past, it is considered historical and skipped.
# - Otherwise, it is reported as a mismatch.
# Parameters:
#   YELLOW, RED, NC - Color codes for output
#   today - Current date (YYYY-MM-DD)
# Input format:
#   file:line_num:version:line_text
awk -F: -v YELLOW="$YELLOW" -v RED="$RED" -v NC="$NC" -v today="$today" '
    # Returns 1 if the string contains a date in the past (YYYY-MM-DD)
    function is_past_date(str,   r, y, m, d, dt) {
        r = match(str, /([0-9]{4})-([0-9]{2})-([0-9]{2})/, arr)
        if (r) {
            y = arr[1]; m = arr[2]; d = arr[3];
            dt = sprintf("%04d-%02d-%02d", y, m, d);
            return (dt < today)
        }
        return 0
    }
    {
        file=$1; line_num=$2; version=$3; text=substr($0, index($0,$4));
        # Read previous line for static version identifier or past date
        prev_line="";
        if (getline prev_line < file) {
            for (i=1; i<line_num; i++) getline prev_line < file;
        }
        # Determine if this version string should be skipped
        skip = (text ~ /static version identifier/ || prev_line ~ /static version identifier/ || is_past_date(text));
        if (skip) {
            # Historical/static reference: print in yellow
            printf "%s[HISTORICAL] %s @ %s, line: %s%s\n", YELLOW, version, file, line_num, NC;
        } else {
            # True mismatch: print in red and set found_mismatch flag
            printf "%s[MISMATCHED] %s @ %s, line: %s%s\n", RED, version, file, line_num, NC;
            found_mismatch=1;
        }
    }
    # Exit with code 1 if any mismatches were found, 0 otherwise
    END { if (found_mismatch) exit 1; else exit 0; }
'

#  Exit with failure if any mismatches were found
if [ $? -ne 0 ]; then
    exit 1
fi
