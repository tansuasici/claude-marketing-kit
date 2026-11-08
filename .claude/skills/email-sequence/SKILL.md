---
name: email-sequence
description: Write one short email sequence for one trigger (a signup, an install, a launch list) from MARKETING_MAP.md and Evidence, with one idea and one next step per email, three subject lines each, a send time, an exit condition and [NEEDS PROOF] on every unbacked claim. Drafts only; never sends or loads anything into an email tool. Use when the user asks for a welcome, onboarding or launch email series.
---

# email-sequence

Write one email sequence in one file. How to write the sentences (material, openings, body, CTA, revision order) is in `agent_docs/copywriting.md`; read it first, along with `agent_docs/claims-and-evidence.md`. This file is the procedure and the shape of the file.

## Input

From `$ARGUMENTS` or the user's request:

- **The trigger:** what puts someone in the sequence (signed up, installed, joined a launch list).
- **The goal:** the one action the sequence leads to (first run, first project, trying the release).
- **How people got on the list.** If the user doesn't say, ask.

The file is `drafts/email/<slug>.md`, starting with frontmatter `channel: email`. If it exists, this run is a revision: follow `copywriting.md → Revising` on what is there instead of starting over.

## Rules

- **Map first.** If `MARKETING_MAP.md → Product, Audience` or `Positioning` is still `<...>`, stop and say to run `/brief`.
- **Only people who asked.** If the list is bought, scraped or built from people who never opted in, stop and say so; this skill doesn't write cold outreach.
- **Material sets the length.** Each email stands on its own Evidence row, artefact or Customer language line. Three emails with material beat five with padding. Five is the most this skill writes in a run; a longer plan is a second sequence.
- **One idea, one next step.** If an email needs "also", the rest is another email. Every email asks for one action, at most, and says what happens after it.
- **Each email stands alone.** People miss emails. No "as I said last time" that leaves the reader lost, and no email that only repeats the one before.
- **Marks at first write.** A claim with no Evidence row gets `[NEEDS PROOF: reason]` in the same write. Quotes come verbatim from `Customer language` or `Evidence` with their source.
- **No fake signals.** No false urgency, no deadline or offer the user didn't state, and no subject that pretends to be something else (`Re:`, `Fwd:`, "your invoice"). The subject says what the email holds.
- **No invented sender or story.** The email comes from the person or address the user names. Don't write a founder story or a personal anecdote the user didn't give you.
- **Slots, not assets.** A screenshot or video goes in as `[SLOT: what it must show]`. Personal fields such as a first name are used only if the user says their tool has them, and each needs a fallback.
- **Unsubscribe and address.** Every marketing email ends with `[SLOT: unsubscribe link and sender's postal address]`. Laws such as CAN-SPAM require them, and most sending tools fill them in. Tell the user to check what applies to their list; this isn't legal advice.
- **Drafts only.** Never send, schedule or load the sequence into an email tool. Email has no row in `MARKETING_MAP.md → Channels`, so the user sends it from their own tool (`CLAUDE.md → Approval Required`).

## File shape

```markdown
---
channel: email
---

# <Sequence name>

- Trigger: <what puts someone in>
- Goal: <the one action>
- Exit: <what takes someone out, usually doing the goal>
- From: <person or address the user named>

## 1. <what this email does>

- Send: <when, relative to the trigger>
- Subject: <chosen line>
- Preview: <what shows after the subject; adds to it, doesn't repeat it>
- Stands on: <Evidence row or artefact>

<!-- other subjects: <line> | <line> -->

<body>

[SLOT: unsubscribe link and sender's postal address]
```

`channel: email` keeps the `channel-limits` hook quiet: it has no email limits, and without this line a slug like `x-launch` would be counted as an X post.

## Steps

1. **Load.** Read `MARKETING_MAP.md` (Product, Audience, Positioning, Voice, Banned words, Evidence, Customer language, Learnings) and the README, docs and changelog behind the goal.
2. **Plan.** List the emails: for each, the job it does, the material it stands on, the next step, and when it goes out. Start from the smallest step toward the goal (`copywriting.md → Call to action`). Send times are your proposal, tied to the trigger; don't claim one is proven to work unless `Learnings` says so. Show the plan to the user in a few lines; if an email has no material, cut it and say so.
3. **Subjects.** For each email, write three subject lines with different patterns from `copywriting.md → The opening line`, then a preview line. Put the specific thing first, since email apps cut long subjects at different lengths. Pick one and say why; keep the other two in an HTML comment.
4. **Bodies.** Inside `copywriting.md → Body` and `Call to action`, in `Voice`. The first line meets the reader at the trigger. Link to the exact page, not the homepage.
5. **Revise.** `copywriting.md → Revising`, steps 1–4 and 6, on each email. Step 5 (limits) doesn't apply: email has no channel row. Count each subject's characters with a command rather than estimating, and report them.
6. **Read the whole run.** Read the emails in order as someone who gets all of them, then read the last one alone. Check that the exit condition holds: nobody who already did the goal is asked to do it again.
7. **Gate.** Run `slop-audit`, then `claim-audit`, on the file and apply only the rewrites the user approves.
8. **Report**, then stop:
   - the file path and each email with its send time and subject;
   - the emails you cut or left out, and why;
   - the counted length of each subject; there is no fixed limit to check against;
   - every `[NEEDS PROOF]` and `[SLOT: …]` still in the file;
   - every competitor comparison, number, guarantee or price, which need the user's approval (`CLAUDE.md → Approval Required`);
   - that nothing has been sent, and that the exit condition and send times have to be set up in the user's own email tool.
