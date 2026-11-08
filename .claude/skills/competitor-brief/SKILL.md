---
name: competitor-brief
description: Write one internal page on one alternative the buyer uses today (a tool, a script, doing nothing), using only facts you can link, with what it does better, what we do better (each backed by Evidence) and when to recommend it instead. Use before positioning against it or writing a comparison.
---

# competitor-brief

Write a one-page brief on one alternative. The fields and the linking rule are in `agent_docs/positioning.md → Competitor briefs`; read it first, along with `agent_docs/claims-and-evidence.md → What counts as proof`. This file is the procedure.

The brief is internal research. It feeds `positioning` and comparison copy; it is not copy itself.

## Input

The alternative to cover (`$ARGUMENTS`): a product name, a URL, or a habit ("a cron script", "a spreadsheet"). If none is given, use `MARKETING_MAP.md → Positioning → Against`; if that is blank too, ask. One alternative per run.

The file is `research/competitors/<slug>.md`. If it exists, this run is a recheck: update the lines that changed and the `Checked` date, and say what changed.

## Rules

- **Only what you can link.** Every fact about the alternative has a URL to its own site, docs, repo, changelog or a public user's post. No link, no line. A competitor's own marketing is quoted as theirs (who said it, where), never restated as fact.
- **No inferred weaknesses.** "It's slow" or "it's hard to set up" needs a source that says so (an issue, a benchmark with a link, a user's post). Otherwise leave it out.
- **Our side needs Evidence.** Each line under "What we do that it doesn't" points at a `MARKETING_MAP.md → Evidence` row, or carries `[NEEDS PROOF]`.
- **Be fair.** "What it does that we don't" is never empty for a real product. If you can't find anything, you haven't read enough of their docs.
- **Fetch, don't recall.** Read the pages in this run; don't fill fields from memory. If a page can't be fetched, say so and leave the field open.
- **Internal only.** Naming the alternative, or any price, limit or flaw of theirs, in public copy needs the user's approval (`CLAUDE.md → Approval Required`). The brief can name them; drafts can't without that yes.

## Steps

1. **Load.** Read `MARKETING_MAP.md → Product, Audience, Positioning, Evidence, Customer language`.
2. **Read the alternative.** Its homepage, docs (install and limits pages first), README, changelog, pricing page if public, and its open issues. For a habit with no product page ("a bash script", "nothing"), read how users in `Customer language` and the issues describe doing it today.
3. **Find what users say.** Search our own issues and `Customer language` for the alternative's name: why they left it, what they miss. Quote verbatim with source.
4. **Write the brief** in this shape:

```markdown
# <Alternative>

| Field | Content |
|---|---|
| What it is | "<their own one-line description>" (<URL>) |
| Who uses it | <from their docs or public users, linked> |
| What it does that we don't | <each line linked> |
| What we do that it doesn't | <each line → Evidence row, or [NEEDS PROOF]> |
| When to recommend them instead | <the reader they fit better> |
| Checked | <today> |

## What users say
- "<verbatim>" — <source, date>

## Sources
- <every URL read in this run>
```

5. **Report**, then stop:
   - the file path;
   - whether `Positioning → Against` and `Why switch` still hold against what you found, and if not, that `positioning` is the next step;
   - every `[NEEDS PROOF]` on our side, with what would clear it;
   - fields you left open because a page couldn't be read.
