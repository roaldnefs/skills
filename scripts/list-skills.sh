#!/usr/bin/env bash
# List all skills in this repo (directories containing a SKILL.md), at any depth.
set -euo pipefail

cd "$(dirname "$0")/.."

find . \( -name node_modules -o -name .git \) -prune \
  -o -type f -name SKILL.md -exec dirname {} \; | sed 's|^\./||' | sort
