# ------------------------------------------------------------------------------
#  file        Makefile
#  brief       Master Makefile for ESPHome-based device management
#  version     0.6.7
#  date        2025-07-18
#  details     This Makefile drives the build, upload, and configuration
#              process for ESPHome projects. It leverages a configuration file
#              for per-device definitions and includes safety mechanisms to
#              prevent destructive errors.
#
#  author      Roland Tembo Hendel
#  email       rhendel@nexuslogic.com
#
#  license     GNU General Public License v3.0
#              SPDX-License-Identifier: GPL-3.0-or-later
#  copyright   Copyright (c) 2025 Roland Tembo Hendel
#              This program is free software: you can redistribute it and/or
#              modify it under the terms of the GNU General Public License
#              as published by the Free Software Foundation, either version 3
#              of the License, or (at your option) any later version.
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Global Configuration
# ------------------------------------------------------------------------------

# Load project version string
VERSION       ?= $(shell cat VERSION)

# Project root directory (no trailing slash)
PROJECT_ROOT  := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# Default target - full pipeline: build + upload + logs
.DEFAULT_GOAL := run

# Load per-device config if available
#   note: we'll generate this if we need it and it doesn't exist
CONFIG ?= $(PROJECT_ROOT)/Makefile.in
-include $(CONFIG)


# ------------------------------------------------------------------------------
# Pre-Build Configuration and Targets
# ------------------------------------------------------------------------------

# Project-wide file variables
CONFIG_SCRIPT    := $(PROJECT_ROOT)/configure.sh
TEST_SCRIPT      := $(PROJECT_ROOT)/regression-test.sh
SRC_DIRS         := $(PROJECT_ROOT) $(PROJECT_ROOT)/common
SECRETS_FILE     := $(PROJECT_ROOT)/common/secrets.yaml
SECRETS_TEMPLATE := $(PROJECT_ROOT)/common/secrets.template.yaml
MAIN             ?= $(PROJECT_ROOT)/main.yaml
YAML_MAIN        := $(MAIN)
BUILD_DIR 	     := $(PROJECT_ROOT)/build/$(NODE_NAME)
RUN_LOGFILE      ?= $(PROJECT_ROOT)/logs/$(NODE_NAME)-$(shell date +%Y%m%d_%H%M%S).log
BUILD_LOGFILE	 ?= $(PROJECT_ROOT)/build.log
YAML_FILES       := $(filter-out %/secrets.yaml, $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.yaml)))
MD_FILES         := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.md))

# Ensure that secrets.yaml is present before running targets that require secrets
.PHONY: check-secrets
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

# Ensure that $(CONFIG) is present before dependent targets run
.PHONY: _configuration_file
_configuration_file:
	@if [ ! -f $(CONFIG) ]; then \
		echo "$(CONFIG) not found. Running $(CONFIG_SCRIPT) to generate it..."; \
		$(CONFIG_SCRIPT); \
		if [ -z "$$MAKEFILE_RELOADED" ]; then \
			echo "Reloading Makefile to pick up new variables..."; \
			MAKEFILE_RELOADED=1 $(MAKE) $(MAKECMDGOALS); \
			exit 0; \
		fi; \
	fi

# Check that PYTHON_WITH_ESPTOOL is set, or fail with a clear error
.PHONY: check-esptool-python
check-esptool-python:
	@if [ -z "$(PYTHON_WITH_ESPTOOL)" ]; then \
		echo -e "$(ERROR) PYTHON_WITH_ESPTOOL is not set!"; \
		echo "Set it in your environment or pass it inline, e.g.:'"; \
		echo "  PYTHON_WITH_ESPTOOL=/cygdrive/c/Users/youruser/AppData/Local/Programs/Python/Python311/python.exe make chip-info"; \
		exit 1; \
	fi

# Run interactive configuration script to generate $(CONFIG) and YAML
.PHONY: configure
configure:
	@$(CONFIGURE_SCRIPT)

# Generate device/node YAML from project source YAML
.PHONY: generate
generate: _version _configuration_file
	@echo "Generating device YAML from $(YAML_MAIN)..."
	@mkdir -p $(BUILD_DIR)
	@awk -F '=' 'NF==2 && $$1 !~ /^#/ && $$1 !~ /^$$/ { \
		gsub(/^[ \t]+|[ \t]+$$/, "", $$1); \
		gsub(/^[ \t]+|[ \t]+$$/, "", $$2); \
		key=$$1; val=$$2; \
		gsub(/[\/|]/, "\\&", val); \
		print "s|__" key "__|" val "|g" \
	}' $(CONFIG) > .sedargs
	@sed -f .sedargs < $(YAML_MAIN) > $(BUILD_DIR)/$(NODE_NAME).yaml
	@rm -f .sedargs


# ------------------------------------------------------------------------------
# Build/Platform Targets
# ------------------------------------------------------------------------------

