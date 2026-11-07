"""slop_scan.py — scanner behind .claude/hooks/slop-scan.sh

Usage: python3 slop_scan.py FILE SLOP_SIGNS_MD [MARKETING_MAP_MD]

Reads the fenced ```slop-hard / ```slop-soft / ```slop-filler lists from
agent_docs/slop-signs.md, adds MARKETING_MAP.md → Banned words, drops
MARKETING_MAP.md → Voice → **Allowed words:**, and scans FILE. Prints a report
when something is found, nothing otherwise. Always exits 0.

Skipped text: fenced code, inline code, HTML comments, blockquotes, quoted
spans ("…" and “…”: customer words keep their wording) and URLs.
"""

import re
import sys

MAX_FINDINGS = 20
SOFT_CLUSTER = 3   # distinct soft words in one paragraph
EM_DASHES = 3      # em-dashes in one paragraph
EMOJI_LINES = 3    # lines that open with an emoji


def read(path):
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            return fh.read()
    except OSError:
        return ""


def fenced_lists(signs):
    lists = {"slop-hard": [], "slop-soft": [], "slop-filler": []}
    for kind, body in re.findall(r"^```(slop-hard|slop-soft|slop-filler)[ \t]*\n(.*?)^```", signs, re.S | re.M):
        for line in body.splitlines():
            line = line.strip()
            if line and not line.startswith("#"):
                lists[kind].append(line)
    return lists


def section(text, heading):
    m = re.search(r"^## " + re.escape(heading) + r"[ \t]*\n(.*?)(?=^## |\Z)", text, re.S | re.M)
    return re.sub(r"<!--.*?-->", "", m.group(1), flags=re.S) if m else ""


def terms(csv):
    out = []
    for t in csv.split(","):
        t = t.strip().strip("`*_").strip()
        if t and "<" not in t and "..." not in t:
            out.append(t.lower())
    return out


def map_terms(mapping):
    banned, allowed = [], []
    for line in section(mapping, "Banned words").splitlines():
        if line.lstrip().startswith(("- ", "* ")):
            banned += terms(line.lstrip()[2:])
    for line in section(mapping, "Voice").splitlines():
        m = re.search(r"\*\*Allowed words:\*\*(.*)", line)
        if m:
            allowed += terms(m.group(1))
    return banned, allowed


def word_re(word):
    # Whole word, plus common inflections: unlock → unlocks, unlocked, unlocking.
    return re.compile(r"(?<![\w-])" + re.escape(word) + r"(?:s|es|d|ed|ing)?(?![\w-])", re.I)


def is_emoji(ch):
    cp = ord(ch)
    return 0x1F300 <= cp <= 0x1FAFF or 0x2600 <= cp <= 0x27BF


def prose_lines(text):
    """FILE as lines with non-prose blanked out; line numbers are kept."""
    text = re.sub(r"<!--.*?-->", lambda m: "\n" * m.group(0).count("\n"), text, flags=re.S)
    out, fence = [], None
    for line in text.splitlines():
        s = line.strip()
        m = re.match(r"(`{3,}|~{3,})", s)
        if fence:
            if m and s.startswith(fence):
                fence = None
            out.append("")
            continue
        if m:
            fence = m.group(1)
            out.append("")
            continue
        if s.startswith(">"):
            out.append("")
            continue
        line = re.sub(r"`[^`]*`", " ", line)
        line = re.sub(r"https?://\S+|\]\([^)]*\)", " ", line)
        line = re.sub(r"<[^>]+>", " ", line)
        line = re.sub(r"\"[^\"]*\"|“[^”]*”", " ", line)
        out.append(line)
    return out


def paragraphs(lines):
    start, buf = None, []
    for i, line in enumerate(lines, 1):
        if line.strip():
            if start is None:
                start = i
            buf.append(line)
        elif buf:
            yield start, " ".join(buf)
            start, buf = None, []
    if buf:
        yield start, " ".join(buf)


def scan(path, signs_path, map_path):
    lists = fenced_lists(read(signs_path))
    banned, allowed = map_terms(read(map_path)) if map_path else ([], [])
    allowed = set(allowed)

    hard = sorted({w.lower() for w in lists["slop-hard"] + banned} - allowed)
    soft = sorted({w.lower() for w in lists["slop-soft"]} - allowed - set(hard))
    hard_res = [(w, word_re(w)) for w in hard]
    soft_res = [(w, word_re(w)) for w in soft]
    filler_res = []
    for p in lists["slop-filler"]:
        try:
            filler_res.append(re.compile(p, re.I))
        except re.error:
            pass

    lines = prose_lines(read(path))
    findings, hard_count = [], 0

    for n, line in enumerate(lines, 1):
        hits = []
        for w, rx in hard_res:
            k = len(rx.findall(line))
            if k:
                hits.append(w)
                hard_count += k
        if hits:
            findings.append(f"  L{n} hype: {', '.join(hits)}")
        for rx in filler_res:
            m = rx.search(line)
            if m:
                findings.append(f"  L{n} filler: \"{m.group(0).strip()}\"")

    for start, para in paragraphs(lines):
        found = [w for w, rx in soft_res if rx.search(para)]
        if len(found) >= SOFT_CLUSTER:
            findings.append(f"  L{start} soft-word cluster: {', '.join(found)}")
        dashes = para.count("—")
        if dashes >= EM_DASHES:
            findings.append(f"  L{start} {dashes} em-dashes in one paragraph")

    emoji = [n for n, line in enumerate(lines, 1)
             if (s := re.sub(r"^[-*+]\s+", "", line.strip())) and is_emoji(s[0])]
    if len(emoji) >= EMOJI_LINES:
        findings.append(f"  L{emoji[0]} {len(emoji)} lines open with an emoji (emoji bullets)")

    if not findings:
        return ""
    more = len(findings) - MAX_FINDINGS
    body = findings[:MAX_FINDINGS] + ([f"  … and {more} more"] if more > 0 else [])
    head = f"[slop-scan] {path}: {len(findings)} finding(s), {hard_count} hype word(s)."
    tail = ("Rewrite each with a concrete fact (agent_docs/slop-signs.md). A term that is the literal "
            "truth goes in MARKETING_MAP.md → Voice → **Allowed words:**. Silence from this hook is not "
            "a review: still run the competitor test.")
    return "\n".join([head] + body + [tail])


if __name__ == "__main__":
    if len(sys.argv) < 3:
        sys.exit(0)
    try:
        report = scan(sys.argv[1], sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else "")
    except Exception:  # warn-only hook: never break the edit
        report = ""
    if report:
        print(report)
