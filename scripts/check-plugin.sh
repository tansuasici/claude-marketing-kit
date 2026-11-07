#!/usr/bin/env bash
#
# check-plugin.sh — assert the plugin layout matches what Claude Code loads.
#
# Claude Code loads plugin agents only from a root agents/ directory and
# ignores an `agents` key in plugin.json. Hooks load from hooks/hooks.json, so
# plugin.json must not also declare `hooks`. This script fails if:
#   - plugin.json declares `agents` or `hooks`
#   - agents/ drifts from .claude/agents/ (the copy the npx installer ships)
#   - hooks/hooks.json drifts from the hooks in .claude/settings.json, or a
#     hook command is not rooted at "${CLAUDE_PLUGIN_ROOT}"
#
# Usage:
#   ./scripts/check-plugin.sh

set -euo pipefail
cd "$(dirname "$0")/.."

fail=0

if [ ! -d .claude/agents ] && [ ! -d agents ]; then
  echo "ok   no agents yet"
elif ! diff -rq .claude/agents agents >/dev/null 2>&1; then
  diff -rq .claude/agents agents || true
  echo "FAIL agents/ drifted from .claude/agents/ — run: cp .claude/agents/*.md agents/"
  fail=1
else
  echo "ok   agents/ matches .claude/agents/ ($(ls agents/*.md | wc -l | tr -d ' ') agents)"
fi

python3 - <<'EOF' || fail=1
import json, sys

ok = True
plugin = json.load(open(".claude-plugin/plugin.json"))
for key in ("agents", "hooks"):
    if key in plugin:
        print(f"FAIL plugin.json declares `{key}` — Claude Code loads it from the default path; remove the key")
        ok = False

root = '"${CLAUDE_PLUGIN_ROOT}"/'
plugin_hooks = json.load(open("hooks/hooks.json"))["hooks"]
settings_hooks = json.load(open(".claude/settings.json"))["hooks"]

def commands(hooks):
    out = set()
    for event, groups in hooks.items():
        for g in groups:
            for h in g["hooks"]:
                out.add((event, g.get("matcher", ""), h["command"]))
    return out

plugin_cmds = commands(plugin_hooks)
for event, matcher, cmd in sorted(plugin_cmds):
    if not cmd.startswith(root):
        print(f"FAIL hooks.json {event} command not rooted at {root}: {cmd}")
        ok = False

expected = {(e, m, root + c.removeprefix('"$CLAUDE_PROJECT_DIR"/')) for e, m, c in commands(settings_hooks)}
if plugin_cmds != expected:
    for x in sorted(expected - plugin_cmds):
        print(f"FAIL hooks.json missing {x}")
    for x in sorted(plugin_cmds - expected):
        print(f"FAIL hooks.json extra {x}")
    ok = False

if ok:
    print(f"ok   plugin.json has no agents/hooks key; hooks.json matches settings.json ({len(plugin_cmds)} hooks)")
sys.exit(0 if ok else 1)
EOF

exit "$fail"
