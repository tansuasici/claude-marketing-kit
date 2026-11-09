"""claim_scan.py — scanner behind .claude/hooks/claim-scan.sh

Usage:
  python3 claim_scan.py pre  MARKETING_MAP_MD  < hook-input.json
  python3 claim_scan.py post MARKETING_MAP_MD FILE

pre  (PreToolUse, Write / Edit / MultiEdit): reads the text about to be
     written. Exits 2 and prints the reason when it holds social proof with
     no backing: a quote attributed to a named person, or "trusted by /
     used by …", "as seen in", "featured in". Backed means an Evidence row
     names the person or the phrase, or the line carries [NEEDS PROOF] or
     [SLOT: …]. Otherwise exits 0, silent.

post (PostToolUse): reads FILE. Prints a warning for numbers, prices and
     superlatives ("the only", "#1", …) that have no Evidence row and no
     [NEEDS PROOF] mark on the line, and counts the marks still open.
     Always exits 0.

The rules live in agent_docs/claims-and-evidence.md.
"""

import json
import re
import sys

MAX_FINDINGS = 20
MARK = re.compile(r"\[(NEEDS PROOF|SLOT)\b[^\]]*\]")

NUM = re.compile(
    r"(?<![\w.#/:@-])"                 # not part of v2, #12, 3.0.1, 9:16, @2x
    r"([$€£]\s?)?"
    r"(\d{1,3}(?:,\d{3})+|\d+)(?:\.\d+)?"
    r"(\s?(?:%|percent\b|[x×](?!\w)|[kKmM](?!\w)|\+))?"
    r"(?![\w:/-]|\.\d)"
)
YEAR = re.compile(r"^(19|20)\d\d$")
LIST_MARKER = re.compile(r"^\s*(?:[-*+]\s+)?\d+[.)]\s")
SUPERLATIVE = re.compile(
    r"\b(the only|the first|the fastest|the best|the leading|number one|world'?s (?:first|best|fastest|only)|"
    r"industry[- ]leading|best[- ]in[- ]class)\b|(?<![\w#])#1(?!\d)",
    re.I,
)
SOCIAL = re.compile(
    r"\b(?:(?:trusted|used|loved|chosen|relied on|adopted) by"
    r"(?: over| more than| thousands of| hundreds of| millions of)?"
    r"(?: \d[\d,.]*[kKmM]?\+?)?"
    # Up to two qualifiers ("500 engineering teams"), but not a word that starts
    # a plain description ("used by your customers", "used by CI to notify users").
    r"(?: (?!(?:your|our|my|their|its|the|this|that|these|those|a|an|and|or|other|"
    r"to|for|in|with|of|on|at|from)\b)[\w-]+){0,2}"
    r" (?:teams|companies|developers|devs|engineers|customers|users|startups|businesses|brands|"
    r"organi[sz]ations|people|founders|makers)\b(?: at\b)?"
    r"|as (?:seen|featured) (?:in|on)\b)",
    re.I,
)
NAME = r"(@\w+|[A-Z][\w.'’-]+(?:\s+[A-Z][\w.'’-]+){0,3})"
# After a quote on the same line: "— Jane Doe, CTO" / "- Jane Doe" / "~ @jane".
INLINE_ATTR = re.compile(r"^[\s,.]*(?:[—–~]|--|-)\s*" + NAME)
# On the line after a quote: only — – ~ or --, so a "- list item" is not a name.
NEXT_ATTR = re.compile(r"^\s*(?:>\s*)*(?:[—–~]|--)\s*" + NAME)
QUOTE = re.compile(r"\"[^\"]{8,}\"|“[^”]{8,}”")


def read(path):
    try:
        with open(path, encoding="utf-8", errors="replace") as fh:
            return fh.read()
    except OSError:
        return ""


def evidence_rows(mapping):
    """Evidence table rows as cell lists; header, divider and <placeholder> rows dropped."""
    m = re.search(r"^## Evidence[ \t]*\n(.*?)(?=^## |\Z)", mapping, re.S | re.M)
    if not m:
        return []
    rows = []
    for line in m.group(1).splitlines():
        s = line.strip()
        if not s.startswith("|") or re.match(r"^\|[\s|:-]+\|$", s) or "<" in s:
            continue
        cells = [c.strip().lower().replace(",", "") for c in s.strip("|").split("|")]
        if cells and cells[0] != "claim":
            rows.append(cells)
    return rows


def evidence(mapping):
    """Whole rows: names and phrases may be backed from any column."""
    return " ".join(" ".join(r) for r in evidence_rows(mapping))


def evidence_claims(mapping):
    """Claim column only: numbers are matched here, so a Checked date or an
    issue number in Source never backs a number in a draft."""
    return " ".join(r[0] for r in evidence_rows(mapping))


