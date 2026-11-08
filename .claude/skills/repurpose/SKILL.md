---
name: repurpose
description: Rewrite one idea from an existing draft, changelog entry, README section or page for other channels, one draft per channel, with the opening and format picked again, the same claims and Evidence rows, [NEEDS PROOF] marks carried over, no new claims and counted lengths. Rewrites, never truncates. Drafts only; never publishes. Use when the user wants the same thing on another channel.
---

# repurpose

Rewrite one idea for another channel. The method is in `agent_docs/channels.md → Rewriting across channels`, the platform limits and formats in the same file, the sentence rules in `agent_docs/copywriting.md`; read both first. This file is the procedure.

`social-post` starts from an idea. This skill starts from something already written and keeps its facts.

## Input

From `$ARGUMENTS` or the user's request: **the source** (a file, a changelog entry, a README section, pasted text) and **the target channels**. If the source is missing, ask. If the targets are missing, offer the channels in `MARKETING_MAP.md → Channels` other than the source's own and let the user pick.

Each target gets its own file, `drafts/<channel>/<slug>.md`, with frontmatter `channel: <channel>` (`agent_docs/channels.md → Draft files`) and `<!-- source: <where it came from> -->` under it. Use the source's slug if it has one. If that file already exists, ask whether to revise it or pick a new slug; never overwrite it.

## Rules

- **Map first.** If `MARKETING_MAP.md → Product, Audience` or `Positioning` is still `<...>`, stop and say to run `/brief`.
- **Rewrite, never truncate.** Each draft is written fresh for its channel. If its sentences are the source's sentences in the source's order with some removed, it is a cut-down copy: write it again.
- **Same facts, new framing.** Every claim in a draft comes from the source and keeps its Evidence row. A fact that isn't in the source goes through `Evidence` like any new claim: it needs a row, or `[NEEDS PROOF: reason]` in the same write.
- **Marks travel.** A `[NEEDS PROOF]` in the source stays on that claim in every draft. A claim the source states with no Evidence row and no mark gets `[NEEDS PROOF: reason]` here, and the report names it, since the source has the same problem.
- **Quotes keep their words.** A quote is copied verbatim with its source, or left out. Never shorten one to fit.
- **One idea per draft.** If the source holds several (a long post, a full changelog), ask which one; the rest are separate runs.
- **Say when a channel doesn't fit.** Instagram, TikTok and Shorts need something visible. If the idea has nothing to show, skip that channel and say why instead of forcing a draft.
- **Slots, not assets.** An image, video, carousel slide or screenshot goes in as `[SLOT: what it must show, aspect ratio]`, on the new channel's ratio. A slot from the source is rewritten for it, not copied.
- **Write to the lower number.** Where `channels.md` marks a limit `conflict`, write to the lower one and say so; where it is `unverified` (Facebook), give no limit and ask the user to check the composer. X is 280 unless the user confirmed a paid tier.
- **The source stays as it is.** This skill writes only the new drafts.
- **Drafts only.** Never publish, schedule or queue. Approval of the source is not approval of its rewrites (`CLAUDE.md → Publishing`).

## Steps

1. **Load.** Read the source and `MARKETING_MAP.md` (Product, Audience, Positioning, Voice, Banned words, Evidence, Customer language, each target's row in Channels, Learnings).
2. **List what carries over.** Write down the one idea, each claim with its Evidence row or mark, any quote with its source, and the artefact behind the idea. Check `Learnings` for what worked or didn't on each target. This list is the limit of what the drafts may say.
3. **For each target, in its own file:**
   1. **Format.** Pick again from `channels.md → Formats` and say why. The source's format is not a default: a thread may become a carousel or one post.
   2. **Opening.** Write three openings with different patterns from `copywriting.md → The opening line`, each fitting the target's visible part (X 280, LinkedIn ~140, Instagram ~125, YouTube title ~50). Don't reuse the source's opening unless it is the best fit, and say so if it is. Pick one and say why; keep the other two in an HTML comment.
   3. **Body and CTA.** Inside `copywriting.md → Body` and `Call to action`, from the list in step 2. Hashtags only within the channel's guidance in `channels.md`. For a thread or carousel, separate the parts with a `---` line; the first part must stand alone.
   4. **Revise.** `copywriting.md → Revising`, all six steps. For step 5, use the `channel-limits` hook's counts from the last write; if it didn't report (no python3, or the file isn't a draft path), run `python3 .claude/hooks/lib/channel_limits.py <file> <file>` and use that. Never estimate when a count is available.
4. **Compare.** Check each draft against the list in step 2: no claim added, no mark dropped, no quote reworded. Check the drafts against each other too: two that open or run the same way aren't rewritten yet.
5. **Gate.** Run `slop-audit`, then `claim-audit`, on each file and apply only the rewrites the user approves.
6. **Report**, then stop:
   - each file with its channel and format, and channels you skipped and why;
   - the opening you picked for each and why;
   - the counted length per part against the limit, and which limit you wrote to if it was a `conflict`;
   - every `[NEEDS PROOF]` and `[SLOT: …]` still in the drafts, and any unbacked claim you found in the source;
   - every competitor comparison, number, guarantee or price, which need the user's approval (`CLAUDE.md → Approval Required`);
   - that nothing is published, and what publishing each draft would need (`social-publish`, the channel's `publish` flag and the user's yes on that post).
