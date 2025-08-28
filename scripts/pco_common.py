#!/usr/bin/env python3
# ==============================================================================
#  File:          pco_common.py
#  File Type:     Python Script
#  Purpose:       Module of definitions, declarations, and functions for
#                 PCO python scripts
#  Version:       0.9.0d
#  Date:          2025-08-07
#  Author:        Roland Tembo Hendel <rhendel@nexuslogic.com>
#
#  Description:   Pre-Commit Operations (PCO) scripts are intended to aid
#                 developers when enforcing established coding standards across
#                 a project or codebase.
#                 This module provides common definitions,declarations, and
#                 functions used across PCO scripts.
#
#  Features:      - Module initialization
#                 - Project file discovery, organized into arrays by filetype
#                 - Standardized argument parsing for -h, -v, [filelist]
#                 - Consistent, colorized status output (PASS, WARN, FAIL)
#                 - Banner and summary reporting utilities
#
#  Usage:         Import this module in any PCO Python script:
#                   from pco_common import ParseArgs, PrintPass, PrintWarn,
#                       PrintFail, PrintBanner, PrintSummary, ExitSuccess,
#                       ExitWarn, ExitFail, pcoInit
#
#  Note:          Importing scripts must call pco_common.pcoInit() prior to
#                 using the features of this module.
#
#  License:      GNU General Public License v3.0
#                SPDX-License-Identifier: GPL-3.0-or-later
#  Copyright:    (c) 2025 Roland Tembo Hendel
#                This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License.
# ==============================================================================


import sys
import threading
import time
import subprocess
import os
import textwrap
import argparse
from   pathlib import Path
from   colorama import init, Fore, Style
import signal


# -------------------------------------------------------------------------------
#  Declarations and Definitions
# -------------------------------------------------------------------------------

# static files and directories
PROJECT_ROOT   = Path(__file__).resolve().parent.parent
SCRIPTS_DIR    = PROJECT_ROOT / 'scripts'
VERSION_FILE   = PROJECT_ROOT / 'VERSION'
SECRETS_FILE   = PROJECT_ROOT / 'common' / 'secrets.yaml'
VARIANTS       = ["phb-std", "phb-pro", "phb-test"]

# dynamic file lists (arrays) by type
MAKEFILES      = []
YAML_FILES     = []
CPP_FILES      = []
MD_FILES       = []
PYTHON_SCRIPTS = []
BASH_SCRIPTS   = []
ALL_FILES      = []

# exit codes
EXIT_SUCCESS   = 0
EXIT_WARN      = 255
EXIT_FAIL      = 1

# special characters
RIGHT_ARROW    = '\u2192'


# -------------------------------------------------------------------------------
#  pcoInit: Initialize PCO common environment for scripts.
#    - Initializes colorama for cross-platform color output
#    - Populates YAML_FILES, MD_FILES, SCRIPT_FILES, MAKEFILES, and ALL_FILES
#      with absolute paths (uses git ls-files if available, else rglob)
#    - Call at script start to refresh file lists and enable color
#
def pcoInit():

    # Install signal handler for graceful CTRL-C termination
    def sigintHandler(signum, frame):
        print(Fore.YELLOW + '\n[WARN] Terminated by user (CTRL-C). Exiting.' + Style.RESET_ALL)
        sys.exit(EXIT_WARN)

    signal.signal(signal.SIGINT, sigintHandler)

    # Initialize colorama
    init()

    # Populate project file lists for PCO scripts.
    global MAKEFILES, YAML_FILES, CPP_FILES, MD_FILES, PYTHON_SCRIPTS, BASH_SCRIPTS, ALL_FILES
    try:
        result = subprocess.run(
            ['git', 'ls-files', '--cached', '--others', '--exclude-standard'],
            cwd=PROJECT_ROOT,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True
        )
        all_files = [PROJECT_ROOT / Path(line.strip()) for line in result.stdout.splitlines() if line.strip()]

    except Exception:
        all_files = list(PROJECT_ROOT.rglob('*'))

    MAKEFILES      = [str(f).strip() for f in all_files if f.name.lower().startswith('makefile') or f.suffix == '.mk']
    YAML_FILES     = [str(f).strip() for f in all_files if f.suffix in ['.yaml', '.yml']]
    CPP_FILES      = [str(f).strip() for f in all_files if f.suffix in ['.c', '.h', '.cpp', '.hpp' ]]
    MD_FILES       = [str(f).strip() for f in all_files if f.suffix.lower() == '.md']
    PYTHON_SCRIPTS = [str(f).strip() for f in all_files if f.suffix.lower() =='.py']
    BASH_SCRIPTS   = [str(f).strip() for f in all_files if f.suffix in ['.sh', '.bash']]

    # Dedup and preserve order
    seen = set()
    ALL_FILES = []
    for f in MAKEFILES + YAML_FILES + CPP_FILES + MD_FILES + PYTHON_SCRIPTS + BASH_SCRIPTS:
        if f and f not in seen:
            ALL_FILES.append(f)
            seen.add(f)

