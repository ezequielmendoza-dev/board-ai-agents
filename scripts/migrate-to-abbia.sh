#!/usr/bin/env bash

# ==============================================================================
# migrate-to-abbia.sh — Compatibility wrapper for migrate-to-boardai.sh
# ==============================================================================
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
exec bash "$SCRIPT_DIR/migrate-to-boardai.sh" "$@"
