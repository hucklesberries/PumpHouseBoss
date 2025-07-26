# GIT-COPILOT.md — Session Context & Developer Continuity

> This file is maintained by GitHub Copilot to preserve technical context, session continuity, troubleshooting notes, and onboarding information for all contributors.
> For project overview and setup, see `README.md`.

# GitHub Copilot Session Context

## Session Status
**Last Updated:** July 21, 2025

**Recent updates:**
- Provided pinout maps for ESP32S3, ST7789 display, and Pico-LCD hardware components
- Major UI improvements: ST7789 display now shows Hostname, SSID, IP, and MAC address, with robust centering and fallback for missing values
- Font size and layout adjustments for better data fit and readability
- Improved secrets management, Makefile automation, and documentation

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

## Troubleshooting & Quick Start

### WiFi Troubleshooting
- Device experiencing WiFi AP registration problems
4. Review last build: `cat build.log`

### Check-in Process
1. Pre-Commit: Follow `CHECKIN-CHECKLIST.md` validation steps
2. Clean Build: `make clean && make build`
3. Version Bump: Update `VERSION` file and Makefile header

### Documentation Generation
#### New Documentation Workflow (as of July 2025)
- YAML module/file descriptions are now extracted to Markdown using `docs/extract_yaml_headers.py`.

To generate all documentation:
  1. Run: `python docs/extract_yaml_headers.py` (extracts YAML headers to Markdown in `docs/`)
  2. Run: `make docs` (generates ESPHome docs)
To generate only ESPHome docs: `make docs-esphome`
All generated documentation is output to `docs/esphome/`.

1. All Docs: `make docs` (ESPHome only)
2. ESPHome Only: `make docs-esphome`

### Flash Operations
1. Chip Info: `make chip-info`
2. Flash Info: `make flash-info`
3. Flash Verify: `make flash-verify`
4. Flash Erase: `make flash-erase`

### Cleanup Operations
1. Basic Clean: `make clean`
2. Cache Clean: `make clean-cache`
4. Full Clean: `make clobber`
5. Archive Clean: `make distclean`

## Session Continuity & Shared Context
- Always use the `.kibo` file in your home directory (`~/.kibo`) for session continuity and shared context across workspaces.
- When updating session context, run `~/sync-kibo.sh push` to sync changes back to `~/.kibo`.
- At the start of every session, read `.kibo` from the workspace (or from the symlink pointing to `~/.kibo`) to restore context.
- Do not use `.git-copilot` or `.git-copilot.md` for continuity—use `.kibo` exclusively.
- Ensure `.kibo` is listed in `.gitignore` to prevent accidental commits.
- If `.kibo` is not accessible, copy it into the workspace or provide its contents.
- All file creation and editing should use Unix (LF) line endings.

---
*These notes ensure robust, cross-workspace session continuity and prevent loss of shared context.*

## Notes & Tips
- **When updating version strings, do not update the version in `main.yaml` unless specifically requested.**
- **All shell code within Makefile recipes (such as inside for/while/if blocks) should be indented for human readability, even though the shell does not require it. This improves maintainability and clarity for all contributors.**

---
*This file is maintained by GitHub Copilot to preserve session context and development state.*
Always use Unix (LF) file format when creating or editing files in this repository.

# Appendix: Display and UI Plan

## Overview
  - Shows system status icons (e.g., checkmark), and can display status text.
  - Blue background, framed by white and blue borders.
  - Used for cycling through sensor and solenoid data, and for menu interactions.

  - Sensor/solenoid name
  - Solenoid state (ON/OFF)
  - Smart shutoff status (enabled/disabled)

## Controls
- Four buttons:
  - **A:** Scroll up
- Any joystick activity brings up a menu in the data pane for manual control.

- Operator can:
  - Turn any solenoid ON or OFF manually
- Menu times out and returns to idle cycling after inactivity.

## UI/UX Notes
- Use icons and color highlights for clarity (e.g., ON/OFF, smart shutoff status).
- Data pane can highlight the currently selected item in the menu.

This plan will be implemented incrementally, starting with display layout and cycling logic, then adding controls and menu features.
# GitHub Copilot Session Context

## Session Status

**Recent updates:**
- Provided pinout maps for ESP32S3, ST7789 display, and Pico-LCD hardware components
- Major UI improvements: ST7789 display now shows Hostname, SSID, IP, and MAC address, with robust centering and fallback for missing values
- Improved secrets management, Makefile automation, and documentation

## Development Environment Highlights
- VS Code integration (tasks.json, 9 ESPHome targets)
- Professional Makefile (24 targets, auto-detected Python)
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

#### New Documentation Workflow (as of July 2025)

- YAML module/file descriptions are now extracted to Markdown using `docs/extract_yaml_headers.py`.
- The Doxygen configuration file is located at `docs/Doxyfile` (not the project root).

To generate all documentation:
  1. Run: `python docs/extract_yaml_headers.py` (extracts YAML headers to Markdown in `docs/`)
  2. Run: `make docs` (generates ESPHome and Doxygen docs)

- To generate only ESPHome docs: `make docs-esphome`
- To generate only Doxygen docs: `make docs-doxygen`
- All generated documentation is output to `docs/esphome/`, `docs/html/`, and `docs/latex/`.

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

## Session Continuity & Shared Context
- Always use the `.kibo` file in your home directory (`~/.kibo`) for session continuity and shared context across workspaces.
- When updating session context, run `~/sync-kibo.sh push` to sync changes back to `~/.kibo`.
- At the start of every session, read `.kibo` from the workspace (or from the symlink pointing to `~/.kibo`) to restore context.
- Do not use `.git-copilot` or `.git-copilot.md` for continuity—use `.kibo` exclusively.
- Ensure `.kibo` is listed in `.gitignore` to prevent accidental commits.
- If `.kibo` is not accessible, copy it into the workspace or provide its contents.
- All file creation and editing should use Unix (LF) line endings.

---
*These notes ensure robust, cross-workspace session continuity and prevent loss of shared context.*

## Notes & Tips
- **When updating version strings, do not update the version in `main.yaml` unless specifically requested.**
- **All shell code within Makefile recipes (such as inside for/while/if blocks) should be indented for human readability, even though the shell does not require it. This improves maintainability and clarity for all contributors.**


---
*This file is maintained by GitHub Copilot to preserve session context and development state.*
Always use Unix (LF) file format when creating or editing files in this repository.
