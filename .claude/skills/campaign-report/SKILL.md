---
name: campaign-report
description: Write one results report for one launch or campaign, with what went out against the plan, every number with its source, read date and time window, the change from baseline and target, what the data can't show and what changes next time, then add the lines the user approves to MARKETING_MAP.md → Learnings. Never invents a number, claims a cause it can't show or forecasts. Use after a launch, a post series or a campaign.
---

# campaign-report

Write down what happened in one campaign, with the numbers. `agent_docs/claims-and-evidence.md → What counts as proof` is the standard for a number; read it first. This file is the procedure and the shape of the file.

The report is internal. It closes the loop in `CLAUDE.md → The Loop`, and what it teaches goes to `Learnings`, where the next `launch-plan`, `social-post` and `positioning` read it.

## Input

From `$ARGUMENTS` or the user's request: **which campaign** (a plan in `drafts/launch/`, a set of posts, a date range) and **the numbers**. If the campaign is missing, ask. Numbers can come from pasted figures, an export, a screenshot the user shares, or the commands in step 2.

The file is `research/campaigns/<slug>.md`, using the plan's slug if there is one. If it exists, this run adds a new read (`T+1`, then `T+7`): keep the earlier numbers next to the new ones, and say what changed.

This skill can run before `/brief`: reporting numbers doesn't need a filled map. If `MARKETING_MAP.md → Audience` or `Positioning` is still `<...>`, skip the doubt line in step 7 and say to run `/brief`.

## Rules

- **Only numbers someone can trace.** Each one has its source, the date you read it and the window it covers. A number you can't get is `not measured`, never an estimate. If a campaign has no numbers yet, the report says so and lists how to get them.
- **Keep the baseline honest.** A baseline comes from the plan or from data that reaches back before the campaign. If nobody took one, write `not measured` and don't call the result a rise or a fall. Some data expires: GitHub's traffic API covers only the last 14 days, so read it soon after launch.
- **Compare like with like.** The same metric, source and window length, and the same weekdays where you can. Say so when windows differ, and don't compare across channels by raw numbers: an X impression and a YouTube view don't count the same thing.
- **Show the arithmetic.** Compute a rate or a change with a command or show the sum. With small numbers, give the counts ("3 of 12") rather than a percentage alone.
- **Against the goal, not just activity.** Lead with the action the plan asked for (installs, signups, first runs). Likes and impressions are context, and don't stand in for it. Without a target, write `no target set` and don't call the result good or bad.
- **Correlation stays correlation.** Name a cause only when the data shows the path: a tracked link, a referrer, someone saying where they came from. Otherwise write "rose after the post", and list what else happened in the window (a release, another mention, a holiday). One post is an anecdote; say how sure a Learning can be.
- **Report the misses.** Pieces that didn't ship, targets missed and results that went nowhere go in with the same weight. They are usually the most useful Learnings.
- **No forecasts.** Don't project the trend forward or predict what the next campaign would get.
- **Read only.** Never publish, boost, change a campaign, or write through a connector from this skill. A read-only stats call is fine; spending or changing anything needs the user (`CLAUDE.md → Approval Required`).
- **Private numbers stay private.** Revenue, signups, ad spend and analytics exports may be sensitive, and `research/` may be committed. Check whether the repo is public, and ask before writing them to the file. Replace names and emails from exports with counts.
- **A result isn't a claim yet.** A number from this report goes in public copy only through an Evidence row with its date, and with the user's approval (`CLAUDE.md → Approval Required`).
- **The map is the user's.** Add to `Learnings` only the lines the user approves. Don't change `Positioning`, `Audience` or `Voice`; report what the results put in doubt.

## File shape

```markdown
# Results: <campaign>

- Plan: <path> | none
- Window: <first date> to <last date>
- Goal: <the plan's action> | not stated
- Target: <the user's number> | no target set

## What went out

| Piece | Where | Planned | Actual | Link |
|---|---|---|---|---|
| <piece> | <channel> | <date> | <date, or "not shipped: why"> | <URL> |

## Numbers

| Metric | Baseline | Result | Change | Window | Source | Read on |
|---|---|---|---|---|---|---|
| <goal metric first> | <number and date, or "not measured"> | <number> | <arithmetic, or "not comparable"> | <dates> | <tool, command, or "user, pasted"> | <date> |

## What the data shows

- <one finding, with the row behind it>

## What it can't show

- <unmeasured metric, or other events in the window that could explain the change>

## Next time

- <one change, tied to a finding>
```

## Steps

1. **Load.** Read the plan or the drafts, `MARKETING_MAP.md → Audience, Positioning, Channels, Learnings`, and the report if it exists. Name the goal metric. If the plan has none, ask the user which action mattered, and write `not stated` if they don't name one.
2. **Get the numbers.** Use what the user gives you, then read what you can. These cover a public repo and package; run only the ones that apply:
   - stars and forks: `gh api repos/<owner>/<repo> --jq '{stars:.stargazers_count,forks:.forks_count}'`
   - views, clones and referrers, last 14 days, with push access: `gh api repos/<owner>/<repo>/traffic/views`, `/traffic/clones`, `/traffic/popular/referrers`
   - npm downloads: `curl -s https://api.npmjs.org/downloads/range/<YYYY-MM-DD>:<YYYY-MM-DD>/<package>`, by day
   - issues opened in the window: `gh issue list --search "created:<YYYY-MM-DD>..<YYYY-MM-DD>"`
   For channel stats, Search Console and web analytics, ask the user for the figures unless a connector they set up can read them. Stars are public counters that go stale, and download counts include CI and mirrors; say so where they matter.
3. **Check what shipped.** Compare the plan with what went out, and link each post. Mark what didn't ship and why, if the user knows.
4. **Compare.** Fill the table, with the goal metric first. Show the change only where both sides are measured and comparable. Set it against the target.
5. **Read it.** Write what the data shows and what it can't, under the rules above. Check `Learnings` for an earlier result this repeats or contradicts. Look through issues and replies in the window for what people said, and suggest `voice-of-customer` if there's material; don't quote here.
6. **Propose Learnings.** One line per lesson, at most three, each in the map's form with its number: `<date>: <what was tried> → <result> → <what changes next time>`. Label a lesson from one campaign as one data point. Show the exact lines and wait for the user's yes, then write the approved ones under `Learnings`, replacing the template line if it's still there.
7. **Report**, then stop:
   - the file path, the window and the goal metric against its target;
   - the main numbers, with what's `not measured` and how to measure it next time;
   - what shipped late or not at all;
   - what can't be concluded, including causes the data doesn't show;
   - the lines added to `Learnings`, and any number worth an Evidence row, which needs the user's approval before public use;
   - what the results put in doubt in `Audience` or `Positioning`, and that `positioning` is the next step if they do; nothing in those sections was changed;
   - the next read's date, if one is due, and that nothing was published or changed.
