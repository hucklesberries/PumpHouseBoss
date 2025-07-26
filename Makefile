
# ===============================================================================
#  File:         Makefile
#  File Type:    Makefile
#  Purpose:      Master Makefile for ESPHome-based device management
#  Version:      0.7.0
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
#  Usage:        make [target] [CONFIG=path/to/config.mk] [VARIANT=variant]
#                   Common targets: build, upload, logs, docs, clean, run
#                   Example:
#                     make build VARIANT=phb-pro CONFIG=phb-pro-test.mk
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
	ifneq ($(shell [ -r $(PROJECT_ROOT)/variants/$(VARIANT)/variant.mk ] && echo yes),yes)
		$(error Variant file '$(PROJECT_ROOT)/variants/$(VARIANT)/variant.mk' is not readable)
	else
		include $(PROJECT_ROOT)/variants/$(VARIANT)/variant.mk
	endif
endif

# Project-wide file variables and pre-compile defaults
SRC_DIRS            := $(PROJECT_ROOT) $(PROJECT_ROOT)/variants $(PROJECT_ROOT)/common
SECRETS_FILE        := $(PROJECT_ROOT)/common/secrets.yaml
SECRETS_TEMPLATE    := $(PROJECT_ROOT)/common/secrets.template.yaml
TEST_SCRIPT         := $(PROJECT_ROOT)/regression-test.sh
YAML_MAIN           ?= $(PROJECT_ROOT)/variants/$(VARIANT)/main.yaml
BUILD_DIR           := $(PROJECT_ROOT)/build/$(VARIANT)/$(NODE_NAME)
LOGFILE             ?= $(PROJECT_ROOT)/logs/$(NODE_NAME)-$(shell date +%Y%m%d_%H%M%S).log
SRC_FILES           := $(filter-out %/secrets.yaml, $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/**/*.yaml)))
MD_FILES            := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.md))

# Files and directories to be protected from accidental deletion
PROTECTED_DIRS      := / ~ ./ $(PROJECT_ROOT)/common $(PROJECT_ROOT)/variants/ $(PROJECT_ROOT)/config $(PROJECT_ROOT)/docs $(PROJECT_ROOT)/icons

# RELATIVE_BUILD_PATH is the YAML path relative to the project root
#   IMPORTANT: Always use a relative path to the YAML file when calling ESPHome.
#   Using an absolute path causes ESPHome to misresolve includes and assets, and produces misleading errors.
RELATIVE_BUILD_PATH := build/$(VARIANT)/$(NODE_NAME)/$(NODE_NAME).yaml


# ------------------------------------------------------------------------------
# Build/Platform Targets
# ------------------------------------------------------------------------------

# Compile the ESPHome firmware for the specified device
.PHONY: build
build: _build
	@echo Building firmware for $(NODE_NAME)...
	esphome compile $(RELATIVE_BUILD_PATH)

# Upload current firmware build to the device
.PHONY: upload
upload:
	@echo Uploading firmware to $(NODE_NAME)...
	@cd $(PROJECT_ROOT) && esphome upload $(RELATIVE_BUILD_PATH) --device $(UPLOAD_PATH)

# Record logs from the device
.PHONY: logs
logs: check-secrets
	@if [ ! -d logs ]; then \
		echo "Creating logs directory..."; \
		mkdir -p logs; \
	fi
	@echo "Stopping any existing logging sessions..."
	@pkill -f "esphome logs.*$(NODE_NAME)" 2>/dev/null || echo "No previous logging processes found"
	@echo "Starting fresh logging session to $(LOGFILE)..."
	@cd $(PROJECT_ROOT) && esphome logs $(RELATIVE_BUILD_PATH) > $(LOGFILE) 2>&1 &
	@echo "Creating symlink to latest log file..."
	@cd logs && ln -sf $(shell basename $(LOGFILE)) $(NODE_NAME).log
	@echo "Logs are being written to: $(LOGFILE)"
	@echo "Latest log accessible via: logs/$(NODE_NAME).log"
	@echo "Use 'tail -f logs/$(NODE_NAME).log' to follow logs, or 'make logs-follow' for convenience"
	@echo "Use 'make logs-stop' to stop background logging"

