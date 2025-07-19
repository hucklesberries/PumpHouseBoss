    for py in python3 python /cygdrive/c/Users/rhendel/AppData/Local/Programs/Python/Python313/python.exe; do \
        if "$$py" -c "import esptool" 2>/dev/null; then echo "$$py"; break; fi \
    done)

# GitHub Copilot Session Context

## Session Status
**Last Updated:** July 18, 2025

This file preserves technical context, session continuity, troubleshooting notes, and action items for developers resuming work. For project overview, features, and setup, see `README.md`.

## Development Environment Highlights
- Cygwin zsh terminal with Meslo Nerd Font
- VS Code integration (tasks.json, 9 ESPHome targets)
- Professional Makefile (24 targets, auto-detected Python)
- Organized documentation (docs/esphome/, docs/html/, docs/latex/)
- Full esptool integration (erase, info, verify)
- Safety systems: PROTECTED_DIRS, dependency composition, error handling
- Consistent GPL v3.0 headers and versioning


## Current Work & Action Items
- Makefile optimization and code quality improvements
- Session continuity and header standardization
- Version consistency (Makefile and VERSION file)
- Always include the standard project header in new files for consistency and traceability
- [ ] Test flash-verify functionality with current firmware
- [ ] Explore additional esptool functions if needed
- [ ] Continue ESPHome development with professional build system

## Troubleshooting & Quick Start

### WiFi Troubleshooting
- Device experiencing WiFi AP registration problems
- Capture live logs during connection attempts
- May need to modify logs target to include tee logging for shared visibility

### Quick Start Commands
1. Open VS Code in workspace: `<your-workspace-path>`
2. Verify environment: `make version` or `make help`
3. Check current config: `make buildvars`
4. Review last build: `cat build.log`

### Development Workflow
1. Configure: `make configure` (interactive setup)
2. Build: `make build` (compile firmware)
3. Upload: `make upload` (flash device)
4. Debug: `make logs` (stream live logs)
5. Full pipeline: `make run` (build + upload + logs)

### Check-in Process
1. Pre-Commit: Follow `CHECKIN-CHECKLIST.md` validation steps
2. Clean Build: `make clean && make build`
3. Version Bump: Update `VERSION` file and Makefile header
4. Archive Test: `make distclean`
5. Commit: Use structured commit message format
6. Post-Commit: Update continuity files (KIBO.md, GIT-COPILOT.md)

### Documentation Generation
1. All Docs: `make docs` (ESPHome + Doxygen)
2. ESPHome Only: `make docs-esphome`
3. Doxygen Only: `make docs-doxygen`

### Flash Operations
1. Chip Info: `make chip-info`
2. Flash Info: `make flash-info`
3. Flash Verify: `make flash-verify`
4. Flash Erase: `make flash-erase`

### Cleanup Operations
1. Basic Clean: `make clean`
2. Cache Clean: `make clean-cache`
3. Docs Clean: `make clean-docs`
4. Full Clean: `make clobber`
5. Archive Clean: `make distclean`

## Notes & Tips
- Always start by reading this file for session context
- Use `make help` to see all available targets
- Check `build.log` for recent compilation results
- Use `make buildvars` to confirm current device configuration
- Session continuity maintained through this documentation system
- Version consistency maintained between VERSION file and all component headers

---
*This file is maintained by GitHub Copilot to preserve session context and development state.*
