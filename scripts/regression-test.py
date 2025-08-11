#!/usr/bin/env python3
# ==============================================================================
#  File:          regression-test.py
#  File Type:     Python Script
#  Purpose:       Perform all regression tests on all targets of the
#                 PumpHouseBoss project
#  Version:       0.9.0d
#  Date:          2025-08-08
#  Author:        Roland Tembo Hendel <rhendel@nexuslogic.com>
#
#  Description:   Project regression test runner for ESPHome-based device
#                 management. Runs a suite of checks and utility targets for all
#                 project variants, echoing results and a summary report.
#                 Designed to be called from the Makefile or directly from the
#                 shell.
#
#  Features:      - Validates required files and YAML syntax
#                 - Runs Makefile utility, build, docs, and clean targets per
#                   variant
#                 - Colorized output in terminal
#                 - Elapsed time and summary reporting
#                 - Robust error handling and exit code propagation
#                 - Modular, maintainable, and DRY: shared helpers from
#                   pco_common
#
#  Usage:         regression-test.py [options]
#                   Options:
#                     -h, --help       Show this help message and exit
#                     -v, --version    Show script version and exit
#                   Example:
#                     regression-test.py somefile
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
import glob
import time
import cursor
import signal
import pco_common
from   datetime import datetime
from   colorama import Fore, Style
from   yaspin import yaspin


UTILITY_TARGETS = ["help", "version", "buildvars"]
BUILD_TARGETS   = ["build"]
DOC_TARGETS     = ["docs"]
CLEAN_TARGETS   = ["clean", "clean-cache"]
CLOBBER_TARGETS = ["clean-docs", "clobber"]

# Results counters
COUNTER_PASS    = 0
COUNTER_FAIL    = 0
COUNTER_WARN    = 0
COUNTER_TOTAL   = 0

BANNER          = "=" * 80

# Trap for graceful termination and killing child processes
def sigintHandler(signum, frame):
    print(Fore.YELLOW + '\n[WARN] Terminated by user (CTRL-C). Exiting gracefully.' + Style.RESET_ALL)
    # Kill all child processes
    import psutil, os
    current = psutil.Process(os.getpid())
    for child in current.children(recursive=True):
        try:
            child.terminate()
        except Exception:
            pass
    printSummaryBanner()
    sys.exit(255)
signal.signal(signal.SIGINT, sigintHandler)

def runTest(cmd, desc):
    global COUNTER_PASS, COUNTER_FAIL, COUNTER_WARN, COUNTER_TOTAL
    with yaspin(text="Running " + desc, color="yellow") as sp:
        with cursor.HiddenCursor():
            try:
                result = subprocess.run(cmd, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
                output = result.stdout + result.stderr
                if result.returncode == 0:
                    if any(w in output.lower() for w in ["fail", "error"]):
                        sp.text = "\r" + Fore.RED + "[FAIL] " + desc + Style.RESET_ALL
                        COUNTER_FAIL += 1
                    elif "warn" in output.lower():
                        sp.text = "\r" + Fore.YELLOW + "[WARN] " + desc + Style.RESET_ALL
                        COUNTER_WARN += 1
                    else:
                        sp.text = "\r" + Fore.GREEN + "[PASS] " + desc + Style.RESET_ALL
                        COUNTER_PASS += 1
                else:
                    sp.text = "\r" + Fore.RED + "[FAIL] " + desc + Style.RESET_ALL
                    COUNTER_FAIL += 1
                COUNTER_TOTAL += 1
                sp.ok()
            except Exception as e:
                sp.text = "\r" + Fore.RED + "[FAIL] " + desc + ": " + str(e) + Style.RESET_ALL
                COUNTER_FAIL += 1
                COUNTER_TOTAL += 1
                sp.ok()

# Print start banner
def printStartBanner():
    print(Fore.GREEN + BANNER)
    print(Fore.GREEN + "  Starting Regression Testing:")
    print(Fore.GREEN + f"    Start Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(Fore.GREEN + BANNER + Style.RESET_ALL)

# Print summary banner
def printSummaryBanner(start_time):
    end_time = datetime.now()
    elapsed = end_time - start_time
    elapsed_fmt = f"{elapsed.seconds//60}m {elapsed.seconds%60}s"
    if COUNTER_FAIL:
        color = Fore.RED
        msg = "Oh Oh! Regression tests failed."
    elif COUNTER_WARN:
        color = Fore.YELLOW
        msg = "All tests passed, but with warnings."
    else:
        color = Fore.GREEN
        msg = "Congratulations! All tests passed."
    print(color + BANNER)
    print(color + f"  {msg}")
    print(color + f"    TOTAL TESTS    : {COUNTER_TOTAL}")
    print(color + f"      Tests PASSED : {COUNTER_PASS}")
    print(color + f"      Tests WARNED : {COUNTER_WARN}")
    print(color + f"      Tests FAILED : {COUNTER_FAIL}")
    print(color + f"    End Time       : {end_time.strftime('%Y-%m-%d %H:%M:%S')}")
    print(color + f"    Elapsed Time   : {elapsed_fmt}")
    print(color + BANNER + Style.RESET_ALL)

# Main test sequence
def Main():
    pco_common.pcoInit()
    invocationArguments = pco_common.ParseArgs("regression-test.py", "0.9.0d", "Project regression test runner for ESPHome-based device management.")
    start_time = datetime.now()
    printStartBanner()

    # Required files
    runTest(f"test -f {pco_common.VERSION_FILE}", "Version file exists")
    runTest(f"test -f {pco_common.SECRETS_FILE}", "Secrets  file exists")

    # YAML validation
    for yf in pco_common.YAML_FILES:
        runTest(f"yamllint {yf}", f"YAML validation: {yf} (yamllint)")

    # Utility targets
    for t in UTILITY_TARGETS:
        runTest(f"make {t}", f"make {t}")

    # Docs targets
    for t in DOC_TARGETS:
        runTest(f"make {t}", f"make {t}")

    # Build/clean per variant
    for v in pco_common.VARIANTS:
        for t in BUILD_TARGETS:
            runTest(f"make {t} VARIANT={v}", f"Variant {v} - make {t}")
        for t in CLEAN_TARGETS:
            runTest(f"make {t} VARIANT={v}", f"Variant {v} - make {t}")

    # Clobber targets
    for t in CLOBBER_TARGETS:
        runTest(f"make {t}", f"make {t}")

    printSummaryBanner(start_time)

    sys.exit(0 if COUNTER_FAIL == 0 else 1)

if __name__ == "__main__":
    Main()
