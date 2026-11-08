---
name: social-post
description: Write one post for one channel (X, LinkedIn, Instagram, Facebook, YouTube, TikTok) about one idea, from MARKETING_MAP.md and an Evidence row, with three openings, a format picked on purpose, counted lengths and [NEEDS PROOF] on every unbacked claim. Drafts only; never publishes. Use when the user asks for a post, thread, caption or announcement.
---

# social-post

Write one post for one channel. The platform limits and formats are in `agent_docs/channels.md`, the sentence rules in `agent_docs/copywriting.md`; read both first. This file is the procedure.

## Input

From `$ARGUMENTS` or the user's request: **the channel** and **the idea** (a release, a fix, a decision, a user's problem). If the channel is missing, ask. If the idea is missing, offer two or three from the latest changelog entries and Evidence rows and let the user pick. One channel and one idea per run; for the same idea on another channel, use `repurpose` afterwards.

The file is `drafts/<channel>/<slug>.md`, starting with frontmatter `channel: <channel>` (`agent_docs/channels.md → Draft files`), so the `channel-limits` hook counts it on every write.

## Rules

- **Map first.** If `MARKETING_MAP.md → Product, Audience` or `Positioning` is still `<...>`, stop and say to run `/brief`.
- **One idea.** If the draft needs "also", the rest is a second post. Say so and stop at one.
- **Proof or nothing.** The post stands on one Evidence row or one artefact (a command, a diff, a screenshot). If there is neither, say there is nothing to post yet instead of writing around it.
- **Marks at first write.** A claim with no Evidence row gets `[NEEDS PROOF: reason]` in the same write. Quotes come verbatim from `Customer language` or `Evidence` with their source.
- **Slots, not assets.** An image, video, carousel slide or screenshot goes in as `[SLOT: what it must show, aspect ratio]`. Instagram, TikTok and Shorts posts always have one; no visual plan, no post for those channels.
- **Write to the lower number.** Where `channels.md` marks a limit `conflict`, write to the lower one and say so; where it is `unverified` (Facebook), give no limit and ask the user to check the composer. X is 280 unless the user confirmed a paid tier.
- **Drafts only.** Never publish, schedule or queue. That needs `publish: on` and the user's approval of this exact post (`CLAUDE.md → Publishing`).

## Steps

1. **Load.** Read `MARKETING_MAP.md` (Product, Audience, Positioning, Voice, Banned words, Evidence, Customer language, the channel's row in Channels, Learnings) and the changelog entry or source behind the idea.
2. **Material.** Name the Evidence row or artefact the post stands on, the reader's moment (`Audience → Primary buyer`), and any Customer language line that says it better. Check `Learnings` for what worked or didn't on this channel before.
3. **Format.** Pick one from `channels.md → Formats` and say why (a thread only when each step needs its own line; a carousel for a before/after or 3–7 steps).
4. **Opening.** Write three openings with different patterns from `copywriting.md → The opening line`, each fitting the channel's visible part (X 280, LinkedIn ~140, Instagram ~125, YouTube title ~50). Pick one and say why; keep the other two in an HTML comment.
5. **Body and CTA.** Inside `copywriting.md → Body` and `Call to action`. Hashtags only within the channel's guidance in `channels.md` (X 0–2), and only tags people search. For a thread or carousel, separate the parts with a `---` line; the first part must stand alone.
6. **Revise.** `copywriting.md → Revising`, all six steps. For step 5, use the `channel-limits` hook's counts from the last write; if it didn't report (no python3, or the file isn't a draft path), run `python3 .claude/hooks/lib/channel_limits.py <file> <file>` and use that. Never estimate when a count is available.
7. **Gate.** Run `slop-audit`, then `claim-audit`, on the file and apply only the rewrites the user approves.
8. **Report**, then stop:
   - the file path, channel and format;
   - the opening you picked and why;
   - the counted length per part against the limit, and which limit you wrote to if it was a `conflict`;
   - every `[NEEDS PROOF]` and `[SLOT: …]` still in the draft;
   - every competitor comparison, number, guarantee or price, which need the user's approval (`CLAUDE.md → Approval Required`);
   - that the draft is not published, and what publishing it would need (`social-publish`, the channel's `publish` flag and the user's yes on this post).
