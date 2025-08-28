#!/usr/bin/env python3
# ==============================================================================
#  File:          pco-header.py
#  File Type:     Python Script
#  Purpose:       Analyze source header files for standards conformance
#  Version:       0.9.0d
#  Date:          2025-08-06
#  Author:        Roland Tembo Hendel <rhendel@nexuslogic.com>
#
#  Description:   Validates project file headers according to a strict schema.
#                 Enforces header field order, required/optional fields, blank
#                 line rules, and field-specific validation. Supports multiline,
#                 indented fields for specified schema fields. Provides clear,
#                 accurate error messages with correct 1-based line numbers.
#                 Fast, portable, and can scan single files or directories.
#                 Easily extensible: add field-specific validation by supplying
#                 a function in the schema.
#
#  Features:      - Enforces header field order, required/optional fields, blank
#                   line rules, and field-specific validation
#                 - Supports multiline, indented fields for specified schema
#                   fields
#                 - Provides clear, accurate error messages with correct 1-based
#                   line numbers
#                 - Fast, portable, and can scan single files or directories
#                 - Easily extensible: add field-specific validation by
#                   supplying a function in the schema
#
#  Usage:         pco-header.py [options]
#                   Options:
#                     -h, --help       Show this help message and exit
#                     -v, --version    Show script version and exit
#                   Example:
#                     pco-header.py somefile
#
#  License:      GNU General Public License v3.0
#                SPDX-License-Identifier: GPL-3.0-or-later
#  Copyright:    (c) 2025 Roland Tembo Hendel
#                This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License.
# ==============================================================================


import re
import sys
import os
import traceback
from   pathlib import Path
from   enum import Enum, auto
import pco_common


# -------------------------------------------------------------------------------
# Definitions, Declarations, Constants and Globals
# -------------------------------------------------------------------------------

# script description, required for all PCO scripts
PCO_DESCRIPTION = "Source File Header Conformance Validation"

# validation constants
MAX_HEADER_LINES = 80
# Maximum lines to read from any file (header + a bit of body for context)

MAX_FILE_READ_LINES = 160


# -------------------------------------------------------------------------------
# Header Line Format Validation
# -------------------------------------------------------------------------------
def ValidateHeaderLineFormat(line, lineNum, allow_blank=False):
    if '\t' in line:
        raise HeaderCheckError(f"Line {lineNum}: Tabs are forbidden; use spaces only.")
    if line.rstrip() != line:
        raise HeaderCheckError(f"Line {lineNum}: Trailing whitespace is forbidden.")
    if len(line) > 80:
        raise HeaderCheckError(f"Line {lineNum}: Line exceeds 80 characters.")
        if allow_blank:
            if line not in ("#", "//"):
                raise HeaderCheckError(
                    f"Line {lineNum}: Blank separator must be exactly a single hash (#) or double slash (//) with no trailing whitespace."
                ) 

def IsFieldLine(line, delimiter_style):
    FieldNames = [
        "File", "File Type", "Purpose", "Version", "Date", "Author",
        "Description", "Features", "Usage", "Note", "WARNING", "License", "Copyright"
    ]
    if delimiter_style == '//':
        Pattern = r"^//  (" + "|".join(re.escape(Name) for Name in FieldNames) + "):"
    else:
        Pattern = r"^#  (" + "|".join(re.escape(Name) for Name in FieldNames) + "):"
    match = re.match(Pattern, line)
    if match:
        if len(line) < 18:
            raise HeaderCheckError(f"Field value must start at column 18 (after 17 chars)")
    return bool(match)

def IsIndentedLine(line, delimiter_style):
    if delimiter_style == '//':
        return line.startswith("//               ")
    else:
        return line.startswith("#                ")

# -------------------------------------------------------------------------------
# Field-Specific Validation Functions
# - these must be declared *before* the Schema Table is defined, because Python
#   is not a real programming language
# -------------------------------------------------------------------------------
def ValidateFileField(line, filename, lineNum):
    match = re.match(r'^(#|//)\s{2}File:\s*(.*)$', line) 
    if not match:
        raise HeaderCheckError(f"{filename}: Line {lineNum}: Malformed File: field: {line}")
    fileField = match.group(2).strip()
    base = os.path.basename(filename)
    if fileField != base:
        raise HeaderCheckError(f"{filename}: Line {lineNum}: File: field value '{fileField}' does not match filename '{base}'")

