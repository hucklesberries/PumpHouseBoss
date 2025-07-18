# ESPHome Project Check-in Checklist

## Pre-Commit Validation

### **1. Code Quality & Standards**
- [ ] **Version Consistency**: Makefile version matches `VERSION` file
- [ ] **Professional Headers**: All new files have GPL v3.0 headers with proper attribution
- [ ] **Documentation**: All functions/components have `@brief`, `@details`, `@author` comments
- [ ] **Code Style**: Consistent formatting, proper indentation, clean spacing

### **2. Build System Validation**
- [ ] **Clean Build**: `make clean && make build` completes successfully
- [ ] **No Warnings**: Build process shows no compilation warnings or errors
- [ ] **Generated Files**: Device YAML generates correctly from main.yaml template
- [ ] **Dependencies**: All required components and packages load without errors

### **3. Testing & Verification**
- [ ] **Hardware Test**: If hardware changes, verify on actual ESP32 device
- [ ] **Component Test**: New components build and initialize correctly
- [ ] **Log Validation**: Logging system produces clean, readable output
- [ ] **OTA Test**: Over-the-air upload works (if network changes made)

### **4. Documentation Updates**
- [ ] **README.md**: Updated with new features, requirements, or workflow changes
- [ ] **CHANGELOG.md**: New entry documenting changes with version bump
- [ ] **Help System**: `make help` reflects any new or changed targets
- [ ] **Component Docs**: New components documented in `common/` directory

### **5. Repository Hygiene**
- [ ] **File Permissions**: Normalized across repository (use `git add --chmod=644`)
- [ ] **Secrets Check**: No secrets, credentials, or sensitive data in commit
- [ ] **Generated Files**: Only commit source files, not generated device configs
- [ ] **Log Files**: Ensure logs/ directory not committed (should be in .gitignore)
- [ ] **Gitignore Updates**: Verify .gitignore covers new file types and patterns

### **6. Version Management**
- [ ] **VERSION File**: Bumped appropriately (major.minor.patch)
- [ ] **Makefile Header**: Version number updated to match VERSION file
- [ ] **Component Versions**: Any component-specific versions updated
- [ ] **Dependency Versions**: Document any new version requirements

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

## Quick Commands

### **Pre-Commit Validation**
```bash
# Clean build test
make clean && make build

# Version consistency check
grep "version.*0\." Makefile VERSION

# File permission normalization  
find . -type f -name "*.yaml" -o -name "*.md" -o -name "*.sh" | xargs chmod 644

# Documentation generation test
make docs

# Gitignore validation
git status --ignored --porcelain | grep "^!!" | head -5
```

### **Post-Commit Validation**
```bash
# Archive readiness test
make distclean && git status

# Fresh build test (after distclean)
make configure  # Interactive setup
make build     # Should build cleanly
```

### **Post-Check-in Procedure**
```bash
# 1. Reset checklist checkboxes (manual step in editor)
# 2. Update version for next development cycle
echo "0.5.0" > VERSION
sed -i 's/@version     0\.4\.0/@version     0.5.0/' Makefile

# 3. Commit version bump and checklist reset
git add VERSION Makefile CHECKIN-CHECKLIST.md
git commit -m "chore: Prepare for v0.5.0 development cycle

- Reset checklist checkboxes for next development cycle
- Bump version to 0.5.0 in VERSION file and Makefile
- Ready for next feature development phase"

# 4. Validate environment
make version && make help
```

## Checklist History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-07-18 | Initial checklist creation |
| 1.1.0 | 2025-07-18 | Added post-check-in procedure, gitignore validation, reset for v0.5.0 cycle |

---

**Remember**: Better to catch issues in the checklist than in production! 🎯
