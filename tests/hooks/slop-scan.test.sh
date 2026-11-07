#!/usr/bin/env bash
#
# slop-scan.test.sh — fixture tests for .claude/hooks/slop-scan.sh
#
# Usage: bash tests/hooks/slop-scan.test.sh
#
set -uo pipefail
cd "$(dirname "$0")/../.." || exit 1

KIT="$PWD"
HOOK="$KIT/.claude/hooks/slop-scan.sh"
FIX="$KIT/tests/hooks/fixtures/slop"
pass=0; fail=0

# run FILE [PROJECT_DIR] → hook's stdout (additionalContext JSON or empty)
run() {
  local dir="${2:-$KIT}"
  printf '{"tool_name":"Write","tool_input":{"file_path":"%s"}}' "$1" \
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

out=$(run "$FIX/hype.md")
expect_has "hype words flagged with line numbers" "$out" '"hookEventName": "PostToolUse"' "L3 hype: seamless, unlock" "L5 hype: revolutionary"

out=$(run "$FIX/inflected.md")
expect_has "inflections count" "$out" "elevate, empower, unlock"

out=$(run "$FIX/filler.md")
expect_has "filler phrases flagged" "$out" "filler: \\\"In today's fast-paced world\\\"" "filler: \\\"look no further\\\"" "filler: \\\"We're thrilled to announce\\\""

out=$(run "$FIX/soft.md")
expect_has "soft words flagged as a cluster" "$out" "L1 soft-word cluster: intuitive, powerful, robust"
expect_lacks "a lone soft word passes" "$out" "L3"

out=$(run "$FIX/structure.md")
expect_has "em-dash density and emoji bullets" "$out" "L1 3 em-dashes in one paragraph" "3 lines open with an emoji"

expect_empty "quotes, comments, code and URLs are skipped" "$(run "$FIX/skipped.md")"
expect_empty "clean copy is silent" "$(run "$FIX/clean.md")"
expect_empty "non-copy files are not scanned" "$(run "$FIX/notes.ts")"
expect_empty "kit docs are not scanned" "$(run "$KIT/agent_docs/slop-signs.md")"
expect_empty "missing file is silent" "$(run "$FIX/does-not-exist.md")"

# Project map: Banned words extend the list, Voice → Allowed words exempt a term.
proj=$(mktemp -d)
trap 'rm -rf "$proj"' EXIT
cat > "$proj/MARKETING_MAP.md" <<'EOF'
## Voice
- **Sounds like:** a maintainer
- **Allowed words:** magic
## Banned words
<!-- project additions -->
- frictionless, <placeholder>
## Evidence
EOF
printf 'A frictionless setup with Magic Link sign-in.\n' > "$proj/landing.md"
out=$(run "$proj/landing.md" "$proj")
expect_has "MARKETING_MAP banned words are added" "$out" "L1 hype: frictionless"
expect_lacks "Voice allowed words are exempt" "$out" "magic"

out=$(run "landing.md" "$proj")
expect_has "relative paths resolve against the project" "$out" "frictionless"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