def ValidateFileTypeField(line, filename, lineNum):
    match = re.match(r'^(#|//)\s{2}File Type:\s*(.*)$', line) 
    if not match:
        raise HeaderCheckError(f"{filename}: Line {lineNum}: Malformed File Type: field: {line}")
    fileType = match.group(2).strip()
    allowedTypes = {
        "Makefile",
        "YAML File",
        "C Header File"
        "C Source File",
        "C++ Header File",
        "C++ Source File",
        "Python Script",
        "Shell Script",
        # Add more allowed types as needed
    }
    if fileType not in allowedTypes:
        raise HeaderCheckError(
            f"{filename}: Line {lineNum}: Invalid File Type: '{fileType}'. Allowed types: {', '.join(sorted(allowedTypes))}"
    )
    # Infer actual file type from filename/extension
    base = os.path.basename(filename)
    ext = os.path.splitext(base)[1].lower()
    actualType = None
    if base == "Makefile" or ext == ".mk":
        actualType = "Makefile"
    elif ext == ".py":
        actualType = "Python Script"
    elif ext == ".sh":
        actualType = "Shell Script"
    elif ext in (".yaml", ".yml"):
        actualType = "YAML File"
    elif ext == ".md":
        actualType = "Markdown"
    # Add more mappings as needed
    if actualType and fileType != actualType:
        raise HeaderCheckError(
            f"{filename}: Line {lineNum}: File Type mismatch: header says '{fileType}', but file appears to be '{actualType}'"
    )

def ValidateVersionField(line, filename, lineNum):
    match = re.match(r'^(#|//)\s{2}Version:\s*(.*)$', line) 
    if not match:
        raise HeaderCheckError(f"{filename}: Line {lineNum}: Malformed Version: field: {line}")
    versionField = match.group(2).strip()
    # Always use the workspace root (sandbox) as project root
    # Find the directory containing this script, then its parent (sandbox)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    projectRoot = os.path.dirname(script_dir)
    versionFile = os.path.join(projectRoot, "VERSION")
    if not os.path.isfile(versionFile):
        raise HeaderCheckError(f"{filename}: Line {lineNum}: VERSION file not found at {versionFile}")
    with open(versionFile, "r", encoding="utf-8") as vf:
        versionActual = vf.readline().strip()
    if versionField != versionActual:
        raise HeaderCheckError(
            f"{filename}: Line {lineNum}: Version field '{versionField}' does not match project VERSION '{versionActual}'"
        )

def ValidateLicenseField(line, filename, lineNum):
    # Must match exactly the License block specified in STANDARDS.md.
    required_lines = [
        "#  License:      GNU General Public License v3.0",
        "#                SPDX-License-Identifier: GPL-3.0-or-later",
        "//  License:      GNU General Public License v3.0",
        "//                SPDX-License-Identifier: GPL-3.0-or-later"
    ]
    # Accept either line as the start of the License block
    if line.strip() not in required_lines:
        raise HeaderCheckError(f"{filename}: Line {lineNum}: License field does not match required text")

def ValidateCopyrightField(line, filename, lineNum):
    # Must match exactly the Copyright block specified in STANDARDS.md.
    required_lines = [
        "#  Copyright:    (c) 2025 Roland Tembo Hendel",
        "#                This program is free software: you can redistribute it and/or",
        "#                modify it under the terms of the GNU General Public License.",
        "//  Copyright:    (c) 2025 Roland Tembo Hendel",
        "//                This program is free software: you can redistribute it and/or",
        "//                modify it under the terms of the GNU General Public License."
    ]
    if line.strip() not in required_lines:
        raise HeaderCheckError(f"{filename}: Line {lineNum}: Copyright field does not match required text")


