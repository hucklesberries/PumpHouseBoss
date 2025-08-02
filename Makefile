# ===============================================================================
#  File:         Makefile
#  File Type:    Makefile
#  Purpose:      Master Makefile for ESPHome-based device management
#  Version:      0.8.0d
#  Date:         2025-07-24
#  Author:       Roland Tembo Hendel <rhendel@nexuslogic.com>
#
#  Description:  Drives the build, upload, and configuration process for ESPHome
#                projects. Leverages a configuration file for per-device definitions
#                and includes safety mechanisms to prevent destructive errors.
#
#  Features:     - Per-device configuration and build
#                - Safety checks for secrets and version
#                - Utility, build, docs, and clean targets
#                - Robust error handling and protected directories
#                - Project versioning and documentation automation
#
#  Usage:        $(MAKE) [target] [CONFIG=path/to/config.mk] [VARIANT=variant]
#                   Common targets: build, upload, logs, docs, clean, run
#                   Example:
#                     $(MAKE) build VARIANT=phb-pro CONFIG=phb-pro-test.mk
#
#  License:      GNU General Public License v3.0
#                SPDX-License-Identifier: GPL-3.0-or-later
#  Copyright:    (c) 2025 Roland Tembo Hendel
#                This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License.
# ===============================================================================


# include helper macros and functions
include makefile.mk


# ------------------------------------------------------------------------------
# Initialization / Configuration
# ------------------------------------------------------------------------------

# Load project version string
VERSION        ?= $(shell cat VERSION)

# Project root directory (no trailing slash)
PROJECT_ROOT   := $(abspath .)

# Default target - full pipeline: build + upload + logs
.DEFAULT_GOAL  := run

# User-specified CONFIG file from the command line, these take precedence
ifeq ($(origin CONFIG),command line)
ifeq ($(shell [ -r $(CONFIG) ] && echo yes),yes)
include $(CONFIG)
else
$(error User config file '$(CONFIG)' is not readable)
endif
endif

# Default custom configuration file (will not override established values)
ifeq ($(shell [ -r $(PROJECT_ROOT)/config/config.mk ] && echo yes),yes)
include $(PROJECT_ROOT)/config/config.mk
else
$(error Default config file '$(PROJECT_ROOT)/config/config.mk' is not readable)
endif

# Project global defaults (will not override established values)
ifeq ($(shell [ -r $(PROJECT_ROOT)/config/default.mk ] && echo yes),yes)
include $(PROJECT_ROOT)/config/default.mk
else
$(error Default config file '$(PROJECT_ROOT)/config/default.mk' is not readable)
endif

# Variant defaults (will not override established values)
ifeq ($(strip $(VARIANT)),)
$(error VARIANT is not set. Please specify a build variant.)
else
ifneq ($(shell [ -r $(PROJECT_ROOT)/variants/$(VARIANT)/$(VARIANT).mk ] && echo yes),yes)
$(error Variant file '$(PROJECT_ROOT)/variants/$(VARIANT)/$(VARIANT).mk' is not readable)
else
include $(PROJECT_ROOT)/variants/$(VARIANT)/$(VARIANT).mk
endif
endif

