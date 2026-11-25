#!/usr/bin/env bash
#
# validate.sh — run the checks from .github/workflows/validate.yml locally.
#
# Run it before you push: bash scripts/validate.sh
# Needs bash, git, jq, shellcheck and python3. Stops at the first failure.
set -euo pipefail
cd "$(dirname "$0")/.."

for tool in git jq shellcheck python3; do
  command -v "$tool" >/dev/null || { echo "validate: $tool not found" >&2; exit 1; }
done

step() { printf '\n== %s\n' "$1"; }

step "plugin layout"
./scripts/check-plugin.sh

step "JSON"
git ls-files -z '*.json' | xargs -0 -n1 jq empty

step "shellcheck"
git ls-files -z '*.sh' | xargs -0 shellcheck

step "hook tests"
for t in tests/hooks/*.test.sh tests/install-other-kit.test.sh; do
  echo "-- $t"
  bash "$t"
done

printf '\nvalidate: all checks passed\n'
