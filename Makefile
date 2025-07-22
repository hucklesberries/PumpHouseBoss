# ------------------------------------------------------------------------------
#  @file        Makefile
#  @brief       Master Makefile for ESPHome-based device management
#  @version     0.6.5
#  @date        2025-07-18
#  @details     This Makefile drives the build, upload, and configuration
#               process for ESPHome projects. It leverages a .makefile for per-device
#               definitions and includes safety mechanisms to prevent destructive errors.
#
#  @author      Roland Tembo Hendel
#  @email       rhendel@nexuslogic.com
#
#  @license     GNU General Public License v3.0
#               SPDX-License-Identifier: GPL-3.0-or-later
#  @copyright   Copyright (c) 2025 Roland Tembo Hendel
#               This program is free software: you can redistribute it and/or
#               modify it under the terms of the GNU General Public License
#               as published by the Free Software Foundation, either version 3
#               of the License, or (at your option) any later version.
#
#               This program is distributed in the hope that it will be useful,
#               but WITHOUT ANY WARRANTY; without even the implied warranty of
#               MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#               GNU General Public License for more details.
#
#               You should have received a copy of the GNU General Public License
#               along with this program. If not, see <https://www.gnu.org/licenses/>.
#
#  @note        Co-developed with GitHub Copilot by OpenAI.
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Pre-Build Configuration and Targets
# ------------------------------------------------------------------------------

# Load project version string
VERSION := $(shell cat VERSION)

# Configurable log file (can be overridden in .makefile or command line)
LOGFILE ?= logs/$(DEVICE_NAME)-$(shell date +%Y%m%d_%H%M%S).log

# Auto-detect Python executable with esptool module
PYTHON_WITH_ESPTOOL := $(shell \
	for py in python3 python /cygdrive/c/Users/rhendel/AppData/Local/Programs/Python/Python313/python.exe; do \
		if "$$py" -c "import esptool" 2>/dev/null; then echo "$$py"; break; fi \
	done)

# Default target - full pipeline: build + upload + logs
.DEFAULT_GOAL := run

# Ensure that secrets.yaml is present before running targets that require secrets
.PHONY: check-secrets
check-secrets:
	@if [ ! -f ./common/secrets.yaml ]; then \
		echo "[ERROR] ./common/secrets.yaml not found!"; \
		echo "Please copy ./secrets.template.yaml to ./common/secrets.yaml and fill in your credentials."; \
		exit 1; \
	fi

# Load per-device config if available
-include .makefile

# Ensure that .makefile is present before dependent targets run
.PHONY: _makefile
_makefile:
	@if [ ! -f .makefile ]; then \
		echo ".makefile not found. Running configure.sh to generate it..."; \
		./configure.sh; \
		if [ -z "$$MAKEFILE_RELOADED" ]; then \
			echo "Reloading Makefile to pick up new variables..."; \
			MAKEFILE_RELOADED=1 $(MAKE) $(MAKECMDGOALS); \
			exit 0; \
		fi; \
	fi

# Run interactive configuration script to generate .makefile and YAML
.PHONY: configure
configure:
	@./configure.sh

# Generate device/node YAML from project source YAML
.PHONY: generate
generate: _makefile
	@echo "Generating device YAML from main.yaml..."
	@mkdir -p $(DEVICE_NAME)
	@awk -F '=' 'NF==2 && $$1 !~ /^#/ && $$1 !~ /^$$/ { \
		gsub(/^[ \t]+|[ \t]+$$/, "", $$1); \
		gsub(/^[ \t]+|[ \t]+$$/, "", $$2); \
		key=$$1; val=$$2; \
		gsub(/[\/|]/, "\\\\&", val); \
		print "s|__" key "__|" val "|g" \
	}' .makefile > .sedargs
	@sed -f .sedargs main.yaml > $(DEVICE_NAME)/$(DEVICE_NAME).yaml
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
flash-erase: _makefile
	@echo "Erasing flash memory on $(DEVICE_NAME) via $(UPLOAD_PATH)..."
	@echo "WARNING: This will completely erase all firmware and data!"
	@echo "Press Ctrl+C within 5 seconds to cancel..."
	@sleep 5
	@$(PYTHON_WITH_ESPTOOL) -m esptool --chip esp32s3 --port $(UPLOAD_PATH) erase_flash

# Display ESP32-S3 chip information and capabilities
.PHONY: chip-info
chip-info: _makefile
	@echo "Reading ESP32-S3 chip information via $(UPLOAD_PATH)..."
	@$(PYTHON_WITH_ESPTOOL) -m esptool --chip esp32s3 --port $(UPLOAD_PATH) chip_id

# Display flash memory information and layout
.PHONY: flash-info
flash-info: _makefile
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
upload: check-secrets _makefile
	@echo Uploading firmware to $(DEVICE_NAME)...
	@esphome upload $(DEVICE_NAME)/$(DEVICE_NAME).yaml --device $(UPLOAD_PATH)

# View live log output from the device
.PHONY: logs
logs: check-secrets _makefile
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
logs-interactive: _makefile
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
DOXYFILE = docs/Doxyfile


