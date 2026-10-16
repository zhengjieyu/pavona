#!/bin/bash
# Copyright zeroRISC Inc.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0

# Usage: check_wdrs.sh ASM MAX
# Fails if ASM uses a wide data register above wMAX.

set -euo pipefail

asm="$1"
max="$2"

bad=$(grep -oE '\bw[0-9]+\b' "$asm" | sort -u | awk -v max="$max" '{ if (substr($0, 2) + 0 > max) print }')
if [[ -n "$bad" ]]; then
  echo "$asm uses WDRs above w$max:" $bad >&2
  exit 1
fi
