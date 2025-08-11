#!/usr/bin/env python3
# ==============================================================================
#  File:          pre-commit.py
#  File Type:     Python Script
#  Purpose:       Run Pre-Commit Operations PCO) scripts to ensure standards
#                 conformance prior to committing or tagging project files in
#                 the repo.
#  Version:       0.9.0d
#  Date:          2025-08-08
#  Author:        Roland Tembo Hendel <rhendel@nexuslogic.com>
#
#  Description:   Master pre-commit check/report automation script for
#                 PumpHouseBoss. Runs all pre-commit check/report scripts
#                 listed in the PCO_SCRIPTS array. Populates arrays of all YAML,
#                 Bash, and Makefile files in the project (excluding .gitignored
#                 files). This framework and all included scripts are strictly
#                 non-destructive: they only check and report, and do NOT update
#                 or modify any files.
#
#  Features:      - Explicit script selection via command-line arguments
#                 - Skips and warns for any missing or non-executable scripts
#                 - Colorful output (via pco_common)
#                 - Progress spinner for long-running operations (future)
#                 - Robust error handling and exit code propagation
#                 - Modular, maintainable, and DRY: shared helpers
#                   from pco_common
#
#  Usage:         pre-commit.py [options] [script1 [script2 ...]]
#                   Options:
#                     -h, --help             Show this help message and exit
#                     -v, --version          Show script version and exit
#                     script1 [script2 ...]  Run only the specified script(s)
#                   Example:
#                     pre-commit.py pco-header.py
#                     pre-commit.py pco-header.py pco-version.py
#
#  License:      GNU General Public License v3.0
#                SPDX-License-Identifier: GPL-3.0-or-later
#  Copyright:    (c) 2025 Roland Tembo Hendel
#                This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License.
# ==============================================================================

import sys
import os
import subprocess
from datetime import datetime
import pco_common
from colorama import Fore, Style

PCO_SCRIPTS = [
    "pco-header.py",
    "pco-version.py"
]

def Main():
    pco_common.pcoInit()
    invocationArguments = pco_common.ParseArgs("pre-commit.py", "0.9.0d", "Master pre-commit check/report automation script for PumpHouseBoss")
    if invocationArguments.filelist:
        Scripts = invocationArguments.filelist
    else:
        Scripts = PCO_SCRIPTS
    Scripts = [os.path.join(os.path.dirname(__file__), s) if not os.path.isabs(s) else s for s in Scripts]

    testsRun    = 0
    passCounter = 0
    failCounter = 0
    warnCounter = 0

    if len(Scripts) > 1:
        pco_common.PrintBanner("Pre-commit Operations")

    overallExit = 0
    for script in Scripts:
        testsRun += 1
        if not os.path.isfile(script):
            pco_common.PrintWarn(f"Script not found: {script}")
            warnCounter += 1
            continue
        try:
            result = subprocess.run([sys.executable, script], capture_output=True, text=True)
            exitCode = result.returncode
            output = result.stdout + result.stderr
            if exitCode == 0:
                pco_common.PrintPass(f"{os.path.basename(script)}, details:")
                passCounter += 1
            elif exitCode == 255:
                pco_common.PrintWarn(f"{os.path.basename(script)}, details:")
                warnCounter += 1
                if overallExit == 0:
                    overallExit = 255
            else:
                pco_common.PrintFail(f"{os.path.basename(script)}, details:")
                failCounter += 1
                overallExit = 1
            # Print all output lines except banners, colorizing multiline details based on previous tag
            if output.strip():
                arrow = "\u2192"  # Unicode right arrow
                color = None
                for line in output.strip().splitlines():
                    lstripped = line.lstrip()
                    # Filter banner lines
                    if (
                        set(line.strip()) == {'='} or
                        'Conformance Validation' in line or
                        (line.strip().startswith('Files processed:') or
                         line.strip().startswith('Passed:') or
                         line.strip().startswith('Failed:') or
                         line.strip().startswith('Warnings:'))
                    ):
                        continue
                    if lstripped.startswith("[FAIL]"):
                        color = Fore.RED
                        print(color + f"  {arrow} {line.strip()}" + Style.RESET_ALL)
                    elif lstripped.startswith("[WARN]"):
                        color = Fore.YELLOW
                        print(color + f"  {arrow} {line.strip()}" + Style.RESET_ALL)
                    elif lstripped.startswith("[PASS]"):
                        color = Fore.GREEN
                        print(color + f"  {arrow} {line.strip()}" + Style.RESET_ALL)
                    else:
                        # Colorize multiline details with previous color if set
                        if color:
                            print(color + f"    {line.strip()}" + Style.RESET_ALL)
                        else:
                            print(f"    {line.strip()}")
        except Exception as e:
            pco_common.PrintFail(f"Error running {script}: {e}")
            failCounter += 1
            overallExit = 1
    if len(Scripts) > 1:
        # Print a colorized summary of results (banner, counts, etc).
        if failCounter == 0 and warnCounter == 0:
            color = Fore.GREEN
        elif failCounter > 0:
            color = Fore.RED
        else:
            color = Fore.YELLOW
        line = '=' * 80
        print(color + line)
        print(f"Tests Run:      {str(testsRun).zfill(2)}")
        print(f"Tests Passed:   {str(passCounter).zfill(2)}")
        print(f"Tests Failed:   {str(failCounter).zfill(2)}")
        print(f"Tests Warning:  {str(warnCounter).zfill(2)}")
        print(line + Style.RESET_ALL)
        sys.exit(overallExit)

if __name__ == "__main__":
    Main()