# -------------------------------------------------------------------------------
#  HEADER_SCHEMA: List of tuples defining the header fields and their properties.
#
#    Each tuple:
#        field_name: str,           # Field name (e.g., 'File')
#        regex: re.Pattern,         # Regex to match field line
#        required: bool,            # True if field is required
#        multiline: bool,           # True if field supports multiline/indented
#        blank_after: int,          # 1 if blank line required after, else 0
#        validator: function|None   # Field-specific validation function or None
#    Example:
#        "File", re.compile(r'^(#|//)\s*$'  File:.*"), True, False, 0, validate_file_field
#
HEADER_SCHEMA = [
    ("File",        re.compile(r"^(#|//)  File:.*"),         True,  False, 0, ValidateFileField),
    ("File Type",   re.compile(r"^(#|//)  File Type:.*"),    True,  False, 0, ValidateFileTypeField),
    ("Purpose",     re.compile(r"^(#|//)  Purpose:.*"),      True,  True,  0, None),
    ("Version",     re.compile(r"^(#|//)  Version:.*"),      True,  False, 0, ValidateVersionField),
    ("Date",        re.compile(r"^(#|//)  Date:.*"),         True,  True,  0, None),
    ("Author",      re.compile(r"^(#|//)  Author:.*"),       True,  True,  1, None),
    ("Description", re.compile(r"^(#|//)  Description:.*"),  False, True,  1, None),
    ("Features",    re.compile(r"^(#|//)  Features:.*"),     False, True,  1, None),
    ("Usage",       re.compile(r"^(#|//)  Usage:.*"),        False, True,  1, None),
    ("Note",        re.compile(r"^(#|//)  Note:.*"),         False, True,  1, None),
    ("WARNING",     re.compile(r"^(#|//)  WARNING:.*"),      False, True,  1, None),
    ("License",     re.compile(r"^(#|//)  License:.*"),      True,  True,  0, ValidateLicenseField),
    ("Copyright",   re.compile(r"^(#|//)  Copyright:.*"),    True,  True,  0, ValidateCopyrightField),
]


# ------------------------------------------------------------------------------
#  State Machine Implementation
# ------------------------------------------------------------------------------
#  States:
#    parseStartDelimiter   - Look for the header start delimiter
#    parseField            - Parse and validate a header field line
#    parseMultline         - Consume multiline/indented lines for a field
#    parseSeparator        - Expect and validate a blank separator line
#    parseEndDelimiter     - Look for the header end delimiter
#    error                 - Handle any error, print and exit
#    done                  - Successfully finished parsing
#
#  State Transition Table:
#    Current State                Input/Condition                Next State
#    ---------------------------------------------------------------------------
#    parseStartDelimiter   Found start delimiter              parseField
#    parseStartDelimiter   Not found, EOF or error            error
#    parseField            Field multiline                    parseMultline
#    parseField            Field not multiline, needs blank   parseSeparator
#    parseField            Field not multiline, no blank      parseField
#    parseField            End delimiter                      parseEndDelimiter
#    parseField            Error                              error
#    parseMultline         More indented lines                parseMultline
#    parseMultline         End of multiline, needs blank      parseSeparator
#    parseMultline         End of multiline, no blank         parseField
#    parseMultline         End delimiter                      parseEndDelimiter
#    parseMultline         Error                              error
#    parseSeparator        Found blank line                   parseField
#    parseSeparator        Not found or error                 error
#    parseEndDelimiter     Found end delimiter                done
#    parseEndDelimiter     Not found or error                 error
#    done                  -                                  (exit success)
#    error                 -                                  (exit fail)
#
class State(Enum):
    ParseStartDelimiter = auto()
    ParseField          = auto()
    ParseMultline       = auto()
    ParseSeparator      = auto()
    ParseEndDelimiter   = auto()
    Error               = auto()
    Done                = auto()


# ---------------------------------------------------------------------------
#  StateMachine
# ---------------------------------------------------------------------------
#  Purpose:
#    Validates the header of a source file against the HEADER_SCHEMA using a
#    robust state machine. Ensures all required fields, order, multiline and
#    blank line rules, and field-specific validation are enforced.
#
#  Arguments:
#    header_lines         List of header lines (strings) to validate.
#    header_line_numbers  List of corresponding 1-based line numbers.
#    filename             Name of the file being checked (for error reporting).
#
#  Operation:
#    - Initializes a context object with parsing state and pointers.
#    - Runs a state machine loop, dispatching to handler functions for each
#      parsing state (start delimiter, field, multiline, separator, end delimiter).
#    - Each handler validates the current line(s), updates context, and returns
#      the next state.
#    - On error, prints a detailed message and exits via pco_common utilities.
#    - On success, parsing completes with no errors.
#
#  Returns:
#    None. Exits on error. On success, parsing completes and returns to caller.
#
def StateMachine(HeaderLines, HeaderLineNumbers, Filename):
    ctx = {
        'headerLines': HeaderLines,
        'headerLineNumbers': HeaderLineNumbers,
        'filename': Filename,
        'idx': 0,
        'hlen': len(HeaderLines),
        'schemaIdx': 0,
        'lastBlank': False,
        'prevBlankIdx': None,
        'delimiter': '// ' + '=' * 77 if str(Filename).endswith(('.h', '.hpp', '.cpp', '.c')) else '# ' + '=' * 78,
        'state': State.ParseStartDelimiter,
        'error': None,
    }
    stateFunctions = {
        State.ParseStartDelimiter: ParseStartDelimiter,
        State.ParseField: ParseField,
        State.ParseMultline: ParseMultline,
        State.ParseSeparator: ParseSeparator,
        State.ParseEndDelimiter: ParseEndDelimiter,
        State.Error: ErrorHandler,
        State.Done: DoneHandler,
    }
    while True:
        func = stateFunctions[ctx['state']]
        nextState = func(ctx)
        if nextState is not None:
            ctx['state'] = nextState
        if ctx['state'] in (State.Done, State.Error):
            break
    if ctx['state'] == State.Error:
        raise HeaderCheckError(ctx['error'])