# Compile the ESPHome firmware for the specified device
.PHONY: build
build: check-secrets generate
	@echo Building firmware for $(NODE_NAME)...
	@$(call ESPHOME_CMD,compile,2>&1 | tee build.log)

# Erase the entire flash memory of the chipset
.PHONY: flash-erase
flash-erase: check-esptool-python _configuration_file
	@echo "Erasing flash memory on $(NODE_NAME) via $(UPLOAD_PATH)..."
	@echo "WARNING: This will completely erase all firmware and data!"
	@echo "Press Ctrl+C within 5 seconds to cancel..."
	@sleep 5
	@$(ESPTOOL_CMD) erase_flash

# Display chipset information and capabilities
.PHONY: chip-info
chip-info: check-esptool-python _configuration_file
	   @echo "Reading $(PLATFORM) information via $(UPLOAD_PATH)..."
	   @$(ESPTOOL_CMD) chip_id

# Display flash memory information and layout
.PHONY: flash-info
flash-info: check-esptool-python _configuration_file
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
	else \
		echo -e "$(ERROR) Firmware binary not found at $$FIRMWARE_PATH"; \
		echo "Try running 'make build' first to generate the firmware binary"; \
		exit 1; \
	fi

# Upload the compiled firmware to the device (USB or OTA)
.PHONY: upload
upload: check-secrets _configuration_file
	@echo Uploading firmware to $(NODE_NAME)...
	@$(call ESPHOME_CMD,upload,--device $(UPLOAD_PATH))

# Record logs from the device
.PHONY: logs
logs: check-secrets _configuration_file
	@if [ ! -d logs ]; then \
		echo "Creating logs directory..."; \
		mkdir -p logs; \
	fi
	@echo "Stopping any existing logging sessions..."
	@pkill -f "esphome logs.*$(NODE_NAME)" 2>/dev/null || echo "No previous logging processes found"
	@echo "Starting fresh logging session to $(LOGFILE)..."
	@$(call ESPHOME_CMD,logs,> $(LOGFILE) 2>&1 &)
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
logs-interactive: _configuration_file
	@echo Streaming logs from $(NODE_NAME)...
	@$(call ESPHOME_CMD,logs,)

# Start fresh logging session and follow immediately (session-specific logs)
.PHONY: logs-fresh
logs-fresh: logs
	@if [ ! -d logs ]; then \
		echo "Creating logs directory..."; \
		mkdir -p logs; \
	fi
	@echo "Following fresh log session ($(RUN_LOGFILE))..."
	@tail -f logs/$(NODE_NAME).log

# Build, upload, start logging, then follow logs in one step
.PHONY: run
run: check-secrets build upload logs
	$(MAKE) logs-follow


# ------------------------------------------------------------------------------
# Documentation Targets
# ------------------------------------------------------------------------------

# Documentation Targets (ESPHome only)
.PHONY: docs-esphome
docs-esphome: _configuration_file
	@echo "Generating ESPHome documentation from device configuration..."
	@mkdir -p docs/esphome
	@WIN_YAML=$(shell cygpath -m $(BUILD_DIR)/$(NODE_NAME).yaml); \
	if [ -f "$$WIN_YAML" ]; then \
		$(call ESPHOME_CMD,compile,--only-generate > docs/esphome/$(NODE_NAME)-config.txt 2>&1 || echo "[WARN] Failed to generate docs for $(NODE_NAME).yaml"); \
	else \
		$(MAKE) generate; \
		$(call ESPHOME_CMD,compile,--only-generate > docs/esphome/$(NODE_NAME)-config.txt 2>&1 || echo "[WARN] Failed to generate docs for $(NODE_NAME).yaml"); \
	fi
	for file in $(YAML_FILES); do \
		name=$$(basename $$file .yaml); \
		echo "→ $$file"; \
		echo "# ESPHome Component: $$name" > docs/esphome/$$name-component.txt; \
		echo "# Source: $$file" >> docs/esphome/$$name-component.txt; \
		echo "# Generated: $$(date)" >> docs/esphome/$$name-component.txt; \
		echo "" >> docs/esphome/$$name-component.txt; \
		cat $$file >> docs/esphome/$$name-component.txt; \
	done
	@echo "ESPHome documentation saved to docs/esphome/"