def strip_noise(text):
    """Blank out code, comments and URLs; line numbers are kept."""
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
        line = re.sub(r"`[^`]*`", " ", line)
        line = re.sub(r"https?://\S+|\]\([^)]*\)", " ", line)
        line = re.sub(r"<[^>]+>", " ", line)
        out.append(line)
    return out


def backed(token, ev):
    digits = token.replace(",", "")
    return bool(ev) and re.search(r"(?<![\d.])" + re.escape(digits) + r"(?![\d])", ev) is not None


# ---- pre: block unbacked social proof ---------------------------------------

def proposed_text(hook):
    ti = hook.get("tool_input") or {}
    parts = [ti.get("content") or "", ti.get("new_string") or ""]
    for e in ti.get("edits") or []:
        parts.append(e.get("new_string") or "")
    return "\n".join(p for p in parts if p)


def social_proof(lines, ev):
    problems = []
    for i, line in enumerate(lines):
        if not line.strip() or MARK.search(line):
            continue
        m = SOCIAL.search(line)
        if m:
            if m.group(0).lower().replace(",", "") not in ev:  # rows are stored without commas
                problems.append(f"  \"{line.strip()[:100]}\": \"{m.group(0)}\" with no Evidence row")
            continue
        # A quote (or blockquote) with an attribution after it, same line or next.
        q = QUOTE.search(line)
        if not q and not line.lstrip().startswith(">"):
            continue
        nxt = lines[i + 1] if i + 1 < len(lines) else ""
        a = (INLINE_ATTR.match(line[q.end():]) if q else None) or NEXT_ATTR.match(nxt)
        if not a or MARK.search(nxt):
            continue
        who = a.group(1).strip()
        if who.lower() in ev:
            continue
        problems.append(f"  quote attributed to \"{who}\": no Evidence row names them")
    return problems


def pre(map_path):
    try:
        hook = json.load(sys.stdin)
    except (ValueError, OSError):
        return 0
    lines = strip_noise(proposed_text(hook))
    problems = social_proof(lines, evidence(read(map_path)))
    if not problems:
        return 0
    print("BLOCKED by claim-scan: social proof with no source.")
    print("\n".join(problems[:MAX_FINDINGS]))
    print("Never invent a testimonial, name, logo or \"used by\" line (agent_docs/claims-and-evidence.md → Never invent). "
          "Add an Evidence row that names the person or the phrase, or leave a labelled slot: [SLOT: customer quote, needs a real one].")
    return 2


# ---- post: warn on unbacked numbers and superlatives ------------------------

def post(map_path, path):
    ev = evidence_claims(read(map_path))
    lines = strip_noise(read(path))
    findings = []
    for n, line in enumerate(lines, 1):
        if not line.strip() or MARK.search(line):
            continue
        body = LIST_MARKER.sub(" ", line)
        nums = []
        for m in NUM.finditer(body):
            token, bare = m.group(2), not m.group(1) and not m.group(3)
            # Bare years and bare single digits ("2 commands") are not flagged.
            if bare and (YEAR.match(token) or (len(token) == 1 and not m.group(0)[1:2] == ".")):
                continue
            if not backed(token, ev):
                nums.append(m.group(0).strip())
        if nums:
            findings.append(f"  L{n} number: {', '.join(dict.fromkeys(nums))}")
        sup = [m.group(0) for m in SUPERLATIVE.finditer(line)]
        if sup:
            findings.append(f"  L{n} superlative: {', '.join(dict.fromkeys(s.lower() for s in sup))} (needs a row and user approval)")
    marks = len(re.findall(r"\[NEEDS PROOF\b", "\n".join(lines)))
    if not findings and not marks:
        return ""
    out = []
    if findings:
        more = len(findings) - MAX_FINDINGS
        out.append(f"[claim-scan] {path}: {len(findings)} claim(s) with no Evidence row.")
        out += findings[:MAX_FINDINGS] + ([f"  … and {more} more"] if more > 0 else [])
        out.append("Add a row to MARKETING_MAP.md → Evidence, mark the sentence [NEEDS PROOF: reason], or cut it "
                   "(agent_docs/claims-and-evidence.md).")
    if marks:
        out.append(f"[claim-scan] {marks} [NEEDS PROOF] mark(s) open in this file: the draft is not done until each is cleared.")
    return "\n".join(out)


if __name__ == "__main__":
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    map_path = sys.argv[2] if len(sys.argv) > 2 else ""
    try:
        if mode == "pre":
            sys.exit(pre(map_path))
        if mode == "post" and len(sys.argv) > 3:
            report = post(map_path, sys.argv[3])
            if report:
                print(report)
    except SystemExit:
        raise
    except Exception:  # never break an edit on a scanner bug
        pass
    sys.exit(0)