# Project-wide variables and pre-compile defaults
YAML_DIRS              := $(PROJECT_ROOT) $(PROJECT_ROOT)/common $(PROJECT_ROOT)/variants/phb-std $(PROJECT_ROOT)/variants/phb-pro
YAML_FILES             := $(filter-out %/secrets.yaml, $(foreach dir,$(YAML_DIRS),$(wildcard $(dir)/*.yaml)))
BLD_DEPS               := $(YAML_MAIN) $(SECRETS_FILE) $(wildcard $(PROJECT_ROOT)/common/*.yaml) $(wildcard $(PROJECT_ROOT)/variants/$(VARIANT)/*.yaml)
MD_FILES               := $(foreach dir,$(YAML_DIRS),$(wildcard $(dir)/*.md))
YAML_MAIN              ?= $(PROJECT_ROOT)/variants/$(VARIANT)/$(VARIANT).yaml
SECRETS_FILE           := $(PROJECT_ROOT)/common/secrets.yaml
SECRETS_TEMPLATE       := $(PROJECT_ROOT)/common/secrets.template.yaml
BUILD_DIR              := $(PROJECT_ROOT)/build/$(VARIANT)/$(NODE_NAME)
DOC_DIR                ?= $(PROJECT_ROOT)/docs
DOC_SITE_MD_DIR        ?= $(DOC_DIR)/site-md
DOC_WIKI_MD_DIR        ?= $(DOC_DIR)/wiki-md
DOC_COMMON_MD_DIR      ?= $(DOC_DIR)/common-md
DOC_MKDOCS_STAGED_DIR  ?= $(DOC_DIR)/mkdocs-staged
DOC_SITE_STAGED_DIR    ?= $(DOC_DIR)/site-staged
DOC_WIKI_STAGED_DIR    ?= $(DOC_DIR)/wiki-staged
BUILD_LOG              ?= $(PROJECT_ROOT)/build.log
RUN_LOG                ?= $(PROJECT_ROOT)/logs/$(NODE_NAME)-$(shell date +%Y%m%d_%H%M%S).log

# Files and directories to be protected from accidental deletion
PROTECTED_DIRS         := / ~ ./ $(PROJECT_ROOT)/common $(PROJECT_ROOT)/variants/ $(PROJECT_ROOT)/config $(PROJECT_ROOT)/docs $(PROJECT_ROOT)/icons

# RELATIVE_BUILD_PATH is the YAML path relative to the project root
#   IMPORTANT: Always use a relative path to the YAML file when calling ESPHome.
#   Using an absolute path causes ESPHome to misresolve includes and assets, and produces misleading errors.
RELATIVE_BUILD_PATH    := build/$(VARIANT)/$(NODE_NAME)/$(NODE_NAME).yaml

# helper scripts
SCRIPT_DIR             ?= $(PROJECT_ROOT)/scripts
REGRESSION_TEST_SCRIPT := $(SCRIPT_DIR)/regression-test.sh

# export for sub/recursive makes
export VARIANT PLATFORM DEVICE_NAME NODE_NAME FRIENDLY_NAME COMM_PATH YAML_MAIN SECRETS_FILE RUN_LOG RELATIVE_BUILD_PATH


# ------------------------------------------------------------------------------
# Build Target
# ------------------------------------------------------------------------------

# Compile the ESPHome firmware for the specified device
$(BUILD_DIR)/$(NODE_NAME).yaml: $(BLD_DEPS)
	@echo "[START] Generating YAMLs with substitutions for $(NODE_NAME)..."
	@$(MAKE) VARS_TO_VALIDATE="VARIANT PLATFORM DEVICE_NAME NODE_NAME FRIENDLY_NAME" _validate_vars
	@$(MAKE) FILES_TO_VALIDATE="$(YAML_MAIN) $(SECRETS_FILE)" _validate_files
	@mkdir -p $(BUILD_DIR)
	@echo "s|__PROJECT_ROOT__|../../..|g" > .sedargs
	@echo "s|__VERSION__|$(VERSION)|g" >> .sedargs
	@echo "s|__VARIANT__|$(VARIANT)|g" >> .sedargs
	@echo "s|__PLATFORM__|$(PLATFORM)|g" >> .sedargs
	@echo "s|__DEVICE_NAME__|$(DEVICE_NAME)|g" >> .sedargs
	@echo "s|__NODE_NAME__|$(NODE_NAME)|g" >> .sedargs
	@echo "s|__FRIENDLY_NAME__|$(FRIENDLY_NAME)|g" >> .sedargs
	@echo "s|__STATIC_STATIC_IP__|$(STATIC_STATIC_IP)|g" >> .sedargs
	@echo "s|__STATIC_GATEWAY__|$(STATIC_GATEWAY)|g" >> .sedargs
	@echo "s|__STATIC_SUBNET__|$(STATIC_SUBNET)|g" >> .sedargs
	@echo "s|__STATIC_DNS1__|$(STATIC_DNS1)|g" >> .sedargs
	@echo "s|__STATIC_DNS2__|$(STATIC_DNS2)|g" >> .sedargs
	# Process all YAML source files with sed and output to build dir
	@for f in $(YAML_FILES); do \
		out="$(BUILD_DIR)/$$(basename $$f)"; \
		sed -f .sedargs < "$$f" > "$$out"; \
	done
	@sed -f .sedargs < $(YAML_MAIN) > $(BUILD_DIR)/$(NODE_NAME).yaml
	@rm -f .sedargs
	   # Copy icons directory if it exists
	   @if [ -d "icons" ]; then \
			   echo "Copying icons/ to \"$(BUILD_DIR)/icons\"..."; \
			   cp -r "icons" "$(BUILD_DIR)/"; \
	   fi
	   # Copy common directory if it exists
	   @if [ -d "common" ]; then \
			   echo "Copying common/ to \"$(BUILD_DIR)/common\"..."; \
			   cp -r "common" "$(BUILD_DIR)/"; \
	   fi
	@echo "[DONE] Generation complete."
	@echo "[START] Building firmware for $(NODE_NAME)..."
	esphome compile $(RELATIVE_BUILD_PATH)
	@echo "[DONE] Build complete for $(NODE_NAME)."


# User build target
.PHONY: build
build: $(BUILD_DIR)/$(NODE_NAME).yaml


# ------------------------------------------------------------------------------
# Platform Targets
# ------------------------------------------------------------------------------
# NOTE: The upload mechanism is flexible. Set COMM_PATH to an OTA address
#       (e.g., 'phb-esp32-00.local') for wireless uploads, 
#       or to a serial port (e.g., '/dev/ttyUSB0' or 'COM3') for wired uploads.
#       The Makefile and all upload/flash/verify targets will use COMM_PATH
#       consistently.
# ------------------------------------------------------------------------------

# Upload current firmware build to the device
.PHONY: upload
upload: build
	@echo "[START] Uploading firmware to $(NODE_NAME)..."
	@$(MAKE) VARS_TO_VALIDATE="COMM_PATH RELATIVE_BUILD_PATH" _validate_vars
	@cd $(PROJECT_ROOT) && esphome upload $(RELATIVE_BUILD_PATH) --device $(COMM_PATH)
	@echo "[DONE] Upload complete for $(NODE_NAME)."

# Verify flash contents against current firmware build
.PHONY: flash-verify
flash-verify: build
	@echo "[START] Verifying flash contents against current firmware build..."
	@$(MAKE) VARS_TO_VALIDATE="COMM_PATH" _validate_vars
	@FIRMWARE_PATH="$(BUILD_DIR)/.esphome/build/$(NODE_NAME)/firmware.bin"; \
	if [ -f "$$FIRMWARE_PATH" ]; then \
		echo "Using firmware binary: $$FIRMWARE_PATH"; \
		echo "Comparing flash contents with built firmware..."; \
		$(ESPTOOL_CMD) verify_flash 0x0 "$$FIRMWARE_PATH" || \
		echo -e "$(ERROR) Flash verification failed - contents do not match firmware binary"; \
	else \
		echo -e "$(ERROR) Firmware binary not found: $$FIRMWARE_PATH"; \
		exit 1; \
	fi
	@echo "[DONE] Flash verification complete."

# Build, upload, start logging, then follow logs in one step
.PHONY: run
run: upload logs logs-follow

# Erase the entire flash memory of the chipset
.PHONY: flash-erase
flash-erase:
	@echo "[START] Erasing flash memory via $(COMM_PATH)..."
	@$(MAKE) VARS_TO_VALIDATE="COMM_PATH" _validate_vars
	@echo -e "$(WARN): This will completely erase all firmware and data!"
	@echo "Press Ctrl+C within 5 seconds to cancel..."
	@sleep 5
	@$(ESPTOOL_CMD) erase_flash
	@echo "[DONE] Flash erase complete."

# Display flash memory information and layout
.PHONY: flash-info
flash-info:
	@echo "[START] Reading flash memory information via $(COMM_PATH)..."
	@$(MAKE) VARS_TO_VALIDATE="COMM_PATH" _validate_vars
	@$(ESPTOOL_CMD) flash_id
	@echo "[DONE] Flash info read."

# Display chipset information and capabilities
.PHONY: chip-info
chip-info:
	@echo "[START] Reading $(PLATFORM) information via $(COMM_PATH)..."
	@$(MAKE) VARS_TO_VALIDATE="COMM_PATH" _validate_vars
	@$(ESPTOOL_CMD) chip_id
	@echo "[DONE] Chip info read."


# ------------------------------------------------------------------------------
# Logging Targets
# ------------------------------------------------------------------------------

# Start foreground logging to stdout
.PHONY: logs
logs:
	@echo "[START] Streaming logs from $(NODE_NAME)..."
	@$(MAKE) VARS_TO_VALIDATE="NODE_NAME RELATIVE_BUILD_PATH" _validate_vars
	@cd $(PROJECT_ROOT) && esphome logs $(RELATIVE_BUILD_PATH)
	@echo "[DONE] Streaming logs from $(NODE_NAME)."

# Start background logging to file
.PHONY: logs-start-bg
logs-start-bg:
	@echo "[START] Starting background log streaming from $(NODE_NAME) to $(RUN_LOG)."
	@$(MAKE) VARS_TO_VALIDATE="NODE_NAME RUN_LOG" _validate_vars
	@if [ ! -d logs ]; then \
			echo "Creating logs directory..."; \
			mkdir -p logs; \
	fi
	@echo "Stopping any pre-existing logging sessions..."
	@pkill -f "esphome logs.*$(NODE_NAME)" 2>/dev/null || echo "No previous logging processes found"
	@echo "Starting fresh logging session to $(RUN_LOG)..."
	@cd $(PROJECT_ROOT) && esphome logs $(RELATIVE_BUILD_PATH) > $(RUN_LOG) 2>&1 &
	@echo "Creating symlink to latest log file..."
	@cd logs && ln -sf $(shell basename $(RUN_LOG)) $(NODE_NAME).log
	@echo "Logs are being written to: $(RUN_LOG)"
	@echo "Latest log accessible via: logs/$(NODE_NAME).log"
	@echo "Use 'tail -f logs/$(NODE_NAME).log' to follow logs, or 'make logs-follow' for convenience"
	@echo "Use 'make logs-stop' to stop background logging"
	@echo "[DONE] Background logging session started."

# Stop background logging to file
.PHONY: logs-stop-bg
logs-stop-bg:
	@echo "[START] Stopping background log streaming from $(NODE_NAME) to $(RUN_LOG)."
	@$(MAKE) VARS_TO_VALIDATE="NODE_NAME" _validate_vars
	@echo "Stopping background logging processes..."
	@pkill -f "esphome logs.*$(NODE_NAME)" 2>/dev/null || echo "No logging processes found"
	@echo "[DONE] Background logging session stopped."

# Follow background log output to stdout in real-time
.PHONY: logs-follow
logs-follow:
	@echo "[START] Following background log stream from $(NODE_NAME)."
	@$(MAKE) VARS_TO_VALIDATE="NODE_NAME" _validate_vars
	@echo "Following logs from logs/$(NODE_NAME).log..."
	@if [ ! -f logs/$(NODE_NAME).log ]; then \
		echo -e "$(ERROR) Log file logs/$(NODE_NAME).log not found. Please run 'make logs' first."; \
		exit 1; \
	fi
	@tail -f logs/$(NODE_NAME).log
	@echo "[DONE] Following background log stream."

# Start new background logging session and follow background log output to stdout in real-ime
.PHONY: logs-follow-new
logs-follow-new: logs-start-bg
	@echo "[START] Following a new background log stream from $(NODE_NAME)."
	@echo "Following new log session ($(RUN_LOG))..."
	@tail -f logs/$(NODE_NAME).log
	@echo "[DONE] Following background log stream."


# ------------------------------------------------------------------------------
# Documentation Targets
# ------------------------------------------------------------------------------

# Stage documentation source for processing by mkdocs
.PHONY: _mkdocs
_mkdocs:
	@echo "[START] Staging documentation source files for mkdocs..."
	@rm -rf $(DOC_MKDOCS_STAGED_DIR)
	@mkdir -p $(DOC_MKDOCS_STAGED_DIR)
	@cp -a $(DOC_SITE_MD_DIR)/* $(DOC_MKDOCS_STAGED_DIR)
	@cp -a $(DOC_COMMON_MD_DIR)/* $(DOC_MKDOCS_STAGED_DIR)
	@for f in $(MD_FILES); do \
		base=$$(basename $$f); \
		cp -f "$$f" $(DOC_MKDOCS_STAGED_DIR)/ 2>/dev/null || echo "# Stub for $$base" > $(DOC_MKDOCS_STAGED_DIR); \
	done
	@for yaml in $(YAML_FILES); do \
		comp=$$(basename $$yaml .yaml); \
		md="$(DOC_MKDOCS_STAGED_DIR)/$${comp}.md"; \
		echo "# Component: $$comp" > "$$md"; \
		echo "# Source: $$yaml" >> "$$md"; \
		echo "# Generated: $$(date)" >> "$$md"; \
		echo "" >> "$$md"; \
		echo '```yaml' >> "$$md"; \
		cat "$$yaml" >> "$$md"; \
		echo '```' >> "$$md"; \
	done
	@echo "[DONE] Documentation source files staged for mkdocs."

# Generate all documentation
.PHONY: docs
docs: _mkdocs
	@echo "Building MkDocs documentation site into $(DOC_SITE_STAGED_DIR)..."
	@mkdocs build --clean --config-file $(DOC_DIR)/mkdocs.yml
	@echo "[DONE] MkDocs site built at $(DOC_SITE_STAGED_DIR)."

# 1. Deploy mkdocs site to GitHub Pages
# 2. Update GitHub wiki
.PHONY: docs-deploy
docs-deploy: _mkdocs
	@echo "[START] Deploying documentation for hosting..."
	@echo " Deploying mkdocs site to GitHub Pages at https://hucklesberries.github.io/PumpHouseBoss/"
	@mkdocs gh-deploy --config-file $(DOC_DIR)/mkdocs.yml --remote-branch gh-pages
	@echo " Deploying Github wiki at https://github.com/hucklesberries/PumpHouseBoss/wiki"
	@rm -rf $(DOC_WIKI_STAGED_DIR) && git clone --depth 1 https://github.com/hucklesberries/PumpHouseBoss.wiki.git $(DOC_WIKI_STAGED_DIR)
	@cp -r $(DOC_WIKI_MD_DIR)/* $(DOC_WIKI_STAGED_DIR)
	@cp -r $(DOC_COMMON_MD_DIR)/* $(DOC_WIKI_STAGED_DIR)
	@cd $(DOC_WIKI_STAGED_DIR) && git add . && git commit -am "Sync wiki from main repo [automated]" || echo "No changes to commit."
	@cd $(DOC_WIKI_STAGED_DIR) && git push
	@echo "[DONE] Documentation deployed."


# ------------------------------------------------------------------------------
# Test Targets
# ------------------------------------------------------------------------------

# Regression test: check for required files and utility targets
.PHONY: regression-test
regression-test:
	@$(REGRESSION_TEST_SCRIPT)


# ------------------------------------------------------------------------------
# Cleanup Targets
# Note: These targets are not dependent on the generated configuration file and
#       may be called at any time, including after `distclean`.
# ------------------------------------------------------------------------------

# Remove temporary build artifacts and logs
.PHONY: clean
clean:
	@echo "[START] Cleaning build artifacts ($(BUILD_LOG), .sedargs)..."
	@rm -f $(BUILD_LOG) .sedargs
	@echo "Cleaning build directory ($(BUILD_DIR))..."
	@sh -c '$(call SAFE_RM,$(BUILD_DIR))'
	@echo "Cleaning logs for $(NODE_NAME)..."
	@rm -f logs/$(NODE_NAME).log logs/$(NODE_NAME)-*.log
	@echo "Cleaning generated documentation for variant ($(VARIANT))..."
	@sh -c '$(call SAFE_RM,docs/esphome/$(VARIANT))'
	@echo "[DONE] Clean complete."

# Remove ESPHome build cache and compiled objects
.PHONY: clean-cache
clean-cache:
	@echo "[START] Removing ESPHome build cache..."
	@-sh -c '$(call SAFE_RM,$(BUILD_DIR)/.esphome)'
	@echo "[DONE] ESPHome build cache removed."

# Remove generated documentation files (ESPHome and MkDocs)
.PHONY: clean-docs
clean-docs:
	@echo "[START] Cleaning documentation files..."
	@-sh -c '$(call SAFE_RM,$(DOC_MKDOCS_STAGED_DIR))'
	@-sh -c '$(call SAFE_RM,$(DOC_SITE_STAGED_DIR))'
	@-sh -c '$(call SAFE_RM,$(DOC_WIKI_STAGED_DIR))'
	@echo "[DONE] Documentation files cleaned."

# Remove entire device directory (generated YAML + all build artifacts)
.PHONY: clobber
clobber: clean-cache clean-docs
	@echo "[START] Clobbering device build directory..."
	@-sh -c '$(call SAFE_RM,$(BUILD_DIR))'
	@echo "[DONE] Device build directory clobbered."

# Remove all generated content for fresh start
.PHONY: distclean
distclean: clean-docs
	@echo "[START] Performing complete cleanup for archive/export..."
	@-rm -f .sedargs $(BUILD_LOG) 2>/dev/null || true
	@-sh -c '$(call SAFE_RM,build)' 2>/dev/null || true
	@-sh -c '$(call SAFE_RM,logs)' 2>/dev/null || true
	@set -- */; \
	if [ "$$1" != "*/" ]; then \
		(set +e; for dir in "$@"; do \
			[ -d "$$dir" ] && sh -c '$(call SAFE_RM,$$dir)' || true; \
		done); \
	fi
	@echo "[DONE] Distclean complete - workspace ready for archive."


# ------------------------------------------------------------------------------
# Utility Targets
# Note: These targets are not dependent on the generated configuration file and
#       may be called at any time, including after `distclean`.
# ------------------------------------------------------------------------------

# Show the version of ESPHome currently installed
.PHONY: version
version:
	@echo "Project Version: $(VERSION)"
	@echo -n "ESPHome "
	@esphome --version

# Display the currently loaded configuration variables
.PHONY: buildvars
buildvars:
	@echo "Variant........: $(if $(VARIANT),$(VARIANT),[ MISSING ])"
	@echo "Platform.......: $(if $(PLATFORM),$(PLATFORM),[ MISSING ])"
	@echo "Device name....: $(if $(DEVICE_NAME),$(DEVICE_NAME),[ MISSING ])"
	@echo "Node name......: $(if $(NODE_NAME),$(NODE_NAME),[ MISSING ])"
	@echo "Friendly name..: $(if $(FRIENDLY_NAME),$(FRIENDLY_NAME),[ MISSING ])"
	@echo "WiFi IP........: $(if $(STATIC_STATIC_IP),$(STATIC_STATIC_IP),[ dynamic ])"
	@echo "WiFi Gateway...: $(if $(STATIC_GATEWAY),$(STATIC_GATEWAY),[ dynamic ])"
	@echo "WiFi Subnet....: $(if $(STATIC_SUBNET),$(STATIC_SUBNET),[ dynamic ])"
	@echo "WiFi DNS1......: $(if $(STATIC_DNS1),$(STATIC_DNS1),[ dynamic ])"
	@echo "WiFi DNS2......: $(if $(STATIC_DNS2),$(STATIC_DNS2),[ dynamic ])"
	@echo "Build Directory: $(if $(DEVICE_NAME),$(BUILD_DIR),[ NOT_SET ])"
	@echo "Comm Path......: $(if $(DEVICE_NAME),$(COMM_PATH),[ NOT_SET ])"
	@echo "Build Log File.: $(if $(DEVICE_NAME),$(BUILD_LOG),[ NOT_SET ])"
	@echo "Run Log File...: $(if $(DEVICE_NAME),$(RUN_LOG),[ NOT_SET ])"



# Print a list of available Makefile targets and descriptions
.PHONY: help
help:
	@echo "================================================================================"
	@echo "|                            AVAILABLE TARGETS                                 |"
	@echo "================================================================================"
	@echo ""
	@echo "Build Targets:"
	@echo "  build               Build (compile) firmware for the selected device variant"
	@echo ""
	@echo "Platform Targets:"
	@echo "  upload              Upload compiled firmware to the device (via $(COMM_PATH))"
	@echo "  flash-verify        Verify device flash contents against current firmware build"
	@echo "  run                 Build, upload, and stream logs (combo pipeline)"
	@echo "  flash-erase         Erase entire device flash memory (CAREFUL: destructive!)"
	@echo "  flash-info          Show flash memory information and layout"
	@echo "  chip-info           Show device chipset information and capabilities"
	@echo ""
	@echo "Logging Targets:"
	@echo "  logs                Stream logs in the foreground (interactive, blocks terminal)"
	@echo "  logs-start-bg       Start background logging to file (creates logs/DEVICE.log symlink)"
	@echo "  logs-stop-bg        Stop background logging processes for this device"
	@echo "  logs-follow         Follow logs in real-time from the background log file"
	@echo "  logs-follow-new     Start new background logging and follow its output"
	@echo ""
	@echo "Documentation Targets:"
	@echo "  docs                Generate project documentation"
	@echo "  docs-deploy         Generate and documentation to GitHub Pages and GitHub Wiki repository"
	@echo ""
	@echo "Test Targets:"
	@echo "  regression-test     Run regression tests on all device YAMLs"
	@echo ""
	@echo "Cleanup Targets:"
	@echo "  clean               Remove temporary build artifacts and logs"
	@echo "  clean-cache         Remove ESPHome build cache"
	@echo "  clean-docs          Remove generated documentation"
	@echo "  clobber             Remove entire device directory and documentation"
	@echo "  distclean           Complete cleanup for archive/export"
	@echo ""
	@echo "Utility Targets:"
	@echo "  version             Show platform and ESPHome version"
	@echo "  buildvars           Show current build configuration values"
	@echo "  help                Show this message"


# ------------------------------------------------------------------------------
# Helper Targets
# Note: These targets are meant for use by the Build and Utility targets.
#       They are not typically invoked directly by users.
# ------------------------------------------------------------------------------

# validate target dependencies
.PHONY: _validate_vars
_validate_vars:
	@for var in $(VARS_TO_VALIDATE); do \
		if [ -z "$${!var}" ]; then \
			echo "[ERROR] Required variable '$$var' is not set."; \
			exit 1; \
		fi; \
	done

.PHONY: _validate_files
_validate_files:
	@for file in $(FILES_TO_VALIDATE); do \
		if [ ! -f "$$file" ]; then \
			echo "[ERROR] Required file '$$file' is missing."; \
			exit 1; \
		fi; \
	done
