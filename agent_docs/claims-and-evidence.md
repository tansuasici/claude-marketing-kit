# Claims and Evidence

How a sentence in a draft earns its place: what counts as a claim, what counts as proof, and how a gap is marked. Used by `claim-audit`, the `claim-scan` hook and the `claim-checker` agent. This file expands the Cardinal Rule in `CLAUDE.md`.

---

## What is a claim

A claim is any sentence a reader could check and find false. If it can be wrong, it needs a source.

| Kind | Example | Needs an Evidence row? |
|---|---|---|
| Capability | "Exports to CSV." | Yes: code ref or docs |
| Number | "Installs in 40 seconds." "1,200 stars." | Yes: measurement or link, with date |
| Comparison | "Faster than Zapier." "The only CLI that…" | Yes, and user approval (see `CLAUDE.md → Approval Required`) |
| Social proof | A quote, a logo, "used by teams at…" | Yes: verbatim source with permission |
| Outcome | "Cuts review time in half." | Yes: a measurement on real use, not a guess |
| Price / guarantee | "Free forever." "Refund in 30 days." | Yes, and user approval |
| Opinion in the author's voice | "I built this because cron kept failing silently." | No, if it is the author's real experience. Ask if unsure. |
| Instruction | "Run `npx cmk init`." | No, but the command must work as written |

"The only", "first", "fastest", "most", "#1" are claims about every competitor at once. They almost never survive checking; rewrite them as a specific, provable difference.

---

## What counts as proof

Strongest first. Use the strongest one available, and name it in the Source column.

1. **Code or config in the repo.** A file path and, where useful, a line or function: `bin/cli.js → init()`. Proves capability only.
2. **Changelog or release notes.** Proves a feature shipped and when.
3. **A measurement you can rerun.** Command, machine, date, result: `time npx cmk init` on M2, 2026-11-07, 38 s. Proves numbers at that point in time.
4. **A public metric with a link.** GitHub stars, npm weekly downloads. Record the value and the date; it goes stale.
5. **A customer's own words.** Verbatim, with where it was said (issue #, review URL, call date) and whether they agreed to be quoted publicly.

Not proof: a plan, a roadmap item, "it should be", a competitor's marketing page about itself, a number Claude estimated, a quote reworded to sound better.

---

## The Evidence row

`MARKETING_MAP.md → Evidence` has three columns. Fill them like this:

```
| Claim | Source | Checked |
|---|---|---|
| Installs with one command | README Quick Start; `bin/claude-marketing-kit.js` | 2026-11-07 |
| 38 s cold install on M2 | `time npx cmk init`, clean dir | 2026-11-07 |
```

- **Claim** is the fact, stated plainly, not the marketing sentence that uses it. One row can back many sentences.
- **Source** is specific enough that someone else can find it in under a minute.
- **Checked** is the date someone last confirmed it. Numbers older than ~90 days get rechecked before use.

A draft may say *less* than the row (round down, drop the number). It may never say more.

---

## Marking a gap: `[NEEDS PROOF]`

When a sentence needs a claim and there is no row, write the sentence anyway and mark it inline, exactly:

```
Setup takes under a minute. [NEEDS PROOF: no install timing measured]
```

- Spelling is fixed: square brackets, upper case, `NEEDS PROOF`, optional `: reason`. Hooks and agents grep for this literal string.
- The mark stays in the draft until a row is added or the sentence is cut. Never delete the mark to make a draft look finished.
- A draft with any `[NEEDS PROOF]` is not done (see `CLAUDE.md → Verification`), and never publishes.
- In the summary to the user, list every mark and what would clear it: "run X", "ask a user", "link the issue".

---

## Never invent

These are the failure modes the kit exists to stop. Do not produce any of them, even as placeholders that look real:

- A metric, percentage, user or customer count, star count, download count.
- A testimonial, a reviewer name, a job title, a company that "uses" the product.
- A customer logo, an award, a press mention, "as seen in".
- A benchmark or comparison result nobody ran.
- An integration, platform or feature that is not in the repo or changelog.
- A price, discount, trial length or guarantee the user did not state.

If a layout needs one (a testimonial block, a logo row), leave a labelled slot: `[SLOT: customer quote, needs a real one]`.

---

## Checking a draft

The order `claim-audit` and `claim-checker` follow:

1. Split the draft into sentences. Mark each one as a claim or not (table above).
2. For every claim, find its Evidence row. Match on meaning, not wording.
3. Check the draft does not overstate the row: bigger number, wider scope, stronger verb ("eliminates" vs "reduces").
4. Check the row is not stale (Checked date).
5. Every claim without a row gets `[NEEDS PROOF]`. Every comparison, number, guarantee or price gets flagged for user approval.
6. Report: claims backed, claims marked, claims overstated, with the sentence and the row for each.
