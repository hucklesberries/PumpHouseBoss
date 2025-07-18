# ESPHome Project Check-in Checklist

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
- [ ] **Hardware Test**: If hardware changes, verify on actual ESP32 device
- [x] **Component Test**: New components build and initialize correctly
- [x] **Log Validation**: Logging system produces clean, readable output
- [ ] **OTA Test**: Over-the-air upload works (if network changes made)

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
- [ ] **Board Notes**: Hardware configuration documented in board_transition_notes.txt

### **2. Archive Readiness**
- [ ] **Distclean Test**: `make distclean` produces clean, archivable workspace
- [ ] **Fresh Clone**: Project builds correctly from fresh git clone
- [ ] **Dependencies**: All external dependencies documented and available

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

## Checklist History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-07-18 | Initial checklist creation |

---

**Remember**: Better to catch issues in the checklist than in production! 🎯
