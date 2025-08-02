#!/usr/bin/env bash
# ===============================================================================
#  File:         .common.sh
#  File Type:    bash script (sourced)
#  Purpose:      Common functions, color definitions, and utilities for PumpHouseBoss scripts
#  Version:      0.8.0d
#  Date:         2025-07-31
#  Author:       Roland Tembo Hendel <rhendel@nexuslogic.com>
#
#  Description:  This file is intended to be sourced by other scripts in the PumpHouseBoss
#                project. It provides color definitions, output helpers, and other shared
#                utilities to ensure consistency and reduce duplication.
#
#  Usage:        source "$(dirname "$0")/.common.sh"
#
#  License:      GNU General Public License v3.0
#                SPDX-License-Identifier: GPL-3.0-or-later
#  Copyright:    (c) 2025 Roland Tembo Hendel
#                This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License.
# ===============================================================================


# ------------------------------------------------------------------------------
#  Declaration and Definitions
# ------------------------------------------------------------------------------
# This section sets up project paths, file discovery, and file type arrays for use
# in all PumpHouseBoss scripts. It ensures all relevant project files are available
# for scanning, reporting, or updating operations.

# Establish project paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Create a placeholder for LOGFILE
LOGFILE=""

# Efficient file discovery: single git call, classify by extension/pattern, absolute paths
# _ALL_PROJECT_FILES contains all tracked and untracked files (not ignored by git).
mapfile -t _ALL_PROJECT_FILES < <(cd "$PROJECT_ROOT" && git ls-files --cached --others --exclude-standard)

# Arrays for different file types
# YAML_FILES: All YAML config files (.yaml, .yml)
# MD_FILES: All Markdown documentation files (.md, .MD)
# SCRIPT_FILES: All shell scripts (.sh, .bash)
# MAKEFILES: All Makefiles and variants
YAML_FILES=()
MD_FILES=()
SCRIPT_FILES=()
MAKEFILES=()

# Populate file type arrays
# Each file is classified by extension or name and added to the appropriate array.
for relpath in "${_ALL_PROJECT_FILES[@]}"; do
    abs="$PROJECT_ROOT/$relpath"
    case "$relpath" in
        *.yaml|*.yml)
            YAML_FILES+=("$abs") ;;
        *.md|*.MD)
            MD_FILES+=("$abs") ;;
        *.sh|*.bash)
            SCRIPT_FILES+=("$abs") ;;
        Makefile|makefile|Makefile.*|makefile.*|*.mk)
            MAKEFILES+=("$abs") ;;
    esac
done

# Concatenate all arrays, remove duplicates
# ALL_FILES contains all project files of interest, with duplicates removed.
ALL_FILES=()
for f in "${YAML_FILES[@]}" "${MD_FILES[@]}" "${SCRIPT_FILES[@]}" "${MAKEFILES[@]}"; do
    [[ -n "$f" ]] && ALL_FILES+=("$f")
done

# Remove duplicates (preserve order)
# Uses an associative array to track seen files and preserve order.
declare -A _seen
_deduped=()
for f in "${ALL_FILES[@]}"; do
    if [[ -n "$f" && -z "${_seen[$f]+x}" ]]; then
        _deduped+=("$f")
        _seen[$f]=1
    fi
done
ALL_FILES=("${_deduped[@]}")


# ------------------------------------------------------------------------------
#  Terminal functions and color handling
# ------------------------------------------------------------------------------

# set_color_vars: Assigns ANSI color codes to color variables
# Usage: set_color_vars <enable>
#   enable=1: set color codes
#   enable=0: set all color vars to empty string
set_color_vars() {
    local enable="$1"
    if [ "$enable" = "1" ]; then
        BLACK="\033[0;30m"
        RED="\033[0;31m"
        GREEN="\033[0;32m"
        YELLOW="\033[0;33m"
        BLUE="\033[0;34m"
        MAGENTA="\033[0;35m"
        CYAN="\033[0;36m"
        WHITE="\033[0;37m"
        BRIGHT_BLACK="\033[1;30m"
        BRIGHT_RED="\033[1;31m"
        BRIGHT_GREEN="\033[1;32m"
        BRIGHT_YELLOW="\033[1;33m"
        BRIGHT_BLUE="\033[1;34m"
        BRIGHT_MAGENTA="\033[1;35m"
        BRIGHT_CYAN="\033[1;36m"
        BRIGHT_WHITE="\033[1;37m"
        NC="\033[0m"
        COLOR_SUPPORT=1
    else
        BLACK=""
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        MAGENTA=""
        CYAN=""
        WHITE=""
        BRIGHT_BLACK=""
        BRIGHT_RED=""
        BRIGHT_GREEN=""
        BRIGHT_YELLOW=""
        BRIGHT_BLUE=""
        BRIGHT_MAGENTA=""
        BRIGHT_CYAN=""
        BRIGHT_WHITE=""
        NC=""
        COLOR_SUPPORT=0
    fi
}

# OS/terminal color support detection (POSIX, Cygwin, macOS, Linux, Windows)
if [ "${COLOR_SUPPORT:-}" = "1" ]; then
    # Forced color support via environment variable
    set_color_vars 1
