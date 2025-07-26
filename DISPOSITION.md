# ESPHome Project Repository Disposition (Checklist)

## 1. Version & Branch
- [x] Version in `VERSION` file and Makefile is correct and in sync
- [x] Version strings updated in headers and documentation
- [x] Working on the correct branch for this release

## 2. Pre-Commit
- [ ] All source/script files have standard project header (file name, type, purpose, version, date, author)
- [ ] README.md up to date with project overview, setup, and file tree
- [ ] CHANGELOG.md and RELEASE.md updated with new version entry
- [ ] GIT-COPILOT.md updated for session context and developer continuity
- [ ] No secrets or generated/log files in commit
- [ ] .gitignore covers all generated/log files and `.kibo`
- [ ] All YAML module/file descriptions extracted to Markdown (if changed)
- [ ] All Makefile targets grouped, documented, and up to date
- [ ] All shell scripts and Makefile recipes quote variables properly
- [ ] All shell code in Makefile recipes is indented for readability
- [ ] All background processes are cleaned up on exit/interruption
- [ ] Log output is sent to file and stdout where appropriate
- [ ] All code and documentation linted/checked for standards compliance

## 3. Commit & Push
- [ ] Commit message follows standards (concise, descriptive, references issues if needed)
- [ ] All staged files are intentional and relevant to the commit
- [ ] Checklist items above are complete before commit
- [ ] Push to remote and verify branch is up to date

## 4. Post-Commit/Pre-Release
- [ ] `make distclean` produces a clean workspace
- [ ] Fresh clone builds successfully; all dependencies are documented
- [ ] Confirm `make help` and `make version` reflect new version
- [ ] Tag release if appropriate

## 5. Reset for Next Cycle
- [ ] Clear all checkboxes above
- [ ] Update checklist version entry in history table (if present)
- [ ] Stage/commit checklist reset
- [ ] Bump VERSION/Makefile for next cycle
- [ ] Fresh build: `make configure && make build`

**Remember:** Better to catch issues in the checklist than in production! 🎯
