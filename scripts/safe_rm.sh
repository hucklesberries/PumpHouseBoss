#!/bin/sh
# ==============================================================================
#  File:         safe_rm.sh
#  File Type:    Shell Script
#  Purpose:      Safe recursive delete for ESPHome-based device management
#  Version:      0.9.0d
#  Date:         2025-08-05
#  Author:       Roland Tembo Hendel <rhendel@nexuslogic.com>
#
#  Description:  Safely deletes directories and files, with protection against
#                accidental deletion of critical or protected paths. Designed
#                for use by Makefile cleanup targets.
#
#  Features:     - Strips leading/trailing spaces from argument
#                - Checks for empty argument
#                - Checks against protected directories
#                - Prints debug and status messages
#                - Exits with error on unsafe or missing argument
#
#  License:      GNU General Public License v3.0
#                SPDX-License-Identifier: GPL-3.0-or-later
#  Copyright:    (c) 2025 Roland Tembo Hendel
#                This program is free software: you can redistribute it and/or
#                modify it under the terms of the GNU General Public License.
# ==============================================================================

set -e

PROTECTED_DIRS="/ ~ ./ ../ . /home /root /usr /bin /etc /var /tmp"
PRECIOUS_DIRS="/root /usr /bin /etc /var"

if [ $# -lt 1 ]; then
  echo "[SAFE_RM] Refusing to delete: directory not specified" >&2
  exit 1
fi

dir="$(echo "$1" | sed 's/^ *//;s/ *$//')"

if [ -z "$dir" ]; then
  exit 1
fi

for protected in $PROTECTED_DIRS; do
  if [ "$dir" = "$protected" ]; then
    echo "[SAFE_RM] Refusing to delete protected directory: $dir" >&2
    exit 1
  fi
  # Prevent deletion of root
  if [ "$dir" = "/" ]; then
    echo "[SAFE_RM] Refusing to delete root directory: $dir" >&2
    exit 1
  fi
  # Prevent deletion of empty string
  if [ "$dir" = "" ]; then
    echo "[SAFE_RM] Refusing to delete: directory not specified" >&2
    exit 1
  fi
  # Prevent deletion of current directory
  if [ "$dir" = "." ]; then
    echo "[SAFE_RM] Refusing to delete current directory: $dir" >&2
    exit 1
  fi
  # Prevent deletion of parent directory
  if [ "$dir" = ".." ]; then
    echo "[SAFE_RM] Refusing to delete parent directory: $dir" >&2
    exit 1
  fi
  # Prevent deletion of home directory
  if [ "$dir" = "$HOME" ]; then
    echo "[SAFE_RM] Refusing to delete home directory: $dir" >&2
    exit 1
  fi
  # Prevent deletion of project root
  if [ "$dir" = "$(pwd)" ]; then
    echo "[SAFE_RM] Refusing to delete project root: $dir" >&2
    exit 1
  fi

done

for precious in $PRECIOUS_DIRS; do
  # Prevent deletion of protected subdirs
  case "$dir" in
    "$precious"/*)
      echo "[SAFE_RM] Refusing to delete protected subdirectory: $dir" >&2
      exit 1
      ;;
  esac
done

absdir="$(realpath "$dir" 2>/dev/null || echo "$dir")"
echo "[SAFE_RM] Deleting directory: $dir (absolute: $absdir)"
rm -rf "$absdir"