else
    case "$(uname -s 2>/dev/null)" in
        CYGWIN*|MINGW*|MSYS*)
            if [ -t 1 ] && ( [ "$TERM" = "xterm" ] || [ "$TERM" = "xterm-256color" ] || [ "$TERM" = "cygwin" ] ); then
                set_color_vars 1
            else
                set_color_vars 0
            fi
            ;;
        Linux*|Darwin*)
            if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ $(tput colors) -ge 8 ]; then
                set_color_vars 1
            else
                set_color_vars 0
            fi
            ;;
        *)
            set_color_vars 0
            ;;
    esac
fi

# Output tags for status reporting
# PASS: Success, WARN: Warning, FAIL: Error
PASS="${GREEN}[PASS]${NC}"
WARN="${YELLOW}[WARN]${NC}"
FAIL="${RED}[FAIL]${NC}"

HORIZONTAL_DELIMETER="========================================================================================"

# ------------------------------------------------------------------------------
#  Printing and Reporting
# ------------------------------------------------------------------------------

# smartprint: Print a line in color to stdout and plain to logfile
# Usage: smartprint <color> <message>
# Params:
#   color   - ANSI color code (e.g., "$GREEN")
#   message - Text to print
# Prints to stdout in color (if supported), and appends to LOGFILE (if set).
smartprint() {
    local color="$1"
    local msg="$2"
    if [ "$COLOR_SUPPORT" -eq 1 ]; then
        printf "%b\n" "${color}${msg}${NC}"
    else
        printf "%s\n" "$msg"
    fi
    if [ -n "$LOGFILE" ]; then
        # Ensure logfile exists and is writeable before writing
        if [ ! -e "$LOGFILE" ]; then
            touch "$LOGFILE" 2>/dev/null || true
        fi
        if [ ! -w "$LOGFILE" ]; then
            printf "[ERROR] Log file '%s' is not writeable.\n" "$LOGFILE" >&2
            return 1
        fi
        printf "%s\n" "$msg" >> "$LOGFILE"
    fi
}

# warn: Print a warning to stderr
# Usage: warn <message>
# Prints message in yellow with [WARN] prefix.
warn() {
    local msg="$1"
    smartprint "$YELLOW" "[WARN] $msg" >&2
}

# error: Print an error to stderr
# Usage: error <message>
# Prints message in red with [FAIL] prefix.
error() {
    local msg="$1"
    smartprint "$RED" "[FAIL] $msg" >&2
}

# good: Print a success message
# Usage: good <message>
# Prints message in green with [PASS] prefix.
good() {
    local msg="$1"
    smartprint "$GREEN" "[PASS] $msg"
}

# pco_report: Print a report line with right-arrow prefix (for op scripts)
# Usage: pco_report <message> [color]
# Params:
#   message - Text to print
#   color   - Optional ANSI color code
# Prints message with a right-arrow prefix, in color if provided.
pco_report() {
    local msg="$1"
    local color="${2:-}"
    if [ -n "$color" ]; then
        smartprint "$color" "→ $msg"
    else
        smartprint "" "→ $msg"
    fi
}

# confirm: Prompt for confirmation (y/N)
# Usage: confirm "Prompt text" && do_something
# Returns 0 if user answers yes, 1 otherwise.
confirm() {
    local prompt="$1 [y/N] "
    local yn
    read -r -p "$prompt" yn
    case $yn in
        [Yy]*) return 0;;
        *) return 1;;
    esac
}


# -----------------------------------------------------------------------------
#  Spinner for progress indication (background)
# -----------------------------------------------------------------------------

# PCO_SPINNER_PID: PID of spinner background process
# PCO_SPINNER_ACTIVE: Flag to control spinner loop
PCO_SPINNER_PID=""
PCO_SPINNER_ACTIVE=0

# pco_spinner_start: Start a spinner with a message (background)
# Usage: pco_spinner_start <message>
# Params:
#   message - Text to display while spinner is active
# Prints <message> with a spinner (|/-\) at the end, updating every 500ms.
# Hides cursor while spinner is running.
# Spinner PID is stored in PCO_SPINNER_PID.
pco_spinner_start() {
    local msg="$1"
    local chars='|/-\\'
    local i=0
    PCO_SPINNER_ACTIVE=1
    tput civis 2>/dev/null || true
    (
        while [ $PCO_SPINNER_ACTIVE -eq 1 ]; do
            local c=${chars:i%4:1}
            printf "\r%s [%s]" "$msg" "$c"
            i=$(( (i+1) % 4 ))
            sleep 0.5
        done
    ) &
    PCO_SPINNER_PID=$!
}

# pco_spinner_stop: Stop the spinner and clear the line
# Usage: pco_spinner_stop
# Stops spinner background process, restores cursor, and clears spinner line.
pco_spinner_stop() {
    local cols
    if [ -n "$PCO_SPINNER_PID" ]; then
        PCO_SPINNER_ACTIVE=0
        kill "$PCO_SPINNER_PID" 2>/dev/null || true
        wait "$PCO_SPINNER_PID" 2>/dev/null || true
        PCO_SPINNER_PID=""
        # Clear spinner line
        cols=$(tput cols 2>/dev/null || echo 80)
        printf "\r%*s\r" "$cols" ""
        tput cnorm 2>/dev/null || true
    fi
}