# Follow log output in real-time
.PHONY: logs-follow
logs-follow:
	@if [ ! -d logs ]; then \
		echo "Creating logs directory..."; \
		mkdir -p logs; \
	fi
	@echo "Following logs from logs/$(NODE_NAME).log..."
	@if [ ! -f logs/$(NODE_NAME).log ]; then \
		echo -e "$(ERROR) Log file logs/$(NODE_NAME).log not found. Please run 'make logs' first."; \
		exit 1; \
	fi
	@tail -f logs/$(NODE_NAME).log

# Stop background logging
.PHONY: logs-stop
logs-stop:
	@echo "Stopping background logging processes..."
	@pkill -f "esphome logs.*$(NODE_NAME)" 2>/dev/null || echo "No logging processes found"

# Interactive logs (old behavior, blocks terminal)
.PHONY: logs-interactive
logs-interactive:
	@echo Streaming logs from $(NODE_NAME)...
	@cd $(PROJECT_ROOT) && esphome logs $(RELATIVE_BUILD_PATH)

# Start fresh logging session and follow immediately (session-specific logs)
.PHONY: logs-fresh
logs-fresh: logs
	@if [ ! -d logs ]; then \
		echo "Creating logs directory..."; \
		mkdir -p logs; \
	fi
	@echo "Following fresh log session ($(LOGFILE))..."
	@tail -f logs/$(NODE_NAME).log

# Build, upload, start logging, then follow logs in one step
.PHONY: run
run: check-secrets build upload logs logs-follow

# Display chipset information and capabilities
.PHONY: chip-info
chip-info: _esptool
	@echo "Reading $(PLATFORM) information via $(UPLOAD_PATH)..."
	@$(ESPTOOL_CMD) chip_id

# Display flash memory information and layout
.PHONY: flash-info
flash-info: _esptool
	@echo "Reading flash memory information via $(UPLOAD_PATH)..."
	@$(ESPTOOL_CMD) flash_id

# Verify flash contents against current firmware build
.PHONY: flash-verify
flash-verify: build
	@echo "Verifying flash contents against current firmware build..."
	@FIRMWARE_PATH="$(BUILD_DIR)/.esphome/build/$(NODE_NAME)/firmware.bin"; \
	if [ -f "$$FIRMWARE_PATH" ]; then \
		echo "Using firmware binary: $$FIRMWARE_PATH"; \
		echo "Comparing flash contents with built firmware..."; \
		$(PYTHON_WITH_ESPTOOL) -m esptool --chip $(PLATFORM) --port $(UPLOAD_PATH) verify_flash 0x0 "$$FIRMWARE_PATH" || \
		echo -e "$(ERROR) Flash verification failed - contents do not match firmware binary"; \
	fi

# Erase the entire flash memory of the chipset
.PHONY: flash-erase
flash-erase: _esptool
	@echo "Erasing flash memory on $(NODE_NAME) via $(UPLOAD_PATH)..."
	@echo "WARNING: This will completely erase all firmware and data!"
	@echo "Press Ctrl+C within 5 seconds to cancel..."
	@sleep 5
	@$(ESPTOOL_CMD) erase_flash


# ------------------------------------------------------------------------------
# Documentation Targets
# ------------------------------------------------------------------------------

# Documentation Targets (ESPHome only)

docs-esphome:
	@echo "Generating ESPHome documentation from device configuration..."
	@mkdir -p docs/esphome/$(VARIANT)
	@if [ -f "$(BUILD_DIR)/$(NODE_NAME)/$(NODE_NAME).yaml" ]; then \
		esphome compile $(RELATIVE_BUILD_PATH) --only-generate > docs/esphome/$(VARIANT)/$(NODE_NAME)-config.txt 2>&1 || echo "[WARN] Failed to generate docs for $(NODE_NAME).yaml"; \
	else \
		$(MAKE) _build; \
		esphome compile $(RELATIVE_BUILD_PATH) --only-generate > docs/esphome/$(VARIANT)/$(NODE_NAME)-config.txt 2>&1 || echo "[WARN] Failed to generate docs for $(NODE_NAME).yaml"; \
	fi
	@for file in $(SRC_FILES); do \
		name=$$(basename $$file .yaml); \
		echo "→ $$file"; \
		echo "# ESPHome Component: $$name" > docs/esphome/$(VARIANT)/$$name-component.txt; \
		echo "# Source: $$file" >> docs/esphome/$(VARIANT)/$$name-component.txt; \
		echo "# Generated: $$(date)" >> docs/esphome/$(VARIANT)/$$name-component.txt; \
		echo "" >> docs/esphome/$(VARIANT)/$$name-component.txt; \
		cat $$file >> docs/esphome/$(VARIANT)/$$name-component.txt; \
	done
	@echo "ESPHome documentation saved to docs/esphome/$(VARIANT)/"


