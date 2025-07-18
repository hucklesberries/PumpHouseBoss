# Check-in Quick Reference

## Pre-Commit Commands
```bash
# 1. Clean build validation
make clean && make build

# 2. Version consistency check  
grep "version.*0\." Makefile VERSION

# 3. Documentation test
make help && make docs

# 4. Archive readiness test
make distclean && git status

# 5. Gitignore validation
git status --ignored --porcelain | grep "^!!" | head -5
```

## Commit Message Template
```
feat: Add session-based logging system

Enhanced logging workflow with timestamp-based session management:
- Added logs-fresh target for clean session-specific logs
- Implemented background process management with automatic cleanup
- Created symlink system for easy log access
- Updated help system with new logging workflow

Hardware tested: ESP32-S3 DevKitC-1
Components: logging, watchdog
Version: 0.4.0
```

## Post-Commit Updates
- [ ] Update `GIT-COPILOT.md` technical context  
- [ ] Update `CHANGELOG.md` with version entry
- [ ] Verify `make distclean` produces clean workspace

---
📋 **Full checklist**: See `CHECKIN-CHECKLIST.md`
