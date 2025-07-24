
# ESPHome Project Check-in Checklist (Consolidated)

## 1. Pre-Commit: Workspace & Code Validation
```bash
# Run regression tests
./regression-test.sh
# Archive readiness & git status
make distclean && git status
# Version consistency check (search all files, exclude .git and ignored/generated files)
grep -r --exclude-dir=.git --exclude-dir=config --exclude=common/secrets.yaml --exclude=regression-test.log --exclude=*.log --color -i '0.6.7' .
# Show all ignored files
git status --ignored -s
```
- [ ] All headers: version/license/attribution consistent
- [ ] All version references match VERSION file (0.6.7)
- [ ] Code style, docs, and formatting standards met
- [ ] Clean build: `make clean && make build` passes
- [ ] No build warnings/errors
- [ ] Device YAML generates from main.yaml
- [ ] All dependencies/components load
- [ ] `make help` and `make docs` succeed
- [ ] Regression test passes, logs clean
- [ ] Hardware/component/OTA tests (if changed)
- [ ] README.md, CHANGELOG.md, help/docs updated
- [ ] Repository file tree in README.md updated
- [ ] No secrets or generated/log files in commit
- [ ] .gitignore covers all generated/log files
- [ ] File permissions normalized

## 2. Commit
- Use clear, conventional commit message:
  ```
  feat|fix|docs|style|refactor|test|chore: Brief description
  - Details of changes
  - Hardware tested: [ESP32-S3 DevKitC-1 | None | Other]
  - Components: [logging, watchdog, ...]
  - Version: X.Y.Z
  ```

## 3. Post-Commit
- [ ] Update `GIT-COPILOT.md` technical context
- [ ] Update `CHANGELOG.md` with version entry
- [ ] Verify `make distclean` produces clean workspace
- [ ] Confirm fresh clone builds and all dependencies are documented

## 4. Reset for Next Cycle
- [ ] Clear all checkboxes above
- [ ] Update checklist version entry in history table
- [ ] Stage/commit checklist reset
- [ ] Bump VERSION/Makefile for next cycle
- [ ] Fresh build: `make configure && make build`
- [ ] `make help` and `make version` reflect new version

## 5. Emergency Rollback
If build breaks after commit:
1. `git revert HEAD` to undo last commit
2. `make clean && make build` to debug
3. Commit fix with `fix:` prefix
4. Update checklist if new failure mode found

---
## Checklist History
| Version | Date       | Changes|
|---------|------------|-------|
| 0.6.7   | 2025-07-23 | Consolidated, clarified, and streamlined checklist|
| 0.6.6   | 2025-07-22 | Checklist consolidated, version bump, post-check-in procedure|
| 0.5.0   | 2025-07-08 | Initial checklist creation|

---
**Remember**: Better to catch issues in the checklist than in production! 🎯