# MkDocs documentation build target
.PHONY: docs-mkdoc
docs-mkdoc:
	@echo "Preparing documentation files for MkDocs..."
	@mkdir -p docs/mkdocs
	# Copy or stub all Markdown files from MD_FILES
	@for f in $(MD_FILES); do \
		base=$$(basename $$f); \
		cp -f "$$f" docs/mkdocs/ 2>/dev/null || echo "# Stub for $$base" > docs/mkdocs/$$base; \
	done
	# Generate .md files for all variants listed in mkdocs.yml nav
	@for variant in phb-pro phb-pro-max phb-std; do \
		yaml="variants/$$variant/main.yaml"; \
		md="docs/mkdocs/$$variant.md"; \
		if [ -f "$$yaml" ]; then \
			echo "# Variant: $$variant" > "$$md"; \
			echo "# Source: $$yaml" >> "$$md"; \
			echo "# Generated: $$(date)" >> "$$md"; \
			echo "" >> "$$md"; \
			cat "$$yaml" >> "$$md"; \
		else \
			echo "# Stub for $$variant" > "$$md"; \
			echo "# Source: $$yaml (not found)" >> "$$md"; \
		fi \
	done
	# Generate .md files for all other SRC_FILES
	@for yaml in $(SRC_FILES); do \
		comp=$$(basename $$yaml .yaml); \
		md="docs/mkdocs/$${comp}.md"; \
		echo "# Component: $$comp" > "$$md"; \
		echo "# Source: $$yaml" >> "$$md"; \
		echo "# Generated: $$(date)" >> "$$md"; \
		echo "" >> "$$md"; \
		cat "$$yaml" >> "$$md"; \
	done
	@echo "Building MkDocs documentation site into docs/html..."
	@mkdocs build --clean --config-file docs/mkdocs.yml
	@echo "MkDocs site built at docs/html/index.html"
	@echo "Cleaning up copied documentation files..."
	@rm -f docs/mkdocs/*.md

# Generate all documentation (ESPHome only)
.PHONY: docs
docs: docs-esphome docs-mkdoc


# ------------------------------------------------------------------------------
# Cleanup Targets
# Note: These targets are not dependent on the generated configuration file and
#       may be called at any time, including after `distclean`.
# ------------------------------------------------------------------------------

# Remove temporary build artifacts and logs

.PHONY: clean
clean:
	@echo "Cleaning build artifacts (build.log, .sedargs)..."
	@rm -f build.log .sedargs
	@echo "Cleaning build directory ($(BUILD_DIR))..."
	@sh -c '$(call SAFE_RM,$(BUILD_DIR))'
	@echo "Cleaning logs for $(NODE_NAME)..."
	@rm -f logs/$(NODE_NAME).log logs/$(NODE_NAME)-*.log
	@echo "Cleaning generated documentation for variant ($(VARIANT))..."
	@sh -c '$(call SAFE_RM,docs/esphome/$(VARIANT))'


# Remove ESPHome build cache and compiled objects
.PHONY: clean-cache
clean-cache: clean
	@echo "Removing ESPHome build cache..."
	@-sh -c '$(call SAFE_RM,$(BUILD_DIR)/.esphome)'

# Remove generated documentation files (ESPHome and MkDocs)
.PHONY: clean-docs
clean-docs:
	@echo "Cleaning documentation files..."
	@-sh -c '$(call SAFE_RM,docs/esphome)'
	@-sh -c '$(call SAFE_RM,docs/mkdocs)'
	@-sh -c '$(call SAFE_RM,docs/html)'

# Remove entire device directory (generated YAML + all build artifacts)
.PHONY: clobber
clobber: clean-cache clean-docs
	@echo "Clobbering device build directory..."
	@-sh -c '$(call SAFE_RM,$(BUILD_DIR))'

# Remove all generated content for fresh start

.PHONY: distclean
distclean: clean-docs
	@echo "Performing complete cleanup for archive/export..."
	@-rm -f $(CONFIG) .sedargs build.log 2>/dev/null || true
	@-sh -c '$(call SAFE_RM,build)' 2>/dev/null || true
	@-sh -c '$(call SAFE_RM,logs)' 2>/dev/null || true
	@set -- */; \
	if [ "$$1" != "*/" ]; then \
		(set +e; for dir in "$@"; do \
			[ -d "$$dir" ] && sh -c '$(call SAFE_RM,$$dir)' || true; \
		done); \
	fi
	@echo "Distclean complete - workspace ready for archive"


