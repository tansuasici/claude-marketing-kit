#!/usr/bin/env bash
#
# channel-limits.sh — PostToolUse hook (Write | Edit | MultiEdit)
#
# Counts a draft against its channel's limits and reports the counts, so the
# length check in CLAUDE.md → Verification is counted, not estimated. The
# channel comes from frontmatter (`channel: x`) or a path token (drafts/x/,
# launch.linkedin.md); files with no channel are skipped. Never blocks.
#
# Limits: agent_docs/channels.md. Scanned: copy files only (lib/copy-file.sh).
#

set -euo pipefail

INPUT=$(cat)
HOOK_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)" || exit 0
HOOK_LIB="$HOOK_DIR/lib"
[ -f "$HOOK_LIB/channel_limits.py" ] || exit 0
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

REPORT=$(python3 "$HOOK_LIB/channel_limits.py" "$FILE" "${FILE#"$ROOT"/}" 2>/dev/null) || exit 0
[ -z "$REPORT" ] && exit 0
emit_context "PostToolUse" "$REPORT"
exit 0
