---
name: claim-audit
description: Check every claim in a draft against MARKETING_MAP.md → Evidence, mark the unbacked ones [NEEDS PROOF], flag overstatements and the claims that need approval, and report each with its sentence and row. Use before calling any copy done.
---

# claim-audit

Check one draft, sentence by sentence, against `MARKETING_MAP.md → Evidence`. The rules for what is a claim and what counts as proof are in `agent_docs/claims-and-evidence.md`; read it first. This file is the procedure.

The hooks catch shapes (a number with no row, an attributed quote). This skill does the part they can't: whether the row actually backs the sentence. The `claim-checker` agent gives a second check from a context that didn't write the draft.

## Input

The draft is the file the user names (`$ARGUMENTS`). If none is named, ask which one. One file per run.

## Rules

- **The draft may say less than the row, never more.** Match on meaning, not wording.
- **Marks go in, nothing else changes on its own.** You may add `[NEEDS PROOF: reason]` marks to the draft. Every other edit (a rewrite of an overstated line, a cut) is proposed and made only after the user says yes.
- **No new Evidence from nothing.** You may propose an Evidence row when you found the source yourself (a file path, a changelog entry, a link) and show it. Numbers need a measurement or a link with a date; never estimate one. Add the row after the user confirms.
- **Don't remove a mark** to make the draft look finished. A mark leaves only when a row is added or the sentence is cut.

## Steps

1. **Load.** Read `MARKETING_MAP.md → Evidence, Customer language, Positioning` and the draft.
2. **Split and classify.** Go sentence by sentence (headings, captions, button text and alt text count). For each, decide claim or not, using the kinds table in `claims-and-evidence.md → What is a claim`.
3. **Match.** For each claim, find the Evidence row that backs it. A quote must appear verbatim in `Customer language` or `Evidence`, with a source and permission to quote.
4. **Overstatement.** Compare the sentence with its row: bigger number, wider scope ("all", "every", "any"), stronger verb ("eliminates" for "reduces"), a present-tense feature the changelog calls planned.
5. **Staleness.** A row whose `Checked` date is over ~90 days old, or blank, is stale for numbers and public metrics.
6. **Approval.** Every comparison with a named competitor, number, guarantee or price needs the user's approval before it ships (`CLAUDE.md → Approval Required`), even when it has a row.
7. **Mark.** Add `[NEEDS PROOF: reason]` after each claim with no row, using the exact spelling from `claims-and-evidence.md`. Leave sentences that already carry a mark alone.
8. **Report** in this shape, then stop and wait:

```
claim-audit: <file>  —  <n> claims: <a> backed, <b> marked, <c> overstated, <d> stale, <e> need approval

Backed
- "<sentence>" → <Evidence row claim> (<source>, <checked>)

Marked [NEEDS PROOF]
- "<sentence>" — <what would clear it: run X / link the issue / ask a user>

Overstated
- "<sentence>" → row says "<row claim>". Proposed: "<rewrite that says no more than the row>"

Stale
- "<sentence>" → <row>, checked <date>. Recheck with <how>.

Needs approval
- "<sentence>" — <comparison / number / guarantee / price>

Proposed Evidence rows
| <claim> | <source you found> | <today> |
```

Leave out an empty group. If every claim is backed, nothing is stale or overstated and nothing waits on approval, say so in one line; the draft can move to the rest of `CLAUDE.md → Verification`.
