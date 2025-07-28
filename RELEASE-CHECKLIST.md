# ESPHome Project Repository Disposition (Checklist)

## 1. Version & Branch
1.  [x] Version in `VERSION` file and Makefile is correct and in sync
2.  [x] Version strings updated in headers and documentation
3.  [x] Working on the correct branch for this release

## 2. Pre-Commit
1.  [x] Conduct a peer review: Request at least one other contributor to review all code and documentation changes before merging. Reviewers should check for code quality, adherence to project standards, clarity, maintainability, and correctness. Approve only when all checklist items and standards are satisfied.
2.  [x] Review all project files for standards compliance as described in STANDARDS.md. This includes:
    - [x] Tabs and indentation
    - [x] Line endings
    - [x] Line spacing
    - [x] File-type specific standards:
      - [x] Build Files
      - [x] Makefiles
      - [x] Shell Scripts
      - [x] Markdown Files
3.  [x] Upadte and validate all header files for standards conformance.
4.  [x] Ensure all files contain the correct version string.
5.  [x] Ensure all files have correct permissions.
6.  [x] Run a spellcheck on all source and documentation files. Correct any spelling errors in code comments, documentation, and user-facing strings.
7.  [x] Review `.gitignore` and use `git status` to ensure that no unwanted files are staged for commit or left untracked.
8.  [x] Update and review the `README.md`, `TODO.md`, and `GIT-COPILOT.md` files with all relevant changes since the previous version was checked in.
9.  [x] For every significant change, add a new entry to `CHANGELOG.md` describing the update.
10. [x] Update the repository file tree in `README.md`.
11. [x] Update the TOC in all documentation files.
12. [x] Validate links in documentation files.
13. [x] Run the `regression-test.sh` script and ensure all tests pass. Resolve any failures.
14. [x] If this is a release, tag the commit appropriately and follow the project release process.
15. [x] All code changes must be reviewed and approved by at least one other contributor before merging.

## 3. Commit & Push
1.  [ ] Commit message follows standards (concise, descriptive, references issues if needed)
2.  [ ] All staged files are intentional and relevant to the commit
3.  [ ] Checklist items above are complete before commit
4.  [ ] Push to remote and verify branch is up to date

## 4. Post-Commit/Pre-Release
1.  [ ] `make distclean` produces a clean workspace
2.  [ ] Fresh clone builds successfully; all dependencies are documented
3.  [ ] Confirm `make help` and `make version` reflect new version
4.  [ ] Tag release if appropriate

## 5. Reset for Next Cycle
1.  [ ] Clear all checkboxes above
2.  [ ] Update checklist version entry in history table (if present)
3.  [ ] Stage/commit checklist reset
4.  [ ] Bump VERSION/Makefile for next cycle
5.  [ ] Regression Test: `make regression-test`

**Remember:** Better to catch issues in the checklist than in production! 🎯
