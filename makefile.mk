# ------------------------------------------------------------------------------
#  File:         makefile.mk
#  File Type:    Makefile Include
#  Purpose:      Make Macros and Helper Functions
#  Version:      0.8.0d
#  Date:         2025-07-24
#  Author:       Roland Tembo Hendel <rhendel@nexuslogic.com>
#
#  Description:  Shared Makefile macros and helper functions for ESPHome-based
#                device management. Provides OS detection, Python/esptool
#                auto-detection, safe recursive delete, and colorized output macros.
#
#  Features:     - OS detection for cross-platform compatibility
#                - Python/esptool auto-detection for firmware operations
#                - Safe recursive delete macro with protected directory checks
#                - Colorized output macros for consistent messaging
#                - Designed for inclusion in project Makefiles
#
#  license:      gnu general public license v3.0
#                spdx-license-identifier: gpl-3.0-or-later
#  copyright:    (c) 2025 roland tembo hendel
#                this program is free software: you can redistribute it and/or
#                modify it under the terms of the gnu general public license.
# ------------------------------------------------------------------------------


# detect os (necessary for path/eol conversion from stupid ms windows)
uname_s := $(shell uname -s)
ifeq ($(findstring cygwin,$(uname_s)),cygwin)
	win_cmd = 1
else ifeq ($(findstring mingw,$(uname_s)),mingw)
	win_cmd = 1
else
	win_cmd = 0
endif

# auto-detect python executable with esptool module
python_with_esptool ?= $(shell \
	for py in python3 python; do \
		if "$$py" -c "import esptool" 2>/dev/null; then echo "$$py"; break; fi \
	done)

# Macro: Run esptool command via Python (single-line variable for safe recipe expansion)
ESPTOOL_CMD = $(PYTHON_WITH_ESPTOOL) -m esptool --chip $(PLATFORM) --port $(COMM_PATH)

# Macro: Safe recursive delete
SAFE_RM = \
  if [ -z "$1" ]; then \
	echo -e "$(RED)[SAFE_RM]$(NC) Refusing to delete: directory not specified"; \
  elif [ "$(if $(filter $(1),$(PROTECTED_DIRS)),yes,no)" = "yes" ]; then \
	echo -e "$(RED)[SAFE_RM]$(NC) Refusing to delete protected directory: $1"; \
  else \
	echo -e "$(YELLOW)[SAFE_RM]$(NC) Deleting directory: $1"; \
	rm -rf "$1"; \
  fi

# Color support detection and color variables
ifeq (,$(findstring dumb,$(TERM)))
	ifneq (,$(TERM))
		RED    := \033[0;31m
		GREEN  := \033[0;32m
		YELLOW := \033[0;33m
		NC     := \033[0m
	endif
endif

# Output colorized normalization macros
INFO  := $(GREEN)[INFO]$(NC)
WARN  := $(YELLOW)[WARN]$(NC)
ERROR := $(RED)[ERROR]$(NC)