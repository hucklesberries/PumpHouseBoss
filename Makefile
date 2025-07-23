# ------------------------------------------------------------------------------
#  file        Makefile
#  brief       Master Makefile for ESPHome-based device management
#  version     0.6.6
#  date        2025-07-18
#  details     This Makefile drives the build, upload, and configuration
#              process for ESPHome projects. It leverages a .makefile for per-device
#              definitions and includes safety mechanisms to prevent destructive errors.
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
# Pre-Build Configuration and Targets
# ------------------------------------------------------------------------------

# Load project version string
VERSION              := $(shell cat VERSION)

# Project-wide file variables
CONFIGURATION_FILE   := .makefile
CONFIGURATION_SCRIPT := ./configure.sh
SRC_DIRS             := . ./common
YAML_FILES           := $(filter-out %/secrets.yaml, $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.yaml)))
MD_FILES             := $(foreach dir,$(SRC_DIRS),$(wildcard $(dir)/*.md))
SECRETS_FILE         := ./common/secrets.yaml
SECRETS_TEMPLATE     := ./common/secrets.template.yaml
YAML_MAIN            := main.yaml
LOGFILE              ?= logs/$(DEVICE_NAME)-$(shell date +%Y%m%d_%H%M%S).log

# Default target - full pipeline: build + upload + logs
.DEFAULT_GOAL        := run

# Auto-detect Python executable with esptool module
PYTHON_WITH_ESPTOOL := $(shell \
	for py in python3 python; do \
		if "$$py" -c "import esptool" 2>/dev/null; then echo "$$py"; break; fi \
	done)

# Load per-device config if available
-include $(CONFIGURATION_FILE)

# Ensure that secrets.yaml is present before running targets that require secrets
.PHONY: check-secrets
check-secrets:
	@if [ ! -f $(SECRETS_FILE) ]; then \
		echo "[ERROR] $(SECRETS_FILE) not found!"; \
		echo "Please copy $(SECRETS_TEMPLATE_FILE) to $(SECRETS_FILE) and fill in your credentials."; \
		exit 1; \
	fi

# Ensure that $(CONFIGURATION_FILE) is present before dependent targets run
.PHONY: _configuration_file
_configuration_file:
	   @if [ ! -f $(CONFIGURATION_FILE) ]; then \
			   echo "$(CONFIGURATION_FILE) not found. Running $(CONFIGURATION_SCRIPT) to generate it..."; \
			   $(CONFIGURATION_SCRIPT); \
			   if [ -z "$$MAKEFILE_RELOADED" ]; then \
					   echo "Reloading Makefile to pick up new variables..."; \
					   MAKEFILE_RELOADED=1 $(MAKE) $(MAKECMDGOALS); \
					   exit 0; \
			   fi; \
	   fi

# Run interactive configuration script to generate $(CONFIGURATION_FILE) and YAML
.PHONY: configure
configure:
	@$(CONFIGURE_SCRIPT)

# Generate device/node YAML from project source YAML
.PHONY: generate
generate: _configuration_file
	@echo "Generating device YAML from $(YAML_MAIN)..."
	@mkdir -p $(DEVICE_NAME)
	@awk -F '=' 'NF==2 && $$1 !~ /^#/ && $$1 !~ /^$$/ { \
		gsub(/^[ \t]+|[ \t]+$$/, "", $$1); \
		gsub(/^[ \t]+|[ \t]+$$/, "", $$2); \
		key=$$1; val=$$2; \
		gsub(/[\/|]/, "\\\\&", val); \
		print "s|__" key "__|" val "|g" \
	}' $(CONFIGURATION_FILE) > .sedargs
	@sed -f .sedargs < $(YAML_MAIN) > $(DEVICE_NAME)/$(DEVICE_NAME).yaml
	@rm -f .sedargs

# ------------------------------------------------------------------------------
# Build Targets
# ------------------------------------------------------------------------------
 
# Compile the ESPHome firmware for the specified device
.PHONY: build
build: check-secrets generate
	@echo Building firmware for $(DEVICE_NAME)...
	@esphome compile $(DEVICE_NAME)/$(DEVICE_NAME).yaml 2>&1 | tee build.log


# ------------------------------------------------------------------------------
# Platform Targets
# ------------------------------------------------------------------------------
 
# Erase the entire flash memory of the ESP32-S3
.PHONY: flash-erase
flash-erase: _configuration_file
	@echo "Erasing flash memory on $(DEVICE_NAME) via $(UPLOAD_PATH)..."
	@echo "WARNING: This will completely erase all firmware and data!"
	@echo "Press Ctrl+C within 5 seconds to cancel..."
	@sleep 5
	@$(PYTHON_WITH_ESPTOOL) -m esptool --chip esp32s3 --port $(UPLOAD_PATH) erase_flash

# Display ESP32-S3 chip information and capabilities
.PHONY: chip-info
chip-info: _configuration_file
	@echo "Reading ESP32-S3 chip information via $(UPLOAD_PATH)..."
	@$(PYTHON_WITH_ESPTOOL) -m esptool --chip esp32s3 --port $(UPLOAD_PATH) chip_id

# Display flash memory information and layout
.PHONY: flash-info
flash-info: _configuration_file
	@echo "Reading flash memory information via $(UPLOAD_PATH)..."
	@$(PYTHON_WITH_ESPTOOL) -m esptool --chip esp32s3 --port $(UPLOAD_PATH) flash_id

# Verify flash contents against current firmware build
.PHONY: flash-verify
flash-verify: build
	@echo "Verifying flash contents against current firmware build..."
	@FIRMWARE_PATH="$(DEVICE_NAME)/.esphome/build/$(DEVICE_NAME)/firmware.bin"; \
	if [ -f "$$FIRMWARE_PATH" ]; then \
		echo "Using firmware binary: $$FIRMWARE_PATH"; \
		echo "Comparing flash contents with built firmware..."; \
		$(PYTHON_WITH_ESPTOOL) -m esptool --chip esp32s3 --port $(UPLOAD_PATH) verify_flash 0x0 "$$FIRMWARE_PATH" || \
		echo "[ERROR] Flash verification failed - contents do not match firmware binary"; \
	else \
		echo "[ERROR] Firmware binary not found at $$FIRMWARE_PATH"; \
		echo "Try running 'make build' first to generate the firmware binary"; \
		exit 1; \
	fi

# Upload the compiled firmware to the device (USB or OTA)
.PHONY: upload
upload: check-secrets _configuration_file
	@echo Uploading firmware to $(DEVICE_NAME)...
	@esphome upload $(DEVICE_NAME)/$(DEVICE_NAME).yaml --device $(UPLOAD_PATH)

# View live log output from the device
.PHONY: logs
logs: check-secrets _configuration_file
	@if [ ! -d logs ]; then \
		echo "Creating logs directory..."; \
		mkdir -p logs; \
	fi
	@echo "Stopping any existing logging sessions..."
	@pkill -f "esphome logs.*$(DEVICE_NAME)" 2>/dev/null || echo "No previous logging processes found"
	@echo "Starting fresh logging session to $(LOGFILE)..."
	@esphome logs $(DEVICE_NAME)/$(DEVICE_NAME).yaml > $(LOGFILE) 2>&1 &
	@echo "Creating symlink to latest log file..."
	@cd logs && ln -sf $(shell basename $(LOGFILE)) $(DEVICE_NAME).log
	@echo "Logs are being written to: $(LOGFILE)"
	@echo "Latest log accessible via: logs/$(DEVICE_NAME).log"
	@echo "Use 'tail -f logs/$(DEVICE_NAME).log' to follow logs, or 'make logs-follow' for convenience"
	@echo "Use 'make logs-stop' to stop background logging"

# Follow log output in real-time
.PHONY: logs-follow
logs-follow:
	@if [ ! -d logs ]; then \
		echo "Creating logs directory..."; \
		mkdir -p logs; \
	fi
	@echo "Following logs from logs/$(DEVICE_NAME).log..."
	@if [ ! -f logs/$(DEVICE_NAME).log ]; then \
		echo "[ERROR] Log file logs/$(DEVICE_NAME).log not found. Please run 'make logs' first."; \
		exit 1; \
	fi
	@tail -f logs/$(DEVICE_NAME).log

# Stop background logging
.PHONY: logs-stop  
logs-stop:
	@echo "Stopping background logging processes..."
	@pkill -f "esphome logs.*$(DEVICE_NAME)" 2>/dev/null || echo "No logging processes found"

# Interactive logs (old behavior, blocks terminal)
.PHONY: logs-interactive
logs-interactive: _configuration_file
	@echo Streaming logs from $(DEVICE_NAME)...
	@esphome logs $(DEVICE_NAME)/$(DEVICE_NAME).yaml

# Start fresh logging session and follow immediately (session-specific logs)
.PHONY: logs-fresh
logs-fresh: logs
	@if [ ! -d logs ]; then \
		echo "Creating logs directory..."; \
		mkdir -p logs; \
	fi
	@echo "Following fresh log session ($(LOGFILE))..."
	@tail -f logs/$(DEVICE_NAME).log


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
	@if [ -f "$(DEVICE_NAME)/$(DEVICE_NAME).yaml" ]; then \
		echo "→ $(DEVICE_NAME)/$(DEVICE_NAME).yaml"; \
		esphome compile $(DEVICE_NAME)/$(DEVICE_NAME).yaml --only-generate > docs/esphome/$(DEVICE_NAME)-config.txt 2>&1 || echo "[WARN] Failed to generate docs for $(DEVICE_NAME).yaml"; \
	else \
		echo "Generating device configuration first..."; \
		$(MAKE) generate; \
		echo "→ $(DEVICE_NAME)/$(DEVICE_NAME).yaml"; \
		esphome compile $(DEVICE_NAME)/$(DEVICE_NAME).yaml --only-generate > docs/esphome/$(DEVICE_NAME)-config.txt 2>&1 || echo "[WARN] Failed to generate docs for $(DEVICE_NAME).yaml"; \
	fi
	@echo "Generating component documentation from YAML_FILES..."
	@for file in $(YAML_FILES); do \
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
# Note: These targets are not dependent on the generated .makefile and may be
#       called at any time, including after `distclean`.
# ------------------------------------------------------------------------------

# Define protected directories to prevent accidental deletion
PROTECTED_DIRS := common docs build src include . /

# Helper function to check if a directory is protected
define is_protected_dir
$(if $(filter $(1),$(PROTECTED_DIRS)),yes,no)
endef

# Remove temporary build artifacts and logs
.PHONY: clean
clean:
	@echo "Cleaning temporary build artifacts..."
	@rm -f build.log .sedargs
	@if [ -n "$(DEVICE_NAME)" ] && [ "$(call is_protected_dir,$(DEVICE_NAME))" = "no" ]; then \
		if [ -f "$(DEVICE_NAME)/$(DEVICE_NAME).yaml" ]; then \
			echo "Removing generated YAML: $(DEVICE_NAME)/$(DEVICE_NAME).yaml"; \
			rm -f "$(DEVICE_NAME)/$(DEVICE_NAME).yaml"; \
		fi; \
		if [ -d "$(DEVICE_NAME)/.esphome" ]; then \
			echo "Cleaning ESPHome cache in $(DEVICE_NAME)/.esphome/"; \
			find "$(DEVICE_NAME)/.esphome" -name "*.bin" -o -name "*.elf" -o -name "*.map" -o -name "*.json" | head -20 | xargs rm -f; \
		fi; \
		if [ -L "logs/$(DEVICE_NAME).log" ]; then \
			echo "Removing latest log symlink: logs/$(DEVICE_NAME).log"; \
			rm -f "logs/$(DEVICE_NAME).log"; \
		fi; \
	else \
		echo "[WARN] DEVICE_NAME not set or protected - skipping device-specific cleanup"; \
	fi


# Remove ESPHome build cache and compiled objects
.PHONY: clean-cache
clean-cache: clean
	@echo "Removing ESPHome build cache..."
	@if [ -n "$(DEVICE_NAME)" ] && [ "$(call is_protected_dir,$(DEVICE_NAME))" = "no" ]; then \
		if [ -d "$(DEVICE_NAME)/.esphome" ]; then \
			echo "Removing ESPHome cache: $(DEVICE_NAME)/.esphome/"; \
			rm -rf "$(DEVICE_NAME)/.esphome"; \
		fi; \
	fi

# Remove generated documentation files (ESPHome and MkDocs)
.PHONY: clean-docs
clean-docs:
	   @echo "Cleaning ESPHome documentation files..."
	   @if [ -d "docs/esphome" ]; then \
			   rm -rf docs/esphome; \
			   echo "Removed ESPHome documentation directory"; \
	   else \
			   echo "No ESPHome documentation directory found"; \
	   fi
	   @echo "Cleaning MkDocs documentation files..."
	   rm -rf docs/mkdocs
	   rm -rf docs/html
	   @echo "Removed MkDocs documentation directory."

# Remove entire device directory (generated YAML + all build artifacts)
.PHONY: clobber
clobber: clean clean-docs
	@echo "Clobbering device directory..."
	@if [ -n "$(DEVICE_NAME)" ] && [ "$(call is_protected_dir,$(DEVICE_NAME))" = "no" ]; then \
		if [ -d "$(DEVICE_NAME)" ]; then \
			echo "Removing device directory: $(DEVICE_NAME)/"; \
			rm -rf "$(DEVICE_NAME)"; \
		else \
			echo "Device directory $(DEVICE_NAME)/ does not exist"; \
		fi; \
	else \
		echo "[ERROR] Cannot clobber: DEVICE_NAME='$(DEVICE_NAME)' is not set or is protected"; \
		exit 1; \
	fi

# Remove all generated content for fresh start
.PHONY: distclean
distclean: clean-docs
	@echo "Performing complete cleanup for archive/export..."
	@echo "Removing configuration files..."
	@rm -f .makefile .sedargs
	@echo "Removing build artifacts..."
	@rm -f build.log
	@echo "Removing log files..."
	@rm -rf logs/
	@echo "Scanning for device directories..."
	@for dir in */; do \
		if [ -d "$$dir" ] && [ "$(call is_protected_dir,$${dir%/})" = "no" ] && [ -f "$${dir}$${dir%/}.yaml" ]; then \
			echo "Removing device directory: $$dir"; \
			rm -rf "$$dir"; \
		fi; \
	done
	@echo "Distclean complete - workspace ready for archive"


# ------------------------------------------------------------------------------
# Utility Targets
# Note: These targets are not dependent on the generated .makefile and may be
#       called at any time, including after `distclean`.
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
	@echo "Device name:   $(if $(DEVICE_NAME),$(DEVICE_NAME),[ MISSING ])"
	@echo "Node name:     $(if $(NODE_NAME),$(NODE_NAME),[ MISSING ])"
	@echo "Friendly name: $(if $(FRIENDLY_NAME),$(FRIENDLY_NAME),[ MISSING ])"
	@echo "Upload path:   $(if $(UPLOAD_PATH),$(UPLOAD_PATH),[ MISSING ])"
	@echo "WiFi IP:       $(if $(WIFI_STATIC_IP),$(WIFI_STATIC_IP),[ dynamic ])"
	@echo "WiFi Gateway:  $(if $(WIFI_GATEWAY),$(WIFI_GATEWAY),[ dynamic ])"
	@echo "WiFi Subnet:   $(if $(WIFI_SUBNET),$(WIFI_SUBNET),[ dynamic ])"
	@echo "WiFi DNS1:     $(if $(WIFI_DNS1),$(WIFI_DNS1),[ dynamic ])"
	@echo "WiFi DNS2:     $(if $(WIFI_DNS2),$(WIFI_DNS2),[ dynamic ])"

# Print a list of available Makefile targets and descriptions
.PHONY: help
help:
	@echo "================================================================================"
	@echo "                             AVAILABLE TARGETS"
	@echo "================================================================================"
	@echo ""
	@echo "Build Targets:"
	@echo "  configure           Generate configuration (.makefile and YAML)"
	@echo "  build               Compile firmware (output to build.log)"
	@echo ""
	@echo "Platform Targets:"
	@echo "  flash-erase         Erase entire ESP32-S3 flash memory (WARNING: destructive!)"
	@echo "  chip-info           Display ESP32-S3 chip information and capabilities"
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
	@echo "Utility Targets:"
	@echo "  version             Show platform and ESPHome version"
	@echo "  buildvars           Show current build configuration values"
	@echo "  help                Show this message"