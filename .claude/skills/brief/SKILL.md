---
name: brief
description: Fill MARKETING_MAP.md (Product, Audience, Positioning, Voice) one section at a time, from the repo first and then short questions to the user. Use when the map is still the template or the user asks to (re)write the brief.
---

# brief

Fill `MARKETING_MAP.md → Product, Audience, Positioning, Voice` with the user, so every later draft has something true to stand on. The field guidance is in `agent_docs/positioning.md`; read it first. This file is the procedure.

## Rules

- **Nothing you weren't told or can't link.** Every line comes from the repo, a user's words or the author's answer. If none of them supports a line, leave the `<...>` and say what would fill it.
- **One section at a time.** Ask, propose, wait, write, then move on. Never dump all four sections in one message.
- **Ask little.** Ask only what the repo can't answer, at most three questions per section, each one short.
- **Approval.** Audience, Positioning and Voice need the user's explicit yes before you write them (`CLAUDE.md → Approval Required`). Show the exact lines that will go into the map, then wait. Product can be written once the user confirms it.
- **Only the map.** Don't write copy, drafts or a README change during this skill.

## Steps

### 0. Read before asking
1. Read `MARKETING_MAP.md`. Note which sections are still `<...>` and whether `Changes` has a filled row (then this is a re-brief, not a first fill).
2. Read the sources in `agent_docs/positioning.md → Sources`: README, changelog, docs, open and closed issues, the code's entry points. Note what the product does today, who the issues come from, and any phrases users repeat.
3. Tell the user in two or three lines what you found and which sections you'll go through.

### 1. Product
- Propose **Name**, **What it does** (the colleague test in `positioning.md`), **Links** from what you read.
- Ask: who builds it (solo / team), and anything in the one-liner they'd say differently.
- Write the section after they confirm.

### 2. Audience
- Propose **Primary buyer** as a situation and **The job** from the issues and README.
- Ask what the repo can't show: "What did you, or your first users, use before this?" and "Who should this not be for?"
- Show the four lines, wait for yes, write.

### 3. Positioning
- Propose **Category** (the words a buyer would search), **Against** (one alternative from "What they use today"), **Why switch** and **One-liner**.
- **Why switch** needs proof. Find the code ref, changelog entry or measurement that shows it and add an `Evidence` row (`agent_docs/claims-and-evidence.md → What counts as proof`). If there is none, write the line with `[NEEDS PROOF]` and say what would prove it.
- Run the swap test from `positioning.md → Testing a position` on the one-liner and say whether it passes.
- Show the four lines and any Evidence row, wait for yes, write.

### 4. Voice
- Ask for one or two things the author has written that sound like them (a PR description, a reply in an issue, a post). Propose **Sounds like**, **Never sounds like** and **Person and tense** from those.
- If they say a word is off-limits, add it to `Banned words`.
- Show the lines, wait for yes, write.

### 5. Customer language
- Copy the user phrases you found in step 0 verbatim, each with its source and date. Don't reword them. Skip the section if you found none.

### 6. Close
1. **Changes.** First fill: complete the template's version 1 row (date, `all`, `first fill`, and why: what the sources were). Re-brief: add a new row on top with the next version number, the sections that changed, and what triggered it.
2. Go through `positioning.md → Testing a position` and say which boxes hold and which don't yet, with what would fix each.
3. List every `<...>` and `[NEEDS PROOF]` still in the four sections.
4. Mention that `Channels` (handles, cadence) is a quick edit they can do directly, and that every `publish` stays `off` until they turn it on.