# -------------------------------------------------------------------------------
#  Status Exit Functions
# -------------------------------------------------------------------------------
#  ExitSuccess(): Exit with code 0
#  ExitWarn(msg=None): Print warning and exit with code 255
#  ExitFail(msg=None): Print error and exit with code 1
#
def ExitSuccess():
    sys.exit(EXIT_SUCCESS)

def ExitWarn(msg=None):
    if msg is not None:
        PrintWarn(msg)
    sys.exit(EXIT_WARN)

def ExitFail(msg=None):
    if msg is not None:
        PrintFail(msg)
    sys.exit(EXIT_FAIL)


# -------------------------------------------------------------------------------
#  ParseArgs: Standardized argument parsing for PCO scripts.
#    - Supports -h (help), -v (version), and [filelist]
#    - Returns argparse.Namespace with .version, .files
#    - Prints help/version and exits if requested
#    - Usage: args = ParseArgs(description, version, [long_description])
#    - description: Short script description for help output
#    - version:     Version string for -v/--version
#    - long_description: Optional long description for help output
#
def ParseArgs(description, version, long_description=None):
    desc = long_description if long_description is not None else description
    parser = argparse.ArgumentParser(
        description=desc,
        formatter_class=argparse.RawDescriptionHelpFormatter,
        add_help=False
    )
    parser.add_argument('-h', '--help',  action='help', help='Show this help message and exit')
    parser.add_argument('-v', '--version', action='version', version=version, help='Show version and exit')
    parser.add_argument('filelist', nargs='*', help='Files to process (optional)')
    args = parser.parse_args()
    return args


# -------------------------------------------------------------------------------
#  Status Output Functions (Colorized, wrapped, and standardized)
# -------------------------------------------------------------------------------
#  PrintPass(msg): Print green PASS message
#  PrintWarn(msg): Print yellow WARN message
#  PrintFail(msg): Print red FAIL message
#    - PASS prints to stdout, WARN/FAIL print to stderr
#    - Output is colorized and wrapped to 71 chars for readability
#
def PrintPass(msg):
    # Print a green PASS message (stdout, colorized, wrapped).
    msg = textwrap.fill(msg, width=71, subsequent_indent="         ")
    print(Fore.GREEN + '[PASS] ' + RIGHT_ARROW + ' ' + msg + Style.RESET_ALL)

def PrintWarn(msg):
    # Print a yellow WARN message (stderr, colorized, wrapped).
    msg = textwrap.fill(msg, width=71, subsequent_indent="         ")
    print(Fore.YELLOW + '[WARN] '+ RIGHT_ARROW + ' '  + msg + Style.RESET_ALL, file=sys.stderr)

def PrintFail(msg):
    # Print a red FAIL message (stderr, colorized, wrapped).
    msg = textwrap.fill(msg, width=71, subsequent_indent="         ")
    print(Fore.RED + '[FAIL] '+ RIGHT_ARROW + ' '  + msg + Style.RESET_ALL, file=sys.stderr)


# -------------------------------------------------------------------------------
#  Banner and Summary Reporting Utilities (Color/Print Section)
# -------------------------------------------------------------------------------
#  PrintBanner(description): Print a green banner, 80 chars wide, centered
#  PrintSummary(total_files, passed, failed, warnings): Print colorized summary
#
def PrintBanner(description):
    # Print a single green banner, 80 chars wide, description centered.
    desc = f" {description} "
    banner = desc.center(80, '=')
    print(Fore.GREEN + banner + Style.RESET_ALL)

def PrintSummary(total_files, passed, failed, warnings):
    # Print a colorized summary of results (banner, counts, etc).
    if failed == 0 and warnings == 0:
        color = Fore.GREEN
    elif failed > 0:
        color = Fore.RED
    else:
        color = Fore.YELLOW
    line = '=' * 80
    print(color + line)
    print(f"Files processed: {str(total_files).zfill(2)}")
    print(f"Passed:          {str(passed).zfill(2)}")
    print(f"Failed:          {str(failed).zfill(2)}")
    print(f"Warnings:        {str(warnings).zfill(2)}")
    print(line + Style.RESET_ALL)
