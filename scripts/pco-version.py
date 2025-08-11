#!/usr/bin/env python3
# ==============================================================================
#  File:          pco-version.py
#  File Type:     Python Script
#  Purpose:       Validate that all embedded version strings have been updated
#                 prior to committing or tagging project files in the repo.
#  Version:       0.9.0d
#  Date:          2025-08-08
#  Author:        Roland Tembo Hendel <rhendel@nexuslogic.com>
#
#  Description:   Scans project files for embedded version strings and checks
#                 for mismatches against the current project version. Reports
#                 historical/static references as warnings, true mismatches as
#                 failures. Prints a colorized summary and exits with code 1 if
#                 any mismatches are found, 0 if all files pass. Warnings do not
#                 cause a nonzero exit code unless there are failures.
#
#  Features:      - Scans all project files for version strings
#                 - Compares found versions to the current project version
#                 - Reports historical/static references as warnings
#                 - Reports true mismatches as failures
#                 - Prints colorized banner and summary
#                 - Exits 1 if any mismatches, 0 if all pass (warnings do not
#                   affect exit code)
#
#  Usage:         pco-version.py [options]
#                   Options:
#                     -h, --help       Show this help message and exit
#                     -v, --version    Show script version and exit
#                   Example:
#                     pco-version.py somefile
#
#  License:      GNU General Public License v3.0
#                SPDX-License-Identifier: GPL-3.0-or-later
#  Copyright:    (c) 2025 Roland Tembo Hendel
#                This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License.
# ==============================================================================
#
import re
import sys
import os
from  datetime import datetime
import pco_common


# -------------------------------------------------------------------------------
# Definitions, Declarations, Constants and Globals
# -------------------------------------------------------------------------------

VERSION_FILE = 'VERSION'
VERSION_PATTERN = r'[0-9]{1,2}\.[0-9]{1,2}\.[0-9]{1,2}[a-z]?'
DATE_PATTERN = r'([0-9]{4})-([0-9]{2})-([0-9]{2})'
STATIC_IDENTIFIER = 'static version identifier'
PCO_DESCRIPTION = "Embedded Version String Conformance Validation"


# -------------------------------------------------------------------------------
# Utility Functions
# -------------------------------------------------------------------------------
def IsPastDate(s, today):
    match = re.search(DATE_PATTERN, s)
    if match:
        dt = f"{match.group(1)}-{match.group(2)}-{match.group(3)}"
        return dt < today
    return False

# -------------------------------------------------------------------------------
# Main Entry Point
# -------------------------------------------------------------------------------
def Main():
    filesProcessed = 0
    passCounter    = 0
    failCounter    = 0
    warnCounter    = 0

	# initialize pco environment
    pco_common.pcoInit()

    # Get current project version
    try:
        with open(VERSION_FILE, 'r') as vf:
            currentVersion = vf.read().strip()
    except Exception as e:
        pco_common.PrintFail(f"Could not read VERSION file: {e}")
        pco_common.ExitFail()

	# parse CLAs
    invocationArguments = pco_common.ParseArgs("pco-version.py", "0.9.0d", PCO_DESCRIPTION)

    if invocationArguments.filelist:
        Files = invocationArguments.filelist
    else:
        Files = pco_common.ALL_FILES

    if len(Files) > 1:
        pco_common.PrintBanner(PCO_DESCRIPTION)

    for file in Files:
        filesProcessed += 1
        try:
            with open(file, 'r', encoding='utf-8', errors='ignore') as f:
                lines = f.readlines()
        except Exception as e:
            pco_common.PrintWarn(f"{file}: Could not read file ({e})")
            warnCounter += 1
            continue
        mismatch = False
        for i, line in enumerate(lines):
            for match in re.finditer(VERSION_PATTERN, line):
                version = match.group(0)
                if version == currentVersion:
                    continue
                prev_line = lines[i-1] if i > 0 else ''
                skip = (STATIC_IDENTIFIER in line or STATIC_IDENTIFIER in prev_line or IsPastDate(line, datetime.now().strftime('%Y-%m-%d')))
                if skip:
                    pco_common.PrintWarn(f"[HISTORICAL] {version} @ {file}, line: {i+1}")
                    warnCounter += 1
                else:
                    pco_common.PrintFail(f"[MISMATCHED] {version} @ {file}, line: {i+1}")
                    mismatch = True
        if mismatch:
            failCounter += 1
        else:
            passCounter += 1
            pco_common.PrintPass(f"{file}")

    if len(Files) > 1:
        pco_common.PrintSummary(filesProcessed, passCounter, failCounter, warnCounter)
    if failCounter == 0:
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == "__main__":
    Main()
