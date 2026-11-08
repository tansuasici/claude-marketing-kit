#!/usr/bin/env bash
#
# channel-limits.test.sh — fixture tests for .claude/hooks/channel-limits.sh
#
# Usage: bash tests/hooks/channel-limits.test.sh
#
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

KIT="$PWD"
HOOK="$KIT/.claude/hooks/channel-limits.sh"
FIX="$KIT/tests/hooks/fixtures/channel"
DOC="$KIT/agent_docs/channels.md"
pass=0; fail=0

# post FILE [PROJECT_DIR] → hook's stdout (additionalContext JSON or empty)
post() {
  local dir="${2:-$KIT}"
  printf '{"hook_event_name":"PostToolUse","tool_name":"Write","tool_input":{"file_path":"%s"}}' "$1" \
    | CLAUDE_PROJECT_DIR="$dir" "$HOOK"
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
expect_lacks() {  # name output needle...
  local name="$1" out="$2"; shift 2
  for needle in "$@"; do
    if printf '%s' "$out" | grep -qF -- "$needle"; then bad "$name" "  unexpected: $needle"$'\n'"  got: $out"; return; fi
  done
  ok "$name"
}
expect_empty() {
  if [ -z "$2" ]; then ok "$1"; else bad "$1" "  expected no output, got: $2"; fi
}

# ---- X ----------------------------------------------------------------------

out=$(post "$FIX/x-over.md")
expect_has "frontmatter picks X; links count 23, emoji 2" "$out" \
  '"hookEventName": "PostToolUse"' "X, counted by the hook" "post: 297/280" "OVER by 17" "split into a thread"

out=$(post "$FIX/drafts/x/thread.md")
expect_has "folder picks X; --- splits a thread, each post counted" "$out" \
  "post 1/3: 32/280" "post 2/3: 300/280" "OVER by 20" "post 3/3: 22/280" "3 hashtags, the cap here is 2"

# ---- other channels ---------------------------------------------------------

out=$(post "$FIX/launch.linkedin.md")
expect_has "file-name part picks LinkedIn; long opening noted" "$out" \
  "LinkedIn" "post: 169/3000" "opening is 150 characters; about 140 show" "Report these as counted lengths"
expect_lacks "fitting post is not OVER" "$out" "OVER" "split into a thread"

out=$(post "$FIX/caption.ig.md")
expect_has "ig alias picks Instagram; caption link noted" "$out" "Instagram" "post: 33/2200" "not clickable"

out=$(post "$FIX/video.md")
expect_has "YouTube: first line is the title, < > rejected" "$out" \
  "title 29/100, description 17/5000" "title has < or >" "Cut to fit;"
expect_lacks "no thread advice off X" "$out" "thread"

out=$(post "$FIX/yt-long.md")
expect_has "YouTube title past ~70 noted, not OVER" "$out" "title 80/100" "title past ~70"
expect_lacks "a 80-character title fits" "$out" "OVER"

expect_has "Facebook: counted, no limit stated" "$(post "$FIX/page.fb.md")" \
  "post: 15 characters; no verified limit"
expect_has "HTML comments are not counted" "$(post "$FIX/tiktok.md")" "TikTok" "post: 14/2200"

# ---- silent -----------------------------------------------------------------

expect_empty "no channel, no report" "$(post "$FIX/plain.md")"
expect_empty "non-copy files are not scanned" "$(post "$FIX/notes.ts")"
expect_empty "kit docs are not scanned" "$(post "$DOC")"
expect_empty "missing file is silent" "$(post "$FIX/does-not-exist.x.md")"

proj=$(mktemp -d "${TMPDIR:-/tmp}/x.XXXXXX")
trap 'rm -rf "$proj"' EXIT
printf 'Plain page.\n' > "$proj/page.md"
expect_empty "folders above the project never pick the channel" "$(post "$proj/page.md" "$proj")"
mkdir -p "$proj/drafts/linkedin"; printf 'Hi.\n' > "$proj/drafts/linkedin/a.md"
expect_has "relative paths resolve against the project" "$(post "drafts/linkedin/a.md" "$proj")" "post: 3/3000"
mkdir -p "$proj/drafts/email"; printf -- '---\nchannel: email\n---\nHi.\n' > "$proj/drafts/email/x-launch.md"
expect_empty "frontmatter naming a channel with no limits beats a path token" "$(post "drafts/email/x-launch.md" "$proj")"

# ---- limits match agent_docs/channels.md ------------------------------------
# The hook hard-codes these; edit one without the other and this fails.

missing=""
for literal in "| 280 characters |" "count as 23 characters" "Emoji, CJK characters | count as 2" \
  "Hashtags: 0–2" "| 3,000 characters |" "~140 (mobile)" "| 2,200 characters |" "~125 characters" \
  "30 per post" "100 characters, no \`<\` or \`>\`" "~50–70 characters" "| 5,000 characters |" \
  "last checked 2026-11-07"; do
  grep -qF -- "$literal" "$DOC" || missing="$missing"$'\n'"  $literal"
done
if [ -z "$missing" ]; then ok "limits in channel_limits.py match channels.md"; else bad "channels.md changed; update channel_limits.py" "$missing"; fi

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
