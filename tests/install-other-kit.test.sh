#!/usr/bin/env bash
#
# install-other-kit.test.sh — install.sh and uninstall.sh next to another Claude kit
#
# Usage: bash tests/install-other-kit.test.sh
#
# The other kit is faked: its map, a session-start hook and a CLAUDE.md are all
# the check looks at, and all a refused run must leave alone.
#
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1

KIT="$PWD"
pass=0; fail=0
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

ok()  { pass=$((pass + 1)); printf '  ok   %s\n' "$1"; }
bad() { fail=$((fail + 1)); printf '  FAIL %s\n%s\n' "$1" "$2"; }

fresh_dir() { mktemp -d "$work/repo.XXXXXX"; }

# other_kit MAP → a folder that looks like another kit's install
other_kit() {
  local d; d=$(fresh_dir)
  mkdir -p "$d/.claude/hooks"
  printf 'other kit rules\n' > "$d/CLAUDE.md"
  printf 'other kit hook\n' > "$d/.claude/hooks/session-start.sh"
  printf 'other kit map\n' > "$d/$1"
  printf '%s' "$d"
}

snapshot() { (cd "$1" && find . -type f -exec cksum {} + | sort); }

# refuses LABEL SCRIPT DIR [FLAGS…] → exit 2, the reason on stderr, the folder untouched
refuses() {
  local label="$1" script="$2" dir="$3"; shift 3
  local before out code
  before=$(snapshot "$dir")
  out=$(bash "$KIT/$script" "$dir" "$@" 2>&1 </dev/null); code=$?
  if [ "$code" -eq 2 ] && [[ "$out" == *"another Claude kit"* ]] && [ "$(snapshot "$dir")" = "$before" ]; then
    ok "$label"
  else
    bad "$label" "  exit=$code: $out"
  fi
}

# passes LABEL EXIT OUTPUT [TEST…] → EXIT is 0 and the test command, if any, holds
passes() {
  local label="$1" code="$2" output="$3"; shift 3
  if [ "$code" -eq 0 ] && { [ $# -eq 0 ] || "$@"; }; then ok "$label"; else bad "$label" "  exit=$code: $output"; fi
}
has()     { [ -e "$1" ]; }
gone()    { [ ! -e "$1" ]; }
is_mine() { [ "$(cat "$1")" = "mine" ]; }

echo "install refuses another kit's folder"
for map in DESIGN_MAP.md CODEBASE_MAP.md MANUSCRIPT_MAP.md; do
  refuses "install: $map" install.sh "$(other_kit "$map")"
done
refuses "install --force"   install.sh "$(other_kit DESIGN_MAP.md)" --force
refuses "install --upgrade" install.sh "$(other_kit DESIGN_MAP.md)" --upgrade
refuses "install --dry-run" install.sh "$(other_kit DESIGN_MAP.md)" --dry-run

echo "uninstall refuses another kit's folder"
for map in DESIGN_MAP.md CODEBASE_MAP.md MANUSCRIPT_MAP.md; do
  refuses "uninstall: $map" uninstall.sh "$(other_kit "$map")" --force
done
refuses "uninstall --dry-run"      uninstall.sh "$(other_kit DESIGN_MAP.md)" --dry-run
refuses "uninstall --keep-project" uninstall.sh "$(other_kit DESIGN_MAP.md)" --force --keep-project

echo "not another kit: a map or a hook alone"
d=$(fresh_dir); printf 'mine\n' > "$d/CODEBASE_MAP.md"
out=$(bash "$KIT/install.sh" "$d" 2>&1); code=$?
passes "a repo's own CODEBASE_MAP.md installs" "$code" "$out" has "$d/MARKETING_MAP.md"
passes "and stays" 0 "" is_mine "$d/CODEBASE_MAP.md"

d=$(fresh_dir); mkdir -p "$d/.claude/hooks"; printf 'mine\n' > "$d/.claude/hooks/session-start.sh"
out=$(bash "$KIT/install.sh" "$d" 2>&1); code=$?
passes "a repo's own session-start hook installs" "$code" "$out" has "$d/MARKETING_MAP.md"
passes "and stays" 0 "" is_mine "$d/.claude/hooks/session-start.sh"

echo "the subfolder the message points at"
d=$(other_kit DESIGN_MAP.md); before=$(snapshot "$d")
msg=$(bash "$KIT/install.sh" "$d" 2>&1)
if [[ "$msg" == *"$d/marketing"* ]]; then ok "the refusal names the subfolder"; else bad "the refusal names the subfolder" "  $msg"; fi
out=$(bash "$KIT/install.sh" "$d/marketing" 2>&1); code=$?
passes "installs into the subfolder" "$code" "$out" has "$d/marketing/.claude/hooks/claim-scan.sh"
out=$(bash "$KIT/install.sh" "$d/marketing" --upgrade 2>&1); code=$?
passes "upgrades in the subfolder" "$code" "$out"
out=$(bash "$KIT/uninstall.sh" "$d/marketing" --force 2>&1); code=$?
passes "uninstalls from the subfolder" "$code" "$out" gone "$d/marketing/CLAUDE.md"
rm -rf "$d/marketing"
if [ "$(snapshot "$d")" = "$before" ]; then ok "the root kit is untouched"; else bad "the root kit is untouched" "  root changed"; fi

echo "this kit alone still installs, upgrades and uninstalls"
d=$(fresh_dir)
out=$(bash "$KIT/install.sh" "$d" 2>&1); code=$?
passes "install" "$code" "$out" has "$d/CLAUDE.md"
out=$(bash "$KIT/install.sh" "$d" --upgrade 2>&1); code=$?
passes "upgrade" "$code" "$out"
out=$(bash "$KIT/uninstall.sh" "$d" --force 2>&1); code=$?
passes "uninstall" "$code" "$out" gone "$d/MARKETING_MAP.md"

echo "the way out the uninstall message gives"
d=$(other_kit DESIGN_MAP.md)
mv "$d/DESIGN_MAP.md" "$work/moved.md"
out=$(bash "$KIT/uninstall.sh" "$d" --force 2>&1); code=$?
mv "$work/moved.md" "$d/DESIGN_MAP.md"
passes "moving the map aside lets it run" "$code" "$out" has "$d/DESIGN_MAP.md"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
