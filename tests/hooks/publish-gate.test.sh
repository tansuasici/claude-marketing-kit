#!/usr/bin/env bash
#
# publish-gate.test.sh — tests for .claude/hooks/publish-gate.sh
#
# Usage: bash tests/hooks/publish-gate.test.sh
#
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

KIT="$PWD"
HOOK="$KIT/.claude/hooks/publish-gate.sh"
pass=0; fail=0

proj=$(mktemp -d); none=$(mktemp -d)
trap 'rm -rf "$proj" "$none"' EXIT
cat > "$proj/MARKETING_MAP.md" <<'MAP'
## Channels
| Channel | Account | Format / limit | Cadence | publish |
|---|---|---|---|---|
| X | @kit | 280 | weekly | on |
| LinkedIn | <page> | 3,000 | <...> | off |
| Instagram | <@handle> | 2,200 | <...> | off |
## Customer language
MAP

# call TOOL_NAME TOOL_INPUT_JSON [PROJECT_DIR] → hook's stdout
call() {
  printf '{"hook_event_name":"PreToolUse","tool_name":"%s","tool_input":%s}' "$1" "$2" \
    | CLAUDE_PROJECT_DIR="${3:-$proj}" "$HOOK"
}

ok()  { pass=$((pass + 1)); printf 'ok   %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf 'FAIL %s\n%s\n' "$1" "$2"; }
expect_has() {  # name output needle...
  local name="$1" out="$2"; shift 2
  for needle in "$@"; do
    if ! printf '%s' "$out" | grep -qF -- "$needle"; then bad "$name" "  missing: $needle"$'\n'"  got: $out"; return; fi
  done
  ok "$name"
}
expect_empty() {
  if [ -z "$2" ]; then ok "$1"; else bad "$1" "  expected no output, got: $2"; fi
}

POST='{"channelId":"65a1b2c3d4e5f60718293a4b","schedulingType":"automatic","mode":"customScheduled","dueAt":"2026-11-10T09:00:00+03:00","text":"v0.2 ships channel-limits.","metadata":{"twitter":{}}}'

# ---- ask: channel on --------------------------------------------------------

out=$(call mcp__buffer__create_post "$POST")
expect_has "Buffer create_post on an on channel asks, with channel, time, text" "$out" \
  '"permissionDecision": "ask"' "Channel: X" "Time: 2026-11-10T09:00:00+03:00" "Text: v0.2 ships channel-limits." "this one post only"

out=$(call mcp__buffer__create_post '{"channelId":"abc","schedulingType":"automatic","text":"Hi"}')
expect_has "unnamed channel with one channel on asks, naming the on rows" "$out" \
  '"permissionDecision": "ask"' "publish: on for X" "queue default"

out=$(call mcp__buffer__edit_post '{"postId":"p1","mode":"shareNow"}')
expect_has "edit_post that reschedules asks" "$out" '"permissionDecision": "ask"' "mode shareNow" "(no text in the call)"

out=$(call mcp__composio__BUFFER_PUBLISH_POSTS '{"service":"twitter","text":"Hi"}')
expect_has "tool names match case-insensitively; service field names the channel" "$out" '"permissionDecision": "ask"' "Channel: X"

# ---- deny: channel off or no map --------------------------------------------

out=$(call mcp__buffer__create_post '{"channelId":"abc","text":"Hi","metadata":{"linkedin":{}}}')
expect_has "a channel with publish: off is denied" "$out" '"permissionDecision": "deny"' "LinkedIn has publish: off" "draft"

out=$(call mcp__buffer__create_post '{"channelId":"abc","text":"Hi","metadata":{"twitter":{},"instagram":{}}}')
expect_has "any off channel in the call denies" "$out" '"permissionDecision": "deny"' "Instagram has publish: off"

out=$(call mcp__buffer__create_post "$POST" "$KIT")
expect_has "the template map (all off) denies an unnamed channel" "$out" '"permissionDecision": "deny"' "BLOCKED by publish-gate"
out=$(call mcp__buffer__create_post '{"channelId":"abc","text":"Hi"}' "$KIT")
expect_has "every channel off denies" "$out" '"permissionDecision": "deny"' "every channel has publish: off"

out=$(call mcp__buffer__create_post "$POST" "$none")
expect_has "no MARKETING_MAP.md denies" "$out" '"permissionDecision": "deny"' "no MARKETING_MAP.md"

# ---- silent: drafts, ideas, other tools -------------------------------------

expect_empty "saveToDraft passes silently" "$(call mcp__buffer__create_post '{"channelId":"abc","text":"Hi","saveToDraft":true,"metadata":{"linkedin":{}}}')"
expect_empty "create_idea passes silently" "$(call mcp__buffer__create_idea '{"text":"Hi"}')"
expect_empty "a draft tool passes silently" "$(call mcp__composio__BUFFER_CREATE_POST_DRAFT '{"text":"Hi"}')"
expect_empty "read tools pass" "$(call mcp__buffer__list_posts '{}')"
expect_empty "delete_post is not publishing" "$(call mcp__buffer__delete_post '{"postId":"p1"}')"
for t in notion-create-pages notion-update-page notion-create-comment notion-query-data-sources; do
  expect_empty "Notion $t is never gated" "$(call "mcp__notion__$t" '{"page_id":"x","command":"update_properties"}' "$KIT")"
done
expect_empty "Slack send_message is not a post" "$(call mcp__slack__send_message '{"text":"Hi"}' "$KIT")"
expect_empty "non-MCP tools are ignored" "$(call Write '{"file_path":"x.md","content":"publish"}' "$KIT")"
expect_empty "bad JSON is silent" "$(printf 'nope' | CLAUDE_PROJECT_DIR="$KIT" "$HOOK")"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
