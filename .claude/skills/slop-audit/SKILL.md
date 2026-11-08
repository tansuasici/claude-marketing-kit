---
name: slop-audit
description: Check a draft for hype words, filler, structural tells and sentences a competitor could post unchanged, judge each against MARKETING_MAP.md → Voice, and propose a specific rewrite for every one. Use before calling any copy done.
---

# slop-audit

Check one draft for slop: the words, phrases and shapes that make copy read as machine-written or interchangeable. The lists and the tells are in `agent_docs/slop-signs.md`; read it first. This file is the procedure.

The `slop-scan` hook counts list words, em-dashes and emoji bullets. This skill does the part it can't: the soft words in context, the structural tells, the competitor test and the fit with this product's voice. The `brand-voice-reviewer` agent gives a second read from a context that didn't write the draft.

## Input

The draft is the file the user names (`$ARGUMENTS`). If none is named, ask which one. One file per run.

## Rules

- **Report first, edit after a yes.** This skill changes nothing on its own. Every rewrite is proposed; the user picks which go in.
- **A rewrite says something specific, or the sentence goes.** Swapping one adjective for a softer one is not a fix. Prefer a fact from the product (a command, a number with an Evidence row, a named feature); if there is none, propose the cut.
- **No new claims in a rewrite.** A replacement that adds a number, a comparison or a user count needs an Evidence row like any other claim (`agent_docs/claims-and-evidence.md`). If it has none, write it with `[NEEDS PROOF]` or choose a different rewrite.
- **Quotes keep their words.** Blockquotes and text in double quotes from `Customer language` or `Evidence` are not slop findings; never reword them.
- **Allowed words are allowed.** Skip terms on the `- **Allowed words:**` line in `MARKETING_MAP.md → Voice`. Don't add one yourself: that line is part of Voice and needs the user's yes (`CLAUDE.md → Approval Required`).

## Steps

1. **Load.** Read `MARKETING_MAP.md → Product, Positioning, Voice, Banned words, Evidence` and the draft.
2. **List pass.** If `.claude/hooks/lib/slop_scan.py` exists, run `python3 .claude/hooks/lib/slop_scan.py <draft> agent_docs/slop-signs.md MARKETING_MAP.md` and start from its output. Otherwise go through the `slop-hard`, `slop-soft` and `slop-filler` blocks and `Banned words` by hand. Hard words, banned words and filler phrases are findings; a soft word is a finding only when it has no concrete object or several appear together.
3. **Structural tells.** Go through `slop-signs.md → Structural tells` one by one: the opener, rules of three, "It's not X, it's Y", emoji and hashtags, em-dash density, the closing line (cut it and check whether anything was lost), sentence length, unattributed superlatives. Name the sentence for each one you find.
4. **Competitor test.** Take `Positioning → Against` (or, if it's blank, the nearest alternative a buyer would name) and swap it in for the product name in every sentence that describes the product. A sentence that still reads true fails.
5. **Voice.** Read the draft against `Voice → Sounds like`, `Never sounds like` and `Person and tense`. Flag lines that break them (a "we" in an "I" voice, press-release phrasing when it should sound like a PR description). If Voice is still the template, say so and skip this step.
6. **Rewrite.** For each finding, propose one replacement that passes steps 2–5, or propose the cut.
7. **Report** in this shape, then stop and wait:

```
slop-audit: <file>  —  <n> findings: <a> words, <b> tells, <c> fail competitor test, <d> off voice

Words
- "<sentence>" — <word> (<hard / soft / filler / banned>). Proposed: "<rewrite>" | cut

Structural tells
- "<sentence>" — <tell>. Proposed: "<rewrite>" | cut

Competitor test (swapped in: <alternative>)
- "<sentence>" — reads true for <alternative>. Proposed: "<rewrite that only fits this product>"

Off voice
- "<sentence>" — <which Voice line it breaks>. Proposed: "<rewrite>"

New claims in rewrites
- "<rewrite>" — needs <Evidence row / [NEEDS PROOF]>
```

Leave out an empty group. If there are no findings, say so in one line and that the draft can move to the rest of `CLAUDE.md → Verification`. After the user picks rewrites, apply exactly those and run `claim-audit` if any of them added a claim.
