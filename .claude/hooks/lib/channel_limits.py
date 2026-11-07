"""channel_limits.py — scanner behind .claude/hooks/channel-limits.sh

Usage: python3 channel_limits.py FILE [REL_PATH]

REL_PATH (FILE relative to the project) is what the path tokens are read
from, so a parent folder outside the project never picks the channel.

Finds the draft's channel (frontmatter `channel: x`, else a path or file-name
token such as drafts/x/ or launch.linkedin.md), counts each post in it and
prints the counts against that channel's limits. Prints nothing when no
channel is found. Always exits 0.

The numbers mirror agent_docs/channels.md (last checked 2026-11-07); change
both together. tests/hooks/channel-limits.test.sh fails if they drift.
"""

import re
import sys

ALIASES = {
    "x": "x", "twitter": "x", "linkedin": "linkedin", "instagram": "instagram", "ig": "instagram",
    "facebook": "facebook", "fb": "facebook", "youtube": "youtube", "yt": "youtube", "tiktok": "tiktok",
}
NAMES = {"x": "X", "linkedin": "LinkedIn", "instagram": "Instagram", "facebook": "Facebook",
         "youtube": "YouTube", "tiktok": "TikTok"}
# Post limit, visible-before-"more" length, hashtag cap: agent_docs/channels.md
LIMIT = {"x": 280, "linkedin": 3000, "instagram": 2200, "tiktok": 2200}
VISIBLE = {"linkedin": 140, "instagram": 125}
HASHTAGS = {"x": 2, "instagram": 30}
YT_TITLE, YT_TITLE_SHOWN, YT_DESCRIPTION = 100, 70, 5000
X_LINK = 23

URL = re.compile(r"https?://\S+")
HASHTAG = re.compile(r"(?<![\w&])#\w+")
# Emoji and CJK count as 2 under X's weighting (third-party, see channels.md).
WIDE = re.compile(
    "[ᄀ-ᅟ⺀-꓏가-힣豈-﫿︰-﹏＀-｠￠-￦"
    "\U0001f000-\U0001faff\U00020000-\U0003fffd☀-➿]"
)


def read(path):
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            return fh.read()
    except OSError:
        return ""


def split_frontmatter(text):
    m = re.match(r"^---[ \t]*\n(.*?)\n---[ \t]*(?:\n|\Z)", text, re.S)
    return (m.group(1), text[m.end():]) if m else ("", text)


def channel_of(path, front):
    m = re.search(r"^channel:\s*['\"]?([\w-]+)", front, re.M | re.I)
    if m:
        return ALIASES.get(m.group(1).lower())
    for token in reversed(re.split(r"[/\\._-]+", path.lower())):
        if token in ALIASES:
            return ALIASES[token]
    return None


def posts(body):
    """Body split on `---` lines; HTML comments (notes to self) dropped."""
    body = re.sub(r"<!--.*?-->", "", body, flags=re.S)
    parts = re.split(r"^\s*---+\s*$", body, flags=re.M)
    return [p.strip() for p in parts if p.strip()]


def x_length(text):
    text = URL.sub("x" * X_LINK, text)
    return len(text) + len(WIDE.findall(text))


def first_paragraph(text):
    return re.split(r"\n\s*\n", text, 1)[0].strip()


def check(channel, text, n, total):
    """Report lines for one post, and whether it is over a hard limit."""
    label = f"post {n}/{total}" if total > 1 else "post"
    out = []
    if channel == "youtube":
        lines = text.splitlines()
        title = re.sub(r"^#+\s*", "", lines[0]).strip()
        desc = "\n".join(lines[1:]).strip()
        flag = "  OVER" if len(title) > YT_TITLE else ""
        out.append(f"  {label}: title {len(title)}/{YT_TITLE}{flag}, description {len(desc)}/{YT_DESCRIPTION}"
                   + ("  OVER" if len(desc) > YT_DESCRIPTION else ""))
        bad = bool(re.search(r"[<>]", title))
        if bad:
            out.append("    title has < or >: YouTube rejects them")
        elif YT_TITLE_SHOWN < len(title) <= YT_TITLE:
            out.append(f"    title past ~{YT_TITLE_SHOWN}: search and mobile cut it; put the specific noun first")
        return out, bad or len(title) > YT_TITLE or len(desc) > YT_DESCRIPTION
    if channel == "facebook":
        out.append(f"  {label}: {len(text)} characters; no verified limit, check the composer")
        return out, False
    count = x_length(text) if channel == "x" else len(text)
    limit = LIMIT[channel]
    note = " (links as 23, emoji/CJK as 2)" if channel == "x" else ""
    out.append(f"  {label}: {count}/{limit}{note}" + (f"  OVER by {count - limit}" if count > limit else ""))
    tags = HASHTAG.findall(text)
    cap = HASHTAGS.get(channel)
    if cap is not None and len(tags) > cap:
        out.append(f"    {len(tags)} hashtags, the cap here is {cap}")
    vis = VISIBLE.get(channel)
    opening = first_paragraph(text)
    if vis and len(opening) > vis:
        out.append(f"    opening is {len(opening)} characters; about {vis} show before \"more\", cut at \"…{opening[vis - 40:vis]}\"")
    if channel == "instagram" and URL.search(text):
        out.append("    caption has a link: Instagram links are not clickable, say \"link in bio\" only if the bio has one")
    return out, count > limit


def scan(path, rel=None):
    front, body = split_frontmatter(read(path))
    channel = channel_of(rel or path, front)
    if not channel:
        return ""
    items = posts(body)
    if not items:
        return ""
    lines, over = [], False
    for i, text in enumerate(items, 1):
        out, bad = check(channel, text, i, len(items))
        lines += out
        over = over or bad
    head = f"[channel-limits] {rel or path}: {NAMES[channel]}, counted by the hook."
    split = ", or split into a thread" if channel == "x" else ""
    tail = (f"Cut to fit{split}; never truncate mid-sentence." if over else
            "Report these as counted lengths.")
    return "\n".join([head] + lines + [tail + " Limits: agent_docs/channels.md."])


if __name__ == "__main__":
    try:
        if len(sys.argv) > 1:
            report = scan(sys.argv[1], sys.argv[2] if len(sys.argv) > 2 else None)
            if report:
                print(report)
    except Exception:  # never break an edit on a scanner bug
        pass
    sys.exit(0)
