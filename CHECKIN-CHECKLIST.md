# ESPHome Project Check-in Checklist

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
Version: 0.6.0
```

## Post-Commit Updates
- [ ] Update `GIT-COPILOT.md` technical context
- [ ] Update `CHANGELOG.md` with version entry
- [ ] Verify `make distclean` produces clean workspace

---
📋 **Full checklist below**

> **Reminder:** Before the next check-in, refine the project description and provide similar updates to all documentation for clarity and completeness.

### **Header Consistency Review**
- [ ] Review all headers in source files for version, license, and attribution consistency

### **Version Reference Update**
- [ ] Update all version references throughout the codebase to match VERSION file (0.6.0)

## Pre-Commit Validation

### **1. Code Quality & Standards**
- [x] **Version Consistency**: Makefile version matches `VERSION` file
- [x] **Professional Headers**: All new files have GPL v3.0 headers with proper attribution
- [x] **Documentation**: All functions/components have `@brief`, `@details`, `@author` comments
- [x] **Code Style**: Consistent formatting, proper indentation, clean spacing

### **2. Build System Validation**
- [x] **Clean Build**: `make clean && make build` completes successfully
- [x] **No Warnings**: Build process shows no compilation warnings or errors
- [x] **Generated Files**: Device YAML generates correctly from main.yaml template
- [x] **Dependencies**: All required components and packages load without errors

### **3. Testing & Verification**
- [x] **Hardware Test**: If hardware changes, verify on actual ESP32 device
- [x] **Component Test**: New components build and initialize correctly
- [x] **Log Validation**: Logging system produces clean, readable output
- [x] **OTA Test**: Over-the-air upload works (if network changes made)

### **4. Documentation Updates**
- [x] **README.md**: Updated with new features, requirements, or workflow changes
- [x] **CHANGELOG.md**: New entry documenting changes with version bump
- [x] **Help System**: `make help` reflects any new or changed targets
- [x] **Component Docs**: New components documented in `common/` directory

### **5. Repository Hygiene**
- [x] **File Permissions**: Normalized across repository (use `git add --chmod=644`)
- [x] **Secrets Check**: No secrets, credentials, or sensitive data in commit
- [x] **Generated Files**: Only commit source files, not generated device configs
- [x] **Log Files**: Ensure logs/ directory not committed (should be in .gitignore)
- [x] **Gitignore Updates**: Verify .gitignore covers new file types and patterns

### **6. Version Management**
- [x] **VERSION File**: Bumped appropriately (major.minor.patch)
- [x] **Makefile Header**: Version number updated to match VERSION file
- [x] **Component Versions**: Any component-specific versions updated
- [x] **Dependency Versions**: Document any new version requirements

## Commit Message Standards

### **Format**
```
feat|fix|docs|style|refactor|test|chore: Brief description

Detailed explanation of changes:
- Specific change 1
- Specific change 2
- Breaking changes (if any)

Hardware tested: [ESP32-S3 DevKitC-1 | None | Other]
Components: [watchdog, logging, flow-monitoring, etc.]
Version: X.Y.Z
```

### **Types**
- **feat**: New feature or enhancement
- **fix**: Bug fix or correction
- **docs**: Documentation updates only
- **style**: Code formatting, whitespace, etc.
- **refactor**: Code restructuring without functional changes
- **test**: Adding or updating tests
- **chore**: Maintenance, build system, etc.

## Post-Commit Validation

### **1. Continuity Check**
- [ ] **GIT-COPILOT.md**: Technical context maintained for AI continuity
- [ ] **Board Notes**: Hardware configuration documented in README.md

### **2. Archive Readiness**
- [ ] **Distclean Test**: `make distclean` produces clean, archivable workspace
- [ ] **Fresh Clone**: Project builds correctly from fresh git clone
- [ ] **Dependencies**: All external dependencies documented and available

## Post-Check-in Procedure

### **1. Reset Checklist for Next Development Cycle**
- [ ] Clear all checkboxes in pre-commit validation sections
- [ ] Update checklist version entry in history table
- [ ] Stage and commit checklist reset

### **2. Version Management for Next Cycle**
- [ ] **Determine Next Version**: Agree on next version number (patch/minor/major)
- [ ] **Update VERSION File**: Increment to next development version
- [ ] **Update Makefile Header**: Sync version in Makefile with VERSION file
- [ ] **Stage Version Changes**: `git add VERSION Makefile`
- [ ] **Commit Version Bump**: Use `chore: Prepare for vX.Y.Z development cycle`

### **3. Development Environment Validation**
- [ ] **Fresh Build Test**: `make configure && make build` (verify clean environment)
- [ ] **Help System Check**: `make help` (ensure all targets documented)
- [ ] **Version Confirmation**: `make version` (verify version increment)

## Emergency Rollback Procedure

### **If Build Breaks After Commit**
1. **Immediate**: `git revert HEAD` to undo last commit
2. **Investigate**: `make clean && make build` to identify issues
3. **Fix Forward**: Create fixing commit with `fix:` prefix
4. **Document**: Update this checklist if new failure mode discovered

<!-- Quick Commands section removed: commands are now referenced in checklist steps above for conciseness -->

## Checklist History

| Version | Date       | Changes|
|---------|------------|-------|
| 0.6.0   | 2025-07-18 | Checklist consolidated, version bump, post-check-in procedure|
| 0.5.0   | 2025-07-08 | Initial checklist creation|

---

**Remember**: Better to catch issues in the checklist than in production! 🎯
