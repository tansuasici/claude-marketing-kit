"""publish_gate.py — decision behind .claude/hooks/publish-gate.sh

Usage: python3 publish_gate.py MARKETING_MAP_MD < hook-input.json

Reads a PreToolUse call to an MCP tool. Prints nothing (allow, no change)
unless the tool publishes, schedules or queues a post. For those it prints a
hookSpecificOutput JSON with:

  deny  no MARKETING_MAP.md, or the post's channel (every channel, when the
        call does not name one) has `publish` off in the Channels table
  ask   the channel is on: the user sees the channel, time and text in the
        permission prompt, and their answer is the approval for this post

Saving a draft or an idea is allowed silently (CLAUDE.md → Publishing).
Always exits 0.
"""

import json
import re
import sys

# Tool-name part after the last "__", lowercased. Matched as whole words
# split on _ - . so "notion-update-page" and "send_message" stay out.
PUBLISH = re.compile(
    r"(?:^|[_.-])(?:publish\w*|schedule\w*|queue\w*|create_post|edit_post|update_post|send_post|"
    r"share_post|post_now|share_now|tweet|create_tweet|create_update)(?:$|[_.-])"
)
DRAFT = re.compile(r"draft|idea", re.I)
ALIASES = {
    "x": "x", "twitter": "x", "linkedin": "linkedin", "instagram": "instagram", "ig": "instagram",
    "facebook": "facebook", "fb": "facebook", "youtube": "youtube", "yt": "youtube", "tiktok": "tiktok",
}
NAMES = {"x": "X", "linkedin": "LinkedIn", "instagram": "Instagram", "facebook": "Facebook",
         "youtube": "YouTube", "tiktok": "TikTok"}
TEXT_KEYS = ("text", "content", "body", "caption", "message", "status", "title")
TIME_KEYS = ("dueAt", "due_at", "scheduledAt", "scheduled_at", "scheduleTime", "publishAt", "publish_at", "time", "when")
PREVIEW = 280


def read(path):
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            return fh.read()
    except OSError:
        return ""


def channel_flags(mapping):
    """{channel: True/False} from MARKETING_MAP.md → Channels (last cell = publish)."""
    m = re.search(r"^## Channels[ \t]*\n(.*?)(?=^## |\Z)", mapping, re.S | re.M)
    flags = {}
    if not m:
        return flags
    for line in m.group(1).splitlines():
        s = line.strip()
        if not s.startswith("|") or re.match(r"^\|[\s|:-]+\|$", s):
            continue
        cells = [c.strip() for c in s.strip("|").split("|")]
        key = ALIASES.get(cells[0].lower()) if cells else None
        if key:
            flags[key] = cells[-1].lower() == "on"
    return flags


def walk(value, key=""):
    """(key, value) pairs for every leaf, keys included as values too."""
    if isinstance(value, dict):
        for k, v in value.items():
            yield key, k
            yield from walk(v, k)
    elif isinstance(value, list):
        for v in value:
            yield from walk(v, key)
    else:
        yield key, value


def is_draft(ti):
    for k, v in walk(ti):
        if v is True and DRAFT.search(str(k)):
            return True
        if isinstance(v, str) and k.lower() in ("mode", "status", "type", "state") and v.lower() == "draft":
            return True
    return False


def channels_named(ti):
    """Channels named anywhere in the call: a service field, a metadata key."""
    found = []
    for _, v in walk(ti):
        if isinstance(v, str):
            c = ALIASES.get(v.strip().lower())
            if c and c not in found:
                found.append(c)
    return found


def first(ti, keys):
    for k in keys:
        v = ti.get(k)
        if isinstance(v, str) and v.strip():
            return v.strip()
    return ""


def decide(hook, map_path):
    name = hook.get("tool_name") or ""
    if not name.startswith("mcp__"):
        return None
    tool = name.split("__")[-1].lower()
    ti = hook.get("tool_input") or {}
    if not PUBLISH.search(tool) or DRAFT.search(tool) or is_draft(ti):
        return None

    mapping = read(map_path)
    if not mapping:
        return "deny", (f"BLOCKED by publish-gate: {name} publishes, and there is no MARKETING_MAP.md, so every channel is off. "
                        "Save it as a draft instead, or fill MARKETING_MAP.md → Channels and set publish: on with the user.")
    flags = channel_flags(mapping)
    named = channels_named(ti)
    on = [c for c, v in flags.items() if v]
    if named:
        off = [c for c in named if not flags.get(c)]
        if off:
            return "deny", (f"BLOCKED by publish-gate: {', '.join(NAMES[c] for c in off)} has publish: off in "
                            "MARKETING_MAP.md → Channels. Save it as a draft instead. Turning a channel on needs the user's approval.")
        where = ", ".join(NAMES[c] for c in named)
    elif not on:
        return "deny", ("BLOCKED by publish-gate: every channel has publish: off in MARKETING_MAP.md → Channels. "
                        "Save it as a draft instead. Turning a channel on needs the user's approval.")
    else:
        where = "not named in the call; publish: on for " + ", ".join(NAMES[c] for c in on)

    text = first(ti, TEXT_KEYS)
    when = first(ti, TIME_KEYS) or (f"mode {ti['mode']}" if isinstance(ti.get("mode"), str) else "not given (queue default)")
    preview = text[:PREVIEW] + ("…" if len(text) > PREVIEW else "") if text else "(no text in the call)"
    return "ask", (f"publish-gate: {name} will publish.\n"
                   f"Channel: {where}\nTime: {when}\nText: {preview}\n"
                   "Approving this prompt approves this one post only.")


def main():
    map_path = sys.argv[1] if len(sys.argv) > 1 else ""
    try:
        hook = json.load(sys.stdin)
    except (ValueError, OSError):
        return 0
    try:
        result = decide(hook, map_path)
    except Exception:  # a gate bug must not let a publish through unasked
        name = str(hook.get("tool_name") or "")
        result = ("ask", f"publish-gate could not read {name}; check the post before approving.") \
            if name.startswith("mcp__") and PUBLISH.search(name.split("__")[-1].lower()) else None
    if result:
        decision, reason = result
        print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse",
                                                 "permissionDecision": decision,
                                                 "permissionDecisionReason": reason}}))
    return 0


if __name__ == "__main__":
    sys.exit(main())
