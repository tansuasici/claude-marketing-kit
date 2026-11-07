#!/usr/bin/env bash
#
# claim-scan.sh — PreToolUse + PostToolUse hook (Write | Edit | MultiEdit)
#
# One script, two modes, picked by hook_event_name:
#
#   PreToolUse   BLOCKS (exit 2) a write whose new text holds social proof
#                with no source: a quote attributed to a named person, or
#                "trusted by / used by N teams", "as seen in". Passes when an
#                Evidence row in MARKETING_MAP.md names the person or phrase,
#                or the line carries [NEEDS PROOF] or [SLOT: …].
#   PostToolUse  WARNS about numbers, prices and superlatives with no
#                Evidence row and no [NEEDS PROOF] mark, and counts the marks
#                still open. Never blocks. Exits 0.
#
# Rules: agent_docs/claims-and-evidence.md. Scanned: copy files only (see
# lib/copy-file.sh).
#

set -euo pipefail

INPUT=$(cat)
HOOK_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)" || exit 0
HOOK_LIB="$HOOK_DIR/lib"
[ -f "$HOOK_LIB/claim_scan.py" ] || exit 0
command -v python3 >/dev/null 2>&1 || exit 0
# shellcheck source=lib/json-parse.sh
source "$HOOK_LIB/json-parse.sh"
# shellcheck source=lib/emit.sh
source "$HOOK_LIB/emit.sh"
# shellcheck source=lib/copy-file.sh
source "$HOOK_LIB/copy-file.sh"

FILE=$(parse_json_field "file_path")
[ -z "$FILE" ] && exit 0

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
is_copy_file "$FILE" "$ROOT" || exit 0
case "$FILE" in /*) ;; *) FILE="$ROOT/$FILE" ;; esac
MAP="$ROOT/MARKETING_MAP.md"

case "$(parse_json_field "hook_event_name")" in
  PreToolUse)
    status=0
    REASON=$(printf '%s' "$INPUT" | python3 "$HOOK_LIB/claim_scan.py" pre "$MAP" 2>/dev/null) || status=$?
    if [ "$status" -eq 2 ]; then
      printf '%s\n' "$REASON" >&2
      exit 2
    fi
    exit 0
    ;;
  PostToolUse)
    [ -f "$FILE" ] || exit 0
    REPORT=$(python3 "$HOOK_LIB/claim_scan.py" post "$MAP" "$FILE" 2>/dev/null) || exit 0
    [ -z "$REPORT" ] && exit 0
    emit_context "PostToolUse" "$REPORT"
    ;;
esac
exit 0