# ------------------------------------------------------------------------------
# Test Targets
# ------------------------------------------------------------------------------

# Regression test: check for required files and utility targets
.PHONY: regression-test
regression-test:
	@$(TEST_SCRIPT)


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
	@echo "Max Controllers: $(if $(NUM_PORTS),$(NUM_PORTS),[ MISSING ])"
	@echo "Upload path....: $(if $(UPLOAD_PATH),$(UPLOAD_PATH),[ MISSING ])"
	@echo "WiFi IP........: $(if $(STATIC_STATIC_IP),$(STATIC_STATIC_IP),[ dynamic ])"
	@echo "WiFi Gateway...: $(if $(STATIC_GATEWAY),$(STATIC_GATEWAY),[ dynamic ])"
	@echo "WiFi Subnet....: $(if $(STATIC_SUBNET),$(STATIC_SUBNET),[ dynamic ])"
	@echo "WiFi DNS1......: $(if $(STATIC_DNS1),$(STATIC_DNS1),[ dynamic ])"
	@echo "WiFi DNS2......: $(if $(STATIC_DNS2),$(STATIC_DNS2),[ dynamic ])"
	@echo "Network Name...: $(if $(OTA_NAME),$(OTA_NAME),[ dynamic ])"
	@echo "Serial ID......: $(if $(SERIAL_ID),$(SERIAL_ID),[ NOT SET ])"
	@echo "Build Directory: $(if $(DEVICE_NAME),$(BUILD_DIR),[ NOT_SET ])"
	@echo "Upload Path....: $(if $(DEVICE_NAME),$(UPLOAD_PATH),[ NOT_SET ])"
	@echo "Log File........: $(if $(DEVICE_NAME),$(LOGFILE),[ NOT_SET ])"


# Print a list of available Makefile targets and descriptions
.PHONY: help
help:
	@echo "================================================================================"
	@echo "|                            AVAILABLE TARGETS                                 |"
	@echo "================================================================================"
	@echo ""
	@echo "Build Targets:"
	@echo "  build               Compile firmware (output to build.log)"
	@echo ""
	@echo "Platform Targets:"
	@echo "  flash-erase         Erase entire PLATFORM flash memory (CAREFUL: destructive!)"
	@echo "  chip-info           Display PLATFORM chip information and capabilities"
	@echo "  flash-info          Display flash memory information and layout"
	@echo "  flash-verify        Verify flash contents against current firmware build"
	@echo "  upload              Upload firmware to device"
	@echo "  logs                Start background logging (creates logs/DEVICE.log symlink)"
	@echo "  logs-fresh          Start fresh session-specific logging + follow immediately"
	@echo "  logs-follow         Follow logs in real-time using symlink"
	@echo "  logs-stop           Stop background logging processes"
	@echo "  logs-interactive    Interactive logs (blocks terminal)"
	@echo "  run                 Build, upload, and stream logs"
	@echo ""
	@echo "Documentation Targets:"
	@echo "  docs                Generate all documentation (ESPHome)"
	@echo "  docs-esphome        Generate ESPHome style documentation"
	@echo "  docs-mkdoc          Generate MkDocs style documentation"
	@echo ""
	@echo "Cleanup Targets:"
	@echo "  clean               Remove temporary build artifacts and logs"
	@echo "  clean-cache         Remove ESPHome build cache"
	@echo "  clean-docs          Remove all generated documentation (ESPHome)"
	@echo "  clobber             Remove entire device directory and documentation"
	@echo "  distclean           Complete cleanup for archive/export"
	@echo ""
	@echo "Test Targets:"
	@echo "  regression-test     Run regression tests on all device YAMLs"
	@echo ""
	@echo "Utility Targets:"
	@echo "  version             Show platform and ESPHome version"
	@echo "  buildvars           Show current build configuration values"
	@echo "  help                Show this message"


