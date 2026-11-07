#!/usr/bin/env bash
#
# publish-gate.sh — PreToolUse hook (mcp__.*)
#
# Enforces CLAUDE.md → Publishing for scheduler connectors (Buffer MCP and
# the like). A tool call that publishes, schedules or queues a post is:
#
#   denied  when MARKETING_MAP.md is missing or the channel has publish: off
#           (every channel, when the call names none, as Buffer's channelId)
#   asked   otherwise: the permission prompt shows channel, time and text,
#           and the user's answer is the approval for that one post
#
# Drafts and ideas pass silently. Other MCP tools are not touched.
# Decisions go out as hookSpecificOutput.permissionDecision JSON, exit 0.
#

set -euo pipefail

INPUT=$(cat)
HOOK_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)" || exit 0
[ -f "$HOOK_DIR/lib/publish_gate.py" ] || exit 0
command -v python3 >/dev/null 2>&1 || exit 0

ROOT="${CLAUDE_PROJECT_DIR:-$PWD}"
printf '%s' "$INPUT" | python3 "$HOOK_DIR/lib/publish_gate.py" "$ROOT/MARKETING_MAP.md" 2>/dev/null || true
exit 0