# Generate HTML and PDF from YAML documentation
.PHONY: docs-doxygen
docs-doxygen:
	@echo "Extracting YAML headers to Markdown for Doxygen..."
	@python3 docs/extract_yaml_headers.py
	@echo "Generating HTML and PDF documentation from YAML files..."
	@mkdir -p docs/html docs/latex
	@doxygen $(DOXYFILE)
	@echo "Building PDF from LaTeX..."
	@$(MAKE) -C docs/latex > /dev/null 2>&1 || echo "[WARN] PDF build may have issues."
	@echo "Done. View HTML at docs/html/index.html or PDF at docs/latex/refman.pdf"

# Generate ESPHome documentation from YAML files
.PHONY: docs-esphome
docs-esphome: _makefile
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
	@echo "Generating component documentation from common YAML files..."
	@for file in common/*.yaml; do \
		name=$$(basename $$file .yaml); \
		if [ "$$name" != "secrets" ]; then \
			echo "→ $$file"; \
			echo "# ESPHome Component: $$name" > docs/esphome/$$name-component.txt; \
			echo "# Source: $$file" >> docs/esphome/$$name-component.txt; \
			echo "# Generated: $$(date)" >> docs/esphome/$$name-component.txt; \
			echo "" >> docs/esphome/$$name-component.txt; \
			cat $$file >> docs/esphome/$$name-component.txt; \
		else \
			echo "[SKIP] Skipping secrets.yaml"; \
		fi; \
	done
	@echo "ESPHome documentation saved to docs/esphome/"

# Generate all documentation (ESPHome + Doxygen)
.PHONY: docs
docs: docs-esphome docs-doxygen


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


# Remove generated documentation files
.PHONY: clean-docs
clean-docs: clean-docs-esphome clean-docs-doxygen clean-docs-generated
	@echo "Checking for empty docs subdirectories..."
	@if [ -d "docs/html" ] && [ -z "$$(ls -A docs/html/ 2>/dev/null)" ]; then \
		echo "Removing empty docs/html directory..."; \
		rmdir docs/html/; \
	fi
	@if [ -d "docs/latex" ] && [ -z "$$(ls -A docs/latex/ 2>/dev/null)" ]; then \
		echo "Removing empty docs/latex directory..."; \
		rmdir docs/latex/; \
	fi
	@if [ -d "docs/esphome" ] && [ -z "$$(ls -A docs/esphome/ 2>/dev/null)" ]; then \
		echo "Removing empty docs/esphome directory..."; \
		rmdir docs/esphome/; \
	fi
# Only remove docs/generated if it is truly empty (including .gitkeep)
	@if [ -d "docs/generated" ]; then \
	count=$$(ls -A docs/generated/ 2>/dev/null | wc -l); \
	if [ "$$count" -eq 0 ]; then \
	echo "Removing empty docs/generated directory..."; \
	rmdir docs/generated/; \
	fi; \
	fi

# Remove only generated Markdown documentation
.PHONY: clean-docs-generated
clean-docs-generated:
	@echo "Cleaning generated Markdown documentation..."
	@if [ -d "docs/generated" ]; then \
		find docs/generated -type f ! -name '.gitkeep' -delete; \
		echo "Removed generated Markdown files from docs/generated/"; \
	else \
		echo "No generated Markdown directory found"; \
	fi

# Remove only ESPHome-generated documentation
.PHONY: clean-docs-esphome
clean-docs-esphome:
	@echo "Cleaning ESPHome documentation files..."
	@if [ -d "docs/esphome" ]; then \
		rm -rf docs/esphome; \
		echo "Removed ESPHome documentation directory"; \
	else \
		echo "No ESPHome documentation directory found"; \
	fi

# Remove only Doxygen-generated documentation
.PHONY: clean-docs-doxygen
clean-docs-doxygen:
	@echo "Cleaning Doxygen documentation..."
	@if [ -d "docs/html" ]; then \
		rm -rf docs/html/; \
		echo "Removed Doxygen HTML documentation"; \
	else \
		echo "No Doxygen HTML directory found"; \
	fi
	@if [ -d "docs/latex" ]; then \
		rm -rf docs/latex/; \
		echo "Removed Doxygen LaTeX documentation"; \
	else \
		echo "No Doxygen LaTeX directory found"; \
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
	@echo "  docs                Generate all documentation (ESPHome + Doxygen)"
	@echo "  docs-esphome        Generate ESPHome style documentation"
	@echo "  docs-doxygen        Generate Doxygen style documentation"
	@echo ""
	@echo "Cleanup Targets:"
	@echo "  clean               Remove temporary build artifacts and logs"
	@echo "  clean-cache         Remove ESPHome build cache"
	@echo "  clean-docs          Remove all generated documentation (including docs/generated)"
	@echo "  clean-docs-generated Remove only generated Markdown documentation (docs/generated)"
	@echo "  clean-docs-esphome  Remove only ESPHome documentation files"
	@echo "  clean-docs-doxygen  Remove only Doxygen documentation"
	@echo "  clobber             Remove entire device directory and documentation"
	@echo "  distclean           Complete cleanup for archive/export"
	@echo ""
	@echo "Utility Targets:"
	@echo "  version             Show platform and ESPHome version"
	@echo "  buildvars           Show current build configuration values"
	@echo "  help                Show this message"