# ------------------------------------------------------------------------------
# Helper Targets
# Note: These targets are meant for use by the Build and Utility targets.
#       They are niot typiocally invoked directly by users.
# ------------------------------------------------------------------------------

# Ensure that secrets.yaml is present before running targets that require secrets
.PHONY: _secrets
check-secrets:
	@if [ ! -f $(SECRETS_FILE) ]; then \
		echo -e "$(ERROR) $(SECRETS_FILE) not found!"; \
		echo "Please copy $(SECRETS_TEMPLATE_FILE) to $(SECRETS_FILE) and fill in your credentials."; \
		exit 1; \
	fi

# Ensure that $(VERSION) is defined before dependent targets run
.PHONY: _version
_version:
	@if [ -z "$(VERSION)" ]; then \
		echo -e "$(ERROR) VERSION variable is not set!"; \
		echo "Please ensure the VERSION file exists and contains a valid version string."; \
		exit 1; \
	fi

# Check that PYTHON_WITH_ESPTOOL is set, or fail with a clear error
.PHONY: _esptool
_esptool:
	@if [ -z "$(PYTHON_WITH_ESPTOOL)" ]; then \
		echo -e "$(ERROR) PYTHON_WITH_ESPTOOL is not set!"; \
		echo "Set it in your environment or pass it inline, e.g.:'"; \
		echo "  PYTHON_WITH_ESPTOOL=/cygdrive/c/Users/youruser/AppData/Local/Programs/Python/Python311/python.exe make chip-info"; \
		exit 1; \
	fi

# Generate device/node YAML from project source YAML
.PHONY: _build
_build: _version _secrets
	@echo "Generating $(BUILD_DIR)/$(NODE_NAME).yaml from $(YAML_MAIN)..."
	@mkdir -p $(BUILD_DIR)
	@echo "s|__PROJECT_ROOT__|../../..|g" > .sedargs
	@echo "s|__VERSION__|$(VERSION)|g" >> .sedargs
	@echo "s|__VARIANT__|$(VARIANT)|g" >> .sedargs
	@echo "s|__PLATFORM__|$(PLATFORM)|g" >> .sedargs
	@echo "s|__DEVICE_NAME__|$(DEVICE_NAME)|g" >> .sedargs
	@echo "s|__NODE_NAME__|$(NODE_NAME)|g" >> .sedargs
	@echo "s|__FRIENDLY_NAME__|$(FRIENDLY_NAME)|g" >> .sedargs
	@echo "s|__NUM_PORTS__|$(NUM_PORTS)|g" >> .sedargs
	@echo "s|__UPLOAD_PATH__|$(UPLOAD_PATH)|g" >> .sedargs
	@echo "s|__STATIC_STATIC_IP__|$(STATIC_STATIC_IP)|g" >> .sedargs
	@echo "s|__STATIC_GATEWAY__|$(STATIC_GATEWAY)|g" >> .sedargs
	@echo "s|__STATIC_SUBNET__|$(STATIC_SUBNET)|g" >> .sedargs
	@echo "s|__STATIC_DNS1__|$(STATIC_DNS1)|g" >> .sedargs
	@echo "s|__STATIC_DNS2__|$(STATIC_DNS2)|g" >> .sedargs
	@echo "s|__OTA_NAME__|$(OTA_NAME)|g" >> .sedargs
	@echo "s|__SERIAL_ID__|$(SERIAL_ID)|g" >> .sedargs
	@sed -f .sedargs < $(YAML_MAIN) > $(BUILD_DIR)/$(NODE_NAME).yaml
	@rm -f .sedargs
	# Copy icons directory if it exists
	@if [ -d icons ]; then \
		echo "Copying icons/ to $(BUILD_DIR)/icons..."; \
		cp -r icons $(BUILD_DIR)/; \
	fi
	# Copy common directory if it exists
	@if [ -d common ]; then \
		echo "Copying common/ to $(BUILD_DIR)/common..."; \
		cp -r common $(BUILD_DIR)/; \
	fi
