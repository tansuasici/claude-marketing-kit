#!/usr/bin/env bash
#
# prompt-router.test.sh — tests for .claude/hooks/prompt-router.sh
#
# Usage: bash tests/hooks/prompt-router.test.sh
#
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

HOOK="$PWD/.claude/hooks/prompt-router.sh"
pass=0; fail=0

# route PROMPT → hook's stdout
route() {
  python3 -c 'import json,sys; print(json.dumps({"hook_event_name":"UserPromptSubmit","prompt":sys.argv[1]}))' "$1" | "$HOOK"
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
expect_lacks() {
  local name="$1" out="$2"; shift 2
  for needle in "$@"; do
    if printf '%s' "$out" | grep -qF -- "$needle"; then bad "$name" "  unexpected: $needle"$'\n'"  got: $out"; return; fi
  done
  ok "$name"
}
expect_empty() {
  if [ -z "$2" ]; then ok "$1"; else bad "$1" "  expected no output, got: $2"; fi
}

out=$(route "Write the landing page hero")
expect_has "copy work gets the map reminder" "$out" '"hookEventName": "UserPromptSubmit"' "[Map first]"
expect_lacks "only the matching reminder" "$out" "[Evidence]" "[Channel]" "[Publish gate]"

expect_has "numbers and testimonials get the evidence reminder" "$(route "Add a testimonial and our user numbers")" "[Evidence]" "[NEEDS PROOF]"
expect_has "social channels get the channel reminder" "$(route "Draft a LinkedIn post")" "[Channel]"
expect_has "publishing gets the publish gate" "$(route "Schedule it for Monday")" "[Publish gate]" "publish-gate.sh"
expect_has "matching ignores case" "$(route "TWEET THIS")" "[Channel]"

out=$(route "Write a launch thread with our user stats and publish it")
expect_has "several reminders stack" "$out" "[Map first]" "[Evidence]" "[Channel]" "[Publish gate]"

expect_empty "whole words only: postgres, userland, threading" "$(route "Fix the postgres userland threading bug")"
expect_empty "unrelated prompts are silent" "$(route "Rename the variable in install.sh")"
expect_empty "an empty prompt is silent" "$(route "")"
expect_empty "bad JSON is silent" "$(printf 'nope' | "$HOOK" 2>/dev/null)"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