# MkDocs documentation build target
.PHONY: docs-mkdoc
docs-mkdoc:
	@echo "Preparing documentation files for MkDocs..."
	@mkdir -p docs/mkdocs
	# Copy or stub all Markdown files from MD_FILES
	for f in $(MD_FILES); do \
		base=$$(basename $$f); \
		cp -f "$$f" docs/mkdocs/ 2>/dev/null || echo "# Stub for $$base" > docs/mkdocs/$$base; \
	done
	# Generate .md files for all YAML_FILES
	for yaml in $(YAML_FILES); do \
		comp=$$(basename $$yaml .yaml); \
		md="docs/mkdocs/$${comp}.md"; \
		echo "# Component: $$comp" > "$$md"; \
		echo "# Source: $$yaml" >> "$$md"; \
		echo "# Generated: $$(date)" >> "$$md"; \
		echo "" >> "$$md"; \
		cat "$$yaml" >> "$$md"; \
	done
	@echo "Building MkDocs documentation site into docs/html..."
	mkdocs build --clean --config-file docs/mkdocs.yml
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
	@echo "Cleaning temporary build artifacts..."
	@rm -f build.log .sedargs
	@if [ -n "$(BUILD_DIR)" ] && [ "$(call is_protected_dir,$(BUILD_DIR))" = "no" ]; then \
		if [ -f "$(BUILD_DIR)/$(NODE_NAME).yaml" ]; then \
			echo "Removing generated YAML: $(BUILD_DIR)/$(NODE_NAME).yaml"; \
			@rm -f "$(BUILD_DIR)/$(NODE_NAME).yaml"; \
		fi; \
		if [ -d "$(BUILD_DIR)/.esphome" ]; then \
			echo "Cleaning ESPHome cache in $(NODE_NAME)/.esphome/"; \
			@find "$(BUILD_DIR)/.esphome" -name "*.bin" -o -name "*.elf" -o -name "*.map" -o -name "*.json" | head -20 | xargs rm -f; \
		fi; \
		if [ -L "logs/$(NODE_NAME).log" ]; then \
			echo "Removing latest log symlink: logs/$(NODE_NAME).log"; \
			@rm -f "logs/$(NODE_NAME).log"; \
		fi; \
	else \
		echo "[WARN] NODE_NAME not set or protected - skipping node-build cleanup"; \
	fi
	@sh -c '$(call safe_rmrf,$(BUILD_DIR))'


# Remove ESPHome build cache and compiled objects
.PHONY: clean-cache
clean-cache: clean
	@echo "Removing ESPHome build cache..."
	@if [ -n "$(BUILD_DIR)" ] && [ "$(call is_protected_dir,$(BUILD_DIR))" = "no" ]; then \
		if [ -d "$(BUILD_DIR)/.esphome" ]; then \
			@sh -c '$(call safe_rmrf,$(BUILD_DIR)/.esphome)'; \
		fi; \
	fi

# Remove generated documentation files (ESPHome and MkDocs)
.PHONY: clean-docs
clean-docs:
	@echo "Cleaning documentation files..."
	@if [ -d "docs/esphome" ]; then \
		sh -c '$(call safe_rmrf,docs/esphome)' >/dev/null 2>&1; \
	fi
	@sh -c '$(call safe_rmrf,docs/mkdocs)' >/dev/null 2>&1
	@sh -c '$(call safe_rmrf,docs/html)' >/dev/null 2>&1

# Remove entire device directory (generated YAML + all build artifacts)
.PHONY: clobber
clobber: clean clean-docs
	@echo "Clobbering device directory..."
	@if [ -n "$(BUILD_DIR)" ] && [ "$(call is_protected_dir,$(BUILD_DIR))" = "no" ]; then \
		if [ -d "$(BUILD_DIR)" ]; then \
			@sh -c '$(call safe_rmrf,$(BUILD_DIR))'; \
		else \
			echo "Device directory $(BUILD_DIR)/ does not exist"; \
		fi; \
	else \
		echo -e "$(ERROR) Cannot clobber: NODE_NAME='$(NODE_NAME)' is not set or is protected"; \
		exit 1; \
	fi

# Remove all generated content for fresh start
.PHONY: distclean
distclean: clean-docs
	@echo "Performing complete cleanup for archive/export..."
	@rm -f $(CONFIG) .sedargs 2>/dev/null
	@rm -f build.log 2>/dev/null
	@sh -c '$(call safe_rmrf,logs)' >/dev/null 2>&1
	@for dir in */; do \
		if [ -d "$$dir" ] && [ "$(call is_protected_dir,$${dir%/})" = "no" ] && [ -f "$$dir$${dir%/}.yaml" ]; then \
			sh -c '$(call safe_rmrf,$$dir)' >/dev/null 2>&1; \
		fi; \
	 done
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
	@echo "Platform.......: $(if $(PLATFORM),$(PLATFORM),[ MISSING ])"
	@echo "Device name....: $(if $(DEVICE_NAME),$(DEVICE_NAME),[ MISSING ])"
	@echo "Node name......: $(if $(NODE_NAME),$(NODE_NAME),[ MISSING ])"
	@echo "Friendly name..: $(if $(FRIENDLY_NAME),$(FRIENDLY_NAME),[ MISSING ])"
	@echo "Upload path....: $(if $(UPLOAD_PATH),$(UPLOAD_PATH),[ MISSING ])"
	@echo "WiFi IP........: $(if $(WIFI_STATIC_IP),$(WIFI_STATIC_IP),[ dynamic ])"
	@echo "WiFi Gateway...: $(if $(WIFI_GATEWAY),$(WIFI_GATEWAY),[ dynamic ])"
	@echo "WiFi Subnet....: $(if $(WIFI_SUBNET),$(WIFI_SUBNET),[ dynamic ])"
	@echo "WiFi DNS1......: $(if $(WIFI_DNS1),$(WIFI_DNS1),[ dynamic ])"
	@echo "WiFi DNS2......: $(if $(WIFI_DNS2),$(WIFI_DNS2),[ dynamic ])"
	@echo "BUILD DIRECTORY: $(if $(DEVICE_NAME),$(BUILD_DIR),[ NOT_SET ])"
	@echo "BUILD_LOGFILE..: $(if $(DEVICE_NAME),$(BUILD_LOGFILE),[ NOT_SET ])"
	@echo "RUN_LOGFILE....: $(if $(DEVICE_NAME),$(RUN_LOGFILE),[ NOT_SET ])"


