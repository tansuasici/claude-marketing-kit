---
name: launch-plan
description: Write one launch plan for one real release or product, in one file, with a readiness check run against the product, the one idea and its proof, a table of pieces (channel, format, skill, time, status), a go/no-go line, and what to measure. No reach forecasts and no vote-gathering. Plans only; never publishes or schedules. Use when the user is preparing a launch, a release announcement or a launch date.
---

# launch-plan

Write the plan for one launch. The channels and formats are in `agent_docs/channels.md`, what counts as proof in `agent_docs/claims-and-evidence.md`; read both first. This file is the procedure and the shape of the plan.

The plan decides what goes out, where and when. The copy is written afterwards by the skills it names, one piece at a time.

## Input

From `$ARGUMENTS` or the user's request: **what is launching** (a version, a feature, the product) and **the date**. If what is launching is missing, ask. If the date is missing, plan in days relative to launch day (`T-7`, `T`, `T+1`) and leave the date for the user; never pick one yourself.

The file is `drafts/launch/<slug>.md`, starting with frontmatter `channel: none`, so the `channel-limits` hook doesn't count the plan as a post if the slug contains a channel name. If it exists, this run is an update: change what moved and say what changed.

## Rules

- **Map first.** If `MARKETING_MAP.md → Product, Audience` or `Positioning` is still `<...>`, stop and say to run `/brief`. If the launch changes who it's for or why they'd switch, stop and say to run `/positioning` first.
- **Something real to launch.** The plan stands on a release a reader can use on launch day, or on one the user says will be ready by then. If the install doesn't work yet, that is the first line of the plan, not a footnote.
- **Fit the plan to the launch.** A patch release may need one post. Every piece needs its own material and someone to make it; cut anything that doesn't have both.
- **One idea, one proof.** The whole launch stands on one idea with one Evidence row or artefact. A claim with no row gets `[NEEDS PROOF: reason]` in the same write.
- **No forecasts.** Don't predict reach, signups, stars or rank. Don't state a best time to post unless `Learnings` shows it for this account; a proposed time is labelled as your proposal.
- **Targets are the user's.** A goal number in the plan comes from the user, or the field says `no target set`.
- **Places outside the Channels table need their rules read.** Hacker News, Product Hunt, Reddit, a forum, a newsletter: include one only if the user names it or agrees to it. Fetch its current rules in this run and link them. If they can't be fetched, say so; don't recall them from memory.
- **No fake traction.** No asking people for upvotes, no coordinated voting, no quotes or launch-day numbers written in advance. Testimonials and counts need a source, like any claim.
- **Costs need a yes.** Ads, boosts, paid tools, paid music or footage go in only as proposals, with the price the user gave (`CLAUDE.md → Approval Required`).
- **Plans only.** Never publish, schedule or queue. Each post still needs the channel's `publish` flag and the user's yes on that exact post, channel and time (`CLAUDE.md → Publishing`).

## Plan shape

```markdown
---
channel: none
---

# Launch: <what>

- Date: <date> | <T-relative, date not set>
- Reader: <from Audience → Primary buyer>
- Idea: <one sentence>
- Proof: <Evidence row or artefact> | [NEEDS PROOF: reason]
- Next step for the reader: <the smallest true one, with the exact link>
- Target: <the user's number> | no target set

## Readiness

| Check | Result | How you checked |
|---|---|---|
| <check> | pass / fail / not checked | <command, URL, or "user to confirm"> |

## Pieces

| When | Where | Format | Written by | Stands on | Status | Approval |
|---|---|---|---|---|---|---|
| T-7 | <channel or place> | <from channels.md → Formats> | <skill> | <Evidence row or artefact> | not started | <what needs a yes> |

## Go / no-go

Launch only if: <checks that must pass on T-1>
If not: <what happens instead, e.g. move the date, launch without one channel>

## After launch

| When | What to record | From where |
|---|---|---|
| T+1, T+7 | <metric> | <analytics, repo, the channel's own stats> |

Baseline before launch: <number and date> | not measured
```

## Steps

1. **Load.** Read `MARKETING_MAP.md` (all of it) and the changelog, README and docs behind what is launching.
2. **Readiness.** Check what you can, and say how for each row. Mark what you couldn't check `not checked`, never `pass`:
   - follow the README's install or quick start as a new user would, if it's safe to run here; otherwise it's for the user to confirm;
   - fetch every link the launch will point to (repo, install section, changelog entry, landing page);
   - check that the changelog or release notes cover what is launching;
   - check that the idea's claim has an Evidence row, and name any that doesn't;
   - check that `Voice` and `Channels` are filled for the channels you plan to use;
   - check the limit rows in `channels.md` for those channels; recheck any older than ~90 days, as that file asks.
3. **Idea.** Write the one idea, the proof and the reader's next step. Compare it with `Positioning → Why switch`, and say if the two don't line up. Check `Learnings` for past launches and channels.
4. **Pieces.** List only what this launch needs, from `MARKETING_MAP.md → Channels` and any place the user agreed to. For each one, name the skill that writes it: `landing-copy`, `social-post`, `repurpose`, `email-sequence`, or another that exists in `.claude/skills/`. If no skill covers a piece, write `by hand`. Pieces that repeat one idea on several channels are one `social-post` and then `repurpose`. Say what the reader sees first and why that order.
5. **Go / no-go and measurement.** Write what must be true on T-1, and what happens if it isn't. Name what you'll record, when and from where, and take the baseline now if you can. Results go to `MARKETING_MAP.md → Learnings` with the number.
6. **Gate.** Run `claim-audit` on the plan if it states any product claim, and apply only the changes the user approves.
7. **Report**, then stop:
   - the file path and the date, or that it isn't set;
   - each readiness row that failed or wasn't checked;
   - the pieces in order, and any you cut and why;
   - the rules you fetched for each outside place, with links, and any you couldn't fetch;
   - every `[NEEDS PROOF]`, and every comparison, number, guarantee, price or cost that needs the user's approval (`CLAUDE.md → Approval Required`);
   - that nothing has been written for the channels, published or scheduled, and which piece you'd write first.
