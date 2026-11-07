#!/usr/bin/env bash
#
# slop-scan.sh — PostToolUse hook (Write | Edit | MultiEdit)
#
# After a copy file is written, scans it for hype words, filler phrases,
# soft-word clusters, em-dash density and emoji bullets. Lists come from
# agent_docs/slop-signs.md plus MARKETING_MAP.md → Banned words; terms under
# MARKETING_MAP.md → Voice → **Allowed words:** are skipped. Warn-only: the
# report goes back to Claude as context, the edit is never blocked. Exits 0.
#
# Scanned: copy files only (see lib/copy-file.sh).
#

set -euo pipefail

# shellcheck disable=SC2034  # read by lib/json-parse.sh
INPUT=$(cat)
HOOK_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)" || exit 0
HOOK_LIB="$HOOK_DIR/lib"
[ -f "$HOOK_LIB/slop_scan.py" ] || exit 0
command -v python3 >/dev/null 2>&1 || exit 0
source "$HOOK_LIB/json-parse.sh"
source "$HOOK_LIB/emit.sh"
source "$HOOK_LIB/copy-file.sh"

FILE=$(parse_json_field "file_path")
[ -z "$FILE" ] && exit 0

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
is_copy_file "$FILE" "$ROOT" || exit 0

case "$FILE" in /*) ;; *) FILE="$ROOT/$FILE" ;; esac
[ -f "$FILE" ] || exit 0

# Project copy first (installed kit), then the plugin's own copy.
SIGNS="$ROOT/agent_docs/slop-signs.md"
[ -f "$SIGNS" ] || SIGNS="$HOOK_DIR/../../agent_docs/slop-signs.md"
[ -f "$SIGNS" ] || exit 0

REPORT=$(python3 "$HOOK_LIB/slop_scan.py" "$FILE" "$SIGNS" "$ROOT/MARKETING_MAP.md" 2>/dev/null) || exit 0
[ -z "$REPORT" ] && exit 0
emit_context "PostToolUse" "$REPORT"
exit 0
