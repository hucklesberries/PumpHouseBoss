# STANDARDS.md — Project Conventions & Coding Standards

> This document defines the conventions, standards, and best practices for all contributors to the PumpHouseBoss project. Adhering to these standards ensures code quality, maintainability, and a consistent developer experience.

---

## Table of Contents
- [General Principles](#general-principles)
- [File Headers](#file-headers)
- [Shell Scripting](#shell-scripting)
- [Makefile Conventions](#makefile-conventions)
- [Documentation](#documentation)
- [Versioning](#versioning)
- [Session Continuity](#session-continuity)
- [Line Endings](#line-endings)
- [Commit Messages](#commit-messages)

---

## General Principles
- Write clear, maintainable, and well-documented code.
- Prefer explicitness and readability over cleverness.
- All code and documentation must be licensed under GPL v3.0 or later.

## File Headers
- Every source/script file must begin with the standard project header, including:
  - File name, type, purpose, version, date, author
  - Description, features, usage, license, copyright
- See `regression-test.sh` for a canonical example.

## Shell Scripting
- Use `#!/usr/bin/env bash` as the shebang for all Bash scripts.
- **Strict Mode:** Use `set -u` (treat unset variables as errors), `set -e` (exit on error), and `set -o pipefail` (fail pipelines if any command fails) at the top of all scripts unless there is a documented reason not to. If you must omit `-e` (e.g., for scripts with background jobs), document this in the script header.
- **Quoting Variables:** Quote all variable expansions, e.g., `"${VAR}"`, to prevent word splitting and globbing issues. This applies to all shell scripts and Makefile recipes.
- Use ALL_CAPS for variable names.
- Indent shell code within Makefile recipes for readability.
- Use colorized output only if the terminal supports it.
- Always clean up background processes on exit or interruption.
- Log output to a file as well as stdout when appropriate.

## Makefile Conventions
- Use phony targets for all non-file targets.
- Group related targets (build, docs, clean, etc.) and document them.
- Use variables for directories and file lists.
- Indent shell code in recipes for human readability.

## Documentation

- All documentation files must use Unix (LF) line endings.
- Use Markdown for all documentation (`.md` files).
- Keep `README.md` up to date with project overview and setup instructions.
- Use `GIT-COPILOT.md` for session context and developer continuity.
- Extract YAML module/file descriptions to Markdown using `docs/extract_yaml_headers.py`.

### Markdown Formatting & Line Spacing

- Use one blank line after headings and between paragraphs or list blocks.
- Do not add extra blank lines within lists or between list items.
- Do not add blank lines before or after code blocks inside lists.
- Use one blank line before and after code blocks that are not inside a list.
- Keep Markdown formatting consistent for readability and proper rendering.

## Versioning
- Keep the `VERSION` file and Makefile version in sync.
- Update version strings in headers and documentation as part of the release process.
- Do not update the version in `main.yaml` unless specifically requested.

## Session Continuity
- Use the `.kibo` file in your home directory (`~/.kibo`) for session continuity and shared context across workspaces.
- Do not use `.git-copilot` or `.git-copilot.md` for continuity—use `.kibo` exclusively.
- Ensure `.kibo` is listed in `.gitignore`.


## Line Endings & Indentation
- All files must use Unix (LF) line endings. Do not use Windows (CRLF).
- Indentation must use spaces, not tabs. Tabs should be expanded to 4 spaces.
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

## File Permissions
- All executable scripts (e.g., Bash, Python) must be committed with executable permissions (`chmod 755` or `chmod +x`).
- Data files, documentation, and configuration files should not be executable (use `chmod 644`).
- Do not commit files as world-writable (no `chmod 777`).
- Use `git update-index --chmod=+x <file>` to set executable bit in git if needed.
- Always check file permissions before committing new or modified files.

## Check-in Procedure
- Before committing code or documentation, contributors must:
  1. Clear all checkmarks in the checklist file (`DISPOSITION.md`) if starting a new release or check-in cycle. Check off items as you complete them on this list.
  2. Review all file headers for accuracy and consistency.
  3. Ensure all files contain the correct version string (see `checkin.sh`).
  4. Ensure all tabs and indentation are consistent with project standards (see Line Endings & Indentation section).
  5. Ensure all shell scripts and Makefiles follow variable naming, quoting, and strict mode standards (see above).
  6. Ensure there are no trailing spaces and that all end-of-lines are UNIX format (unless explicitly indicated otherwise).
  7. Ensure all repo files have correct permissions.
  8. Run a spellcheck on all source and documentation files. Correct any spelling errors in code comments, documentation, and user-facing strings.
  9. Run the `regression-test.sh` script and ensure all tests pass. Resolve any failures.
 10. Review `.gitignore` and use `git status` to ensure that no unwanted files are staged for commit or left untracked.
 11. Update and review the `README.md`, `TODO.md`, and `GIT-COPILOT.md` files with all relevant changes since the previous version was checked in.
 12. For every significant change, add a new entry to `CHANGELOG.md` describing the update.
 13. Update the repository file tree in `README.md`.
 14. If this is a release, tag the commit appropriately and follow the project release process.
 15. All code changes must be reviewed and approved by at least one other contributor before merging.
 16. Update and review the checklist in `CHECKIN-CHECKLIST.md` to ensure that all items are checked off—provide a detailed explanation if any remain unchecked.

## Commit Messages
- Use structured commit messages:
  - Short summary (max 72 chars)
  - Blank line
  - Detailed description (if needed)
- Reference related issues or action items when appropriate.

---

*This document is maintained by GitHub Copilot and the project maintainers. Please propose updates as standards evolve.*