# -------------------------------------------------------------------------------
# State Machine Function Implementations
# -------------------------------------------------------------------------------
# Each state handler function (smFunctionParseStartDelimiter, smFunctionParseField,
# smFunctionParseMultline, smFunctionParseSeparator, smFunctionParseEndDelimiter,
# smFunctionError, smFunctionDone) is responsible for:
#   - Examining the current context (ctx) and the relevant line(s) of the header.
#   - Performing validation and updating the context (e.g., advancing idx, schema_idx,
#     tracking blank lines).
#   - Returning the next state (as a state enum value) to drive the state machine.
#
# General responsibilities:
# - smFunctionParseStartDelimiter: Find and validate the header start delimiter. On success,
#   advance to the first field; on failure, transition to error.
# - smFunctionParseField: Match the current line to the expected schema field, validate, and
#   determine if multiline or blank separator is needed. Handles end delimiter detection.
# - smFunctionParseMultline: Consume and validate all indented/multiline lines for the current
#   field. Decide if a blank separator or next field is expected.
# - smFunctionParseSeparator: Ensure a required blank line follows the previous field. On success,
#   advance to the next field.
# - smFunctionParseEndDelimiter: Validate the header end delimiter. On success, transition to done;
#   on failure, to error.
# - smFunctionError: Print error and exit.
# - smFunctionDone: Parsing complete; exit successfully.
#
# Each handler must:
# - Use only the context object for state and data.
# - Use reporting utilities from pco_common.py for all output.
# - Return the next state or None (to stay in the same state).
#
def ParseStartDelimiter(Ctx):
    idx = Ctx['idx']
    hlen = Ctx['hlen']
    headerLines = Ctx['headerLines']
    headerLineNumbers = Ctx['headerLineNumbers']
    delimiter = Ctx['delimiter']
    if idx < hlen and headerLines[idx].rstrip() == delimiter:
        Ctx['idx'] += 1
        Ctx['state'] = State.ParseField
        return State.ParseField
    else:
        Ctx['error'] = f"Line {headerLineNumbers[idx] if idx < hlen else '?'}: Missing or malformed header start delimiter."
        return State.Error

def ParseField(Ctx):
    idx = Ctx['idx']
    hlen = Ctx['hlen']
    schemaIdx = Ctx['schemaIdx']
    headerLines = Ctx['headerLines']
    headerLineNumbers = Ctx['headerLineNumbers']
    delimiter = Ctx['delimiter']
    delimiter_style = '//' if str(Ctx['filename']).endswith(('.h', '.hpp', '.cpp', '.c')) else '#'


    if idx >= hlen:
        Ctx['error'] = f"{Ctx['filename']}: Line {headerLineNumbers[-1] if headerLineNumbers else '?'}: Unexpected end of header while expecting field."
        return State.Error
    line = headerLines[idx]
    lineNum = headerLineNumbers[idx]
    if line.rstrip() == delimiter:
        return State.ParseEndDelimiter
    if schemaIdx >= len(HEADER_SCHEMA):
        Ctx['error'] = f"{Ctx['filename']}: Line {lineNum}: Extra lines found after expected header fields."
        return State.Error
    field, regex, required, multiline, blankAfter, validator = HEADER_SCHEMA[schemaIdx]
    while not regex.match(line):
        if not required:
            Ctx['schemaIdx'] += 1
            if Ctx['schemaIdx'] >= len(HEADER_SCHEMA):
                Ctx['error'] = f"{Ctx['filename']}: Line {lineNum}: Extra lines found after expected header fields."
                return State.Error
            field, regex, required, multiline, blankAfter, validator = HEADER_SCHEMA[Ctx['schemaIdx']]
            continue
        if IsFieldLine(line, delimiter_style):
            Ctx['error'] = f"{Ctx['filename']}: Line {lineNum}: Expected field '{field}' but got: {line}"
        else:
            Ctx['error'] = f"{Ctx['filename']}: Line {lineNum}: Unknown or misspelled header field: {line}"
        return State.Error
    # Enforce header line format for field lines
    ValidateHeaderLineFormat(line, lineNum)
    if validator:
        validator(line, Ctx['filename'], lineNum)
    Ctx['idx'] += 1
    if multiline:
        return State.ParseMultline
    if blankAfter:
        return State.ParseSeparator
    Ctx['schemaIdx'] += 1
    return State.ParseField

