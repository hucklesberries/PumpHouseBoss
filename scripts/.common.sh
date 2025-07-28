
#!/usr/bin/env bash
# ===============================================================================
#  File:         .common.sh
#  File Type:    bash script
#  Purpose:      Utility definitions, macros, and functions for use in project
#                scripts
#  Version:      0.7.1
#  Date:         2025-07-24
#  Author:       Roland Tembo Hendel <rhendel@nexuslogic.com>
#
#  Description:  Utility script to be included by other scripts to provide
#                a single source for commonly used definitions, macros, and
#		         functions.
#
#  Features:     - Common directory and file macros
#                - Support for colorized output
#
#  Usage:        include .coomon.sh
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


# Set PROJECT_ROOT to the absolute path of the project root (parent of scripts dir)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Detect if terminal supports color
if [ -t 1 ] && command -v tput >/dev/null 2>&1 && [ $(tput colors) -ge 8 ]; then
    COLOR_SUPPORT=1
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
    ORANGE="\033[38;5;208m"
    NC="\033[0m"
else
    COLOR_SUPPORT=0
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
    ORANGE=""
    NC=""
fi
