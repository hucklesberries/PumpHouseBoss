# CONTRIBUTING.md — Project Context & Developer Guide

> **Scope & Purpose:**
> This document provides living project context, onboarding, workflow, troubleshooting, and technical notes for all contributors to PumpHouseBoss. It is the authoritative guide for day-to-day development, automation, and best practices. For a high-level project overview, see `README.md`.

---

## Table of Contents

## Table of Contents
- [Project Overview](#project-overview)
- [Quick Start](#quick-start)
- [Development Workflow](#development-workflow)
- [Documentation and Automation](#documentation-and-automation)
- [Troubleshooting and Tips](#troubleshooting-and-tips)
- [Appendix: Display and UI Plan](#appendix-display-and-ui-plan)

---

## Project Overview
- ESPHome-based device management for PumpHouseBoss
- Professional Makefile with robust build, upload, and documentation targets
- Modular YAML configuration, hardware abstraction, and automation
- Documentation generated via MkDocs and custom scripts

## Quick Start
1. Open VS Code in this workspace
2. Configure your device:
   - create or edit configuration in .//config
   - create your own secrets.yaml file from template
3. Build firmware: `make build`
4. Upload to device: `make upload`
5. Stream logs: `make logs`
6. Full pipeline: `make run`

## Development Workflow
- All build and upload logic is managed by the Makefile
- Use `make help` for a list of available targets
- Device, variant, and secrets are set via config files and Makefile variables
- Use `make clean` and `make distclean` for cleanup

## Documentation and Automation
- YAML headers and comments are extracted to Markdown for MkDocs
- Documentation targets:
  - `make docs` – Generate all documentation
  - `make docs-deploy` – Build and deploy documentation to GitHub Pages (public docs), and sync docs/wiki/ to the GitHub Wiki repository

## Troubleshooting and Tips
- Use `make buildvars` to check current build configuration
- If upload fails, check `COMM_PATH` and device connectivity
- For WiFi issues, stream logs and review connection attempts
- Always use Unix (LF) line endings
- Indent shell code in Makefile recipes for clarity

---

# Appendix: Display and UI Plan

## Overview
- System status icons, text, and menu interactions
- Blue background, white/blue borders
- Cycles through sensor and solenoid data
- Menu for manual solenoid control

## Controls
- Four buttons (e.g., scroll, select)
- Joystick activity brings up menu
- Operator can turn solenoids ON/OFF manually
- Menu times out after inactivity

## UI/UX Notes
- Use icons and color highlights for clarity
- Data pane highlights selected menu item

---

*This file is maintained by GitHub Copilot to provide living project context and best practices for all contributors.*