def ParseMultline(Ctx):
    idx = Ctx['idx']
    hlen = Ctx['hlen']
    schemaIdx = Ctx['schemaIdx']
    headerLines = Ctx['headerLines']
    headerLineNumbers = Ctx['headerLineNumbers']
    delimiter = Ctx['delimiter']
    delimiter_style = '//' if str(Ctx['filename']).endswith(('.h', '.hpp', '.cpp', '.c')) else '#'
    field, regex, required, multiline, blankAfter, validator = HEADER_SCHEMA[schemaIdx]
    found_indented = False

    while idx < hlen:
        line = headerLines[idx]
        lineNum = headerLineNumbers[idx]
        # End delimiter: finish header
        if line.rstrip() == delimiter:
            Ctx['idx'] = idx
            return State.ParseEndDelimiter
        # Blank separator after multiline field
        blank_pattern = r'^' + re.escape(delimiter_style) + r'\s*$'
        if blankAfter and re.match(blank_pattern, line):
            Ctx['idx'] = idx
            return State.ParseSeparator
        # Next field (not multiline, no blank required)
        if not blankAfter and IsFieldLine(line, delimiter_style):
            Ctx['idx'] = idx
            Ctx['schemaIdx'] += 1
            return State.ParseField
        # Multiline continuation
        if IsIndentedLine(line, delimiter_style):
            ValidateHeaderLineFormat(line, lineNum)
            idx += 1
            found_indented = True
            continue
        # If no indented lines found, error
        if not found_indented:
            Ctx['error'] = f"{Ctx['filename']}: Line {lineNum}: Expected indented multiline continuation for field '{field}', got: {line}"
            return State.Error
        # If we get here, line is malformed
        Ctx['error'] = f"{Ctx['filename']}: Line {lineNum}: Malformed multiline continuation for field '{field}': {line}"
        return State.Error
    # If we run out of lines
    Ctx['error'] = f"{Ctx['filename']}: Line {headerLineNumbers[-1] if headerLineNumbers else '?'}: Unexpected end of header in multiline field '{field}'."
    return State.Error

def ParseSeparator(Ctx):
    idx = Ctx['idx']
    hlen = Ctx['hlen']
    headerLines = Ctx['headerLines']
    headerLineNumbers = Ctx['headerLineNumbers']
    schemaIdx = Ctx['schemaIdx']
    delimiter_style = '//' if str(Ctx['filename']).endswith(('.h', '.hpp', '.cpp', '.c')) else '#'
    blank_pattern = r'^' + re.escape(delimiter_style) + r'\s*$'

    if idx < hlen and re.match(blank_pattern, headerLines[idx]):
        ValidateHeaderLineFormat(headerLines[idx], headerLineNumbers[idx], allow_blank=True)
        Ctx['idx'] += 1
        Ctx['lastBlank'] = True
        Ctx['prevBlankIdx'] = idx
        Ctx['schemaIdx'] += 1
        return State.ParseField
    else:
        ln = headerLineNumbers[idx] if idx < hlen else (headerLineNumbers[-1] if headerLineNumbers else '?')
        field = HEADER_SCHEMA[schemaIdx][0]
        Ctx['error'] = f"{Ctx['filename']}: Line {ln}: Missing required blank comment line after field '{field}'"
        return State.Error