# Print a list of available Makefile targets and descriptions
.PHONY: help
help:
	@echo "================================================================================"
	@echo "|                            AVAILABLE TARGETS                                 |"
	@echo "================================================================================"
	@echo ""
	@echo "Build Targets:"
	@echo "  configure           Generate configuration (Makefile.in and YAML)"
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
# Helper Functions
# ------------------------------------------------------------------------------

# Macro: Safe recursive delete
PROTECTED_DIRS := / ~ ./ $(PROJECT_ROOT)/common $(PROJECT_ROOT)/config $(PROJECT_ROOT)/docs $(PROJECT_ROOT)/icons
define is_protected_dir
$(if $(filter $(1),$(PROTECTED_DIRS)),yes,no)
endef
safe_rmrf = \
	if [ -z "$1" ]; then \
		echo "[SAFE_RM] Refusing to delete: directory not specified"; \
	elif [ "$(call is_protected_dir,$1)" = "yes" ]; then \
		echo "[SAFE_RM] Refusing to delete protected directory: $1"; \
	else \
		echo "[SAFE_RM] Deleting directory: $1"; \
		rm -rf "$1"; \
	fi

# Detect Windows (Cygwin/MINGW) for path conversion
UNAME_S := $(shell uname -s)
ifeq ($(findstring CYGWIN,$(UNAME_S)),CYGWIN)
	WIN_CMD = 1
else ifeq ($(findstring MINGW,$(UNAME_S)),MINGW)
	WIN_CMD = 1
else
	WIN_CMD = 0
endif

# Auto-detect Python executable with esptool module
#   Windows users: If esptool is only available in your Windows Python, override this variable in your environment:
#   export PYTHON_WITH_ESPTOOL=/cygdrive/c/Users/youruser/AppData/Local/Programs/Python/Python311/python.exe
#   (adjust the path as needed; see Makefile docs for details)
PYTHON_WITH_ESPTOOL ?= $(shell \
	for py in python3 python; do \
		if "$$py" -c "import esptool" 2>/dev/null; then echo "$$py"; break; fi \
	done)

# Macro: Run esptool command via Python (single-line variable for safe recipe expansion)
ESPTOOL_CMD = $(PYTHON_WITH_ESPTOOL) -m esptool --chip $(PLATFORM) --port $(UPLOAD_PATH)

# Macro: Set YAML path (Windows: cygpath -m, else normal path) and run ESPHome command
define ESPHOME_CMD
if [ -n "$(YAML_PATH)" ]; then \
  yaml_path="$(YAML_PATH)"; \
else \
  yaml_path="$(BUILD_DIR)/$(NODE_NAME).yaml"; \
fi; \
if [ "$(WIN_CMD)" = "1" ]; then \
  YAML_PATH=$$(cygpath -m "$$yaml_path"); \
else \
  YAML_PATH="$$yaml_path"; \
fi; \
esphome $(1) $$YAML_PATH $(2)
endef

# Color support detection and color variables
ifeq (,$(findstring dumb,$(TERM)))
  ifneq (,$(TERM))
	COLOR_SUPPORT := 1
  else
	COLOR_SUPPORT := 0
  endif
else
  COLOR_SUPPORT := 0
endif
ifeq ($(COLOR_SUPPORT),1)
  RED    := \033[0;31m
  GREEN  := \033[0;32m
  YELLOW := \033[0;33m
  NC     := \033[0m
else
  RED    :=
  GREEN  :=
  YELLOW :=
  NC     :=
endif
FAIL  := $(YELLOW)[FAIL]$(NC)
ERROR := $(RED)[ERROR]$(NC)
OK    := $(GREEN)[OK]$(NC)
