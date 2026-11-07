#!/usr/bin/env bash
#
# claim-scan.test.sh — fixture tests for .claude/hooks/claim-scan.sh
#
# Usage: bash tests/hooks/claim-scan.test.sh
#
# The fixtures are copy files, so the kit's own claim-scan hook blocks writing
# a testimonial fixture with the Write/Edit tools. Edit them from the shell.
#
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

KIT="$PWD"
HOOK="$KIT/.claude/hooks/claim-scan.sh"
FIX="$KIT/tests/hooks/fixtures/claim"
pass=0; fail=0

# post FILE [PROJECT_DIR] → hook's stdout (additionalContext JSON or empty)
post() {
  local dir="${2:-$KIT}"
  printf '{"hook_event_name":"PostToolUse","tool_name":"Write","tool_input":{"file_path":"%s"}}' "$1" \
    | CLAUDE_PROJECT_DIR="$dir" "$HOOK"
}

# pre TOOL FILE TEXT_FILE [PROJECT_DIR] → "exit=N" then the hook's stderr.
# TOOL is Write (content), Edit (new_string) or MultiEdit (edits[]).
pre() {
  local tool="$1" file="$2" text="$3" dir="${4:-$KIT}" json code err
  json=$(python3 - "$tool" "$file" "$text" <<'PY'
import json, sys
tool, path, src = sys.argv[1:4]
body = open(src, encoding="utf-8").read()
ti = {"file_path": path}
if tool == "Write":
    ti["content"] = body
elif tool == "Edit":
    ti.update(old_string="x", new_string=body)
else:
    ti["edits"] = [{"old_string": "x", "new_string": body}]
print(json.dumps({"hook_event_name": "PreToolUse", "tool_name": tool, "tool_input": ti}))
PY
)
  err=$(printf '%s' "$json" | CLAUDE_PROJECT_DIR="$dir" "$HOOK" 2>&1 >/dev/null); code=$?
  printf 'exit=%s\n%s' "$code" "$err"
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
expect_pass() {  # name pre-output
  if [ "$2" = "exit=0" ]; then ok "$1"; else bad "$1" "  expected exit=0 and no stderr, got: $2"; fi
}

# ---- PostToolUse: numbers and superlatives warn -----------------------------

out=$(post "$FIX/numbers.md")
expect_has "unsourced numbers flagged with line numbers" "$out" \
  '"hookEventName": "PostToolUse"' "L3 number: 38" "L4 number: 1,200" "L5 number: 50%, \$49" "L6 number: 10x"
expect_lacks "years, versions, list markers, single digits, refs are skipped" "$out" "L7" "L8" "L9"
expect_lacks "a [NEEDS PROOF] line is not flagged" "$out" "L10"
expect_has "open [NEEDS PROOF] marks are counted" "$out" "1 [NEEDS PROOF] mark(s) open"

out=$(post "$FIX/superlative.md")
expect_has "superlatives flagged and need approval" "$out" "L1 superlative: the only" "L2 superlative: #1, industry-leading" "user approval"
expect_lacks "plain sentence passes" "$out" "L3"

expect_empty "code, comments, inline code and URLs are skipped" "$(post "$FIX/skipped.md")"
expect_empty "clean copy is silent" "$(post "$FIX/clean.md")"
expect_empty "non-copy files are not scanned" "$(post "$FIX/notes.ts")"
expect_empty "kit docs are not scanned" "$(post "$KIT/agent_docs/claims-and-evidence.md")"
expect_empty "missing file is silent" "$(post "$FIX/does-not-exist.md")"

# ---- PreToolUse: invented social proof blocks -------------------------------

out=$(pre Write "$FIX/x.md" "$FIX/testimonial.md")
expect_has "attributed quote on next line blocks" "$out" "exit=2" "BLOCKED by claim-scan" "\"Jane Doe\"" "[SLOT: customer quote"
out=$(pre Edit "$FIX/x.md" "$FIX/testimonial-inline.md")
expect_has "inline attribution in an Edit blocks" "$out" "exit=2" "\"Sam Lee\""
out=$(pre MultiEdit "$FIX/x.md" "$FIX/blockquote.md")
expect_has "blockquote with @handle in a MultiEdit blocks" "$out" "exit=2" "\"@devjane\""
out=$(pre Write "$FIX/x.md" "$FIX/social.md")
expect_has "\"trusted by N teams\" blocks" "$out" "exit=2" "Trusted by 500+ teams at"
out=$(pre Write "$FIX/x.md" "$FIX/seen.md")
expect_has "\"as seen on\" blocks" "$out" "exit=2" "As seen on"

expect_pass "[SLOT] and [NEEDS PROOF] lines pass" "$(pre Write "$FIX/x.md" "$FIX/slot.md")"
expect_pass "a quoted term, a list item and \"used by the hook\" pass" "$(pre Write "$FIX/x.md" "$FIX/plain-quote.md")"
expect_pass "non-copy files are not blocked" "$(pre Write "$FIX/x.ts" "$FIX/testimonial.md")"

# ---- Evidence rows back claims ----------------------------------------------

proj=$(mktemp -d)
trap 'rm -rf "$proj"' EXIT
cat > "$proj/MARKETING_MAP.md" <<'EOF'
## Evidence
| Claim | Source | Checked |
|---|---|---|
| <placeholder claim 50%> | <source> | <date> |
| Jane Doe quote, OK to publish | issue #41 | 2026-11-01 |
| Trusted by 500+ teams at | customer list, sales sheet | 2026-11-01 |
| 1200 GitHub stars | issue #30 | 2026-11-07 |
## Learnings
EOF
printf 'Over 1,200 developers starred it and 50%% stayed.\nTrial lasts 30 days, refunds within 11 days.\n' > "$proj/landing.md"
out=$(post "$proj/landing.md" "$proj")
expect_lacks "a number in an Evidence row is backed (commas ignored)" "$out" "1,200"
expect_has "placeholder rows back nothing" "$out" "L1 number: 50%"
expect_has "Source refs and Checked dates back nothing" "$out" "L2 number: 30, 11"

out=$(post "landing.md" "$proj")
expect_has "relative paths resolve against the project" "$out" "50%"

expect_pass "a quote whose person has an Evidence row passes" "$(pre Write "$proj/l.md" "$FIX/testimonial.md" "$proj")"
expect_pass "a social-proof phrase with an Evidence row passes" "$(pre Write "$proj/l.md" "$FIX/social.md" "$proj")"
out=$(pre Write "$proj/l.md" "$FIX/testimonial-inline.md" "$proj")
expect_has "other names still block with a map present" "$out" "exit=2" "\"Sam Lee\""

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