def ParseEndDelimiter(Ctx):
    idx = Ctx['idx']
    hlen = Ctx['hlen']
    headerLines = Ctx['headerLines']
    headerLineNumbers = Ctx['headerLineNumbers']
    delimiter = Ctx['delimiter']
    if idx < hlen and headerLines[idx].rstrip() == delimiter:
        Ctx['idx'] += 1
        return State.Done
    else:
        Ctx['error'] = f"{Ctx['filename']}: Could not find matching end delimiter"
        return State.Error

def ErrorHandler(Ctx):
    raise HeaderCheckError(Ctx['error'])

def DoneHandler(Ctx):
    return None


# -------------------------------------------------------------------------------
# Utility Functions
# -------------------------------------------------------------------------------

def FindHeaderStart(Lines, Filename):
    Idx = 0

    if str(Filename).endswith(('.h', '.hpp', '.cpp', '.c')):
        Delimiter = '// ' + '=' * 77 + '\n'
    else:
        Delimiter = '# ' + '=' * 78 + '\n'

    while Idx < len(Lines):
        Line = Lines[Idx]
        if Line.startswith('#!') or Line.strip() == '---':
            Idx += 1
            continue
        if Line == Delimiter:
            return Idx
        else:
            raise HeaderCheckError(f"{Filename}: Could not find matching start delimiter")
    raise HeaderCheckError(f"{Filename}: Could not find matching start delimiter")

def ParseHeaderBlock(Lines, Filename):
    StartIdx = FindHeaderStart(Lines, Filename)
    Header = []
    HeaderLineNumbers = []

    if str(Filename).endswith(('.h', '.hpp', '.cpp', '.c')):
        Delimiter = '// ' + '=' * 77 + '\n'
    else:
        Delimiter = '# ' + '=' * 78 + '\n'


    for I, Line in enumerate(Lines[StartIdx : StartIdx + 1 + MAX_HEADER_LINES], start=StartIdx):
        Header.append(Line.rstrip('\n'))
        HeaderLineNumbers.append(I + 1)  # 1-based line number
        if Line.rstrip('\n') == Delimiter and I != StartIdx:
            break
    return Header, HeaderLineNumbers

# Custom Exceptions for Header Checking
class HeaderCheckError(Exception):
    pass

class HeaderCheckWarn(Exception):
    pass


# -------------------------------------------------------------------------------
# Main Entry Point
# -------------------------------------------------------------------------------
def Main():

    # initialize counters
    TotalFiles = 0
    Passed     = 0
    Failed     = 0
    Warnings   = 0

    try:
        # initiailize PCO common module
        pco_common.pcoInit()  # Populate YAML_FILES, CPP_FILES, SCRIPT_FILES, MAKEFILES, ALL_FILES

        # parse CLAs
        Args = pco_common.ParseArgs("pco-header.py", "1.0", PCO_DESCRIPTION)
        if Args.filelist:
            Files = [Path(F) for F in Args.filelist]
        else:
            # applies to all project file types except markdown files
            Files = [Path(F) for F in pco_common.MAKEFILES + pco_common.YAML_FILES + pco_common.CPP_FILES + pco_common.PYTHON_SCRIPTS + pco_common.BASH_SCRIPTS]

        if len(Files) > 1:
            pco_common.PrintBanner(PCO_DESCRIPTION)

        for Filename in Files:
            TotalFiles += 1
            try:
                with open(Filename, encoding='utf-8') as F:
                    Lines = [Line for _, Line in zip(range(MAX_FILE_READ_LINES), F)]
                Header, HeaderLineNumbers = ParseHeaderBlock(Lines, Filename)
                StateMachine(Header, HeaderLineNumbers, Filename)
                pco_common.PrintPass(f"{Filename}")
                Passed += 1
            except HeaderCheckWarn as W:
                pco_common.PrintWarn(f"{Filename}: {W}")
                Warnings += 1
            except HeaderCheckError as E:
                pco_common.PrintFail(f"{Filename}: {E}")
                Failed += 1
            except Exception as E:
                pco_common.PrintFail(f"{Filename}: [FATAL] {type(E).__name__}: {E}")
                traceback.print_exc()
                Failed += 1

        if len(Files) > 1:
            pco_common.PrintSummary(TotalFiles, Passed, Failed, Warnings)

        if Failed == 0:
            sys.exit(0)
        else:
            sys.exit(1)
    except Exception as E:
        pco_common.PrintFail(f"[FATAL] {type(E).__name__}: {E}")
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    Main()
