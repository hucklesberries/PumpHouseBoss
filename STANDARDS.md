# STANDARDS.md — Project Conventions & Coding Standards

This document defines the conventions, standards, and best practices for all contributors to the PumpHouseBoss project. Adhering to these standards ensures code quality, maintainability, and a consistent developer experience.

For the purpose of this project, the following terms are defined:
- **project files:** Includes source files, build files, project configuration files, and documentation.
- **build files:** Includes source files, makefiles, and configuration files required for executing makefile targets.
- **source files:** Includes all files consisting of source code (i.e., C/C++, YAML, Python, and shell scripts).
- **documentation:** Includes files consisting of Markdown or HTML.

---


## Table of Contents
- [General Principles](#general-principles)
- [Project Files](#project-files)
- [Build Files](#build-files)
- [Makefiles](#makefiles)
- [Shell Scripts](#shell-scripts)
- [Markdown Files](#markdown-files)
- [Versioning](#versioning)
- [File Permissions](#file-permissions)
- [Check-in Procedure](#check-in-procedure)
- [Commit Messages](#commit-messages)
- [Session Continuity](#session-continuity)

---

## General Principles
- Write clear, maintainable, and well-documented code.
- Prioritize explicitness and readability over cleverness.
- All project files must be licensed under GPL v3.0 or later.


## Project Files

### Tabs and Indentation
- Indentation must use spaces, not tabs, Except for Makefiles, tabs should be expanded to 4 spaces.
- Configure your editor to display tabs as 4 spaces and to insert spaces when the Tab key is pressed.
- For VS Code, add the following to your workspace settings:
  ```json
     {
        "editor.tabSize": 4,
        "editor.insertSpaces": true,
        "files.eol": "\n"
    }
  ```
- For Vim, add to your `.vimrc`:
  ```vim
     set tabstop=4
     set shiftwidth=4
     set expandtab
     set fileformat=unix
  ```
- For Emacs, add to your `.emacs` or `.dir-locals.el`:
  ```elisp
     (setq-default indent-tabs-mode nil)
     (setq-default tab-width 4)
     (setq-default buffer-file-coding-system 'utf-8-unix)
  ```
*Note: Makefiles are required to use tabs for indentation, and as such are an exception to this rule.*

### Line Endings
- Files must use Unix (LF) line endings. Do not use Windows (CRLF).
- Lines should not include trailing whitespce.
- Lines should not end with trailing whitespace.

### Line Spacing
- Files should not start with empty lines, and should end with a single empty line.
- Major sections should be separated by two blank lines.
- Minor sections should be separated by a single blank line.


## Build Files
- Build files must begin with the standard project header, including in order:
  - **Required:** Name, Type, Purpose, Version, Date, Author
  - **Where Applicable:** Description, Features, Usage, Note, Caution
  - **Required:** License, Copyright
  See `Makefile` for a canonical example.
- Build files must include comprehensive inline documentation, including:
  - Inline documentation consists of comments and explanations within the code, scripts, or configuration files that clarify the purpose, logic, and usage of code sections (such as code blocks, function definitions, and logic groupings), functions, variables, and complex logic.
  - Use clear, concise comments to aid future maintainers and reviewers.
  -  Inline documentation should follow the conventions of the language or file type (e.g., `#` for shell scripts, `//` or `/* ... */` for C/C++, `#` for YAML, etc.).
- PascalCase is preferred for variable names (i.e., ThisIsAVariable).
- UPPER_SNAKE_CASE (also known as CONSTANT_CASE) is preferred for macros and definitions (i.e., THIS_IS_A_MACRO).
- **Note:** Build files include Makefiles and related configuration files required for building the project. Makefiles are a special type of build file and must follow both the general build file standards and the additional Makefile-specific standards below.


## Makefiles
Makefiles are a type of build file and must follow all build file standards in addition to the following Makefile-specific conventions:
- Use phony targets for all non-file targets.
- Prepend targets not meant for external use with an underscore ("_"). For example, use `_internal_target` for internal-only targets. This helps distinguish private/internal targets from those intended for public use.
- Group related targets (build, docs, clean, etc.) and document them.
- Use variables for directories and file lists.
- Indent shell code in recipes for human readability.
- **Quoting Variables:** Quote all variable expansions, e.g., "$(VAR)", to prevent word splitting and globbing issues.


## Shell Scripts
- Use `#!/usr/bin/env bash` as the shebang for all Bash scripts.
- **Strict Mode:** Use `set -u` (treat unset variables as errors), `set -e` (exit on error), and `set -o pipefail` (fail pipelines if any command fails) at the top of all scripts unless there is a documented reason not to. If you must omit `-e` (e.g., for scripts with background jobs), document this in the script header.
- **Quoting Variables:** Quote all variable expansions, e.g., `"${VAR}"`, to prevent word splitting and globbing issues.
- Use colorized output only if the terminal supports it.
- Always clean up background processes on exit or interruption.

### Markdown Files
- Use two blank lines before the start of major (##) sections/headers.
- Use one blank line before the start of minor (###...) sections/headers.
- Use one blank line between paragraphs or list blocks.
- Do not add extra blank lines within lists or between list items.
- Do not add blank lines before or after code blocks inside lists.
- Use one blank line before and after code blocks that are not inside a list.
- Keep Markdown formatting consistent for readability and proper rendering.


## Versioning
- Keep the `VERSION` file and Makefile version in sync.
- Update version strings in headers and documentation as part of the release process.


## File Permissions
- All executable scripts (e.g., Bash, Python) must be committed with executable permissions (`chmod 755` or `chmod +x`).
- Data files, documentation, and configuration files should not be executable (use `chmod 644`).
- Do not commit files as world-writable (no `chmod 777`).
- Use `git update-index --chmod=+x <file>` to set executable bit in git if needed.
- Always check file permissions before committing new or modified files.


## Check-in Procedure
- Before committing code or documentation, contributors must:
  - Conduct a peer review:
      - Request at least one other contributor to review all code and documentation changes before merging.
      - Reviewers should check for code quality, adherence to project standards, clarity, maintainability, and correctness.
      - Provide constructive feedback and suggest improvements where needed.
      - Ensure all comments and requested changes are addressed before approval.
      - Approve the changes only when all checklist items and standards are satisfied.
  - Perform all steps and clear all checkmarks in the checklist file (`RELEASE-CHECKLIST.md`).


## Commit Messages
- Use structured commit messages:
  - Short summary (max 72 chars)
  - Blank line
  - Detailed description (if needed)
- Reference related issues or action items when appropriate.


## Session Continuity
- Use `GIT-COPILOT.md` for session context and developer continuity.

---

*This document is maintained by GitHub Copilot and the project maintainers. Please propose updates as standards evolve.*
