---
name: landing-copy
description: Write or revise the copy for one landing page from MARKETING_MAP.md (Positioning, Evidence, Customer language), section by section, with three hero options, labelled slots for assets and [NEEDS PROOF] on every unbacked claim. Use when the user asks for a landing page, homepage or product page.
---

# landing-copy

Write the words for one landing page. How to write the sentences (material, openings, body, CTA, revision order) is in `agent_docs/copywriting.md`; read it first, along with `agent_docs/claims-and-evidence.md`. This file is the procedure and the page structure.

## Input

The output file is `$ARGUMENTS`, or `drafts/landing.md` if none is named. If the file already exists, this run is a revision: skip to step 4 and follow `copywriting.md → Revising` on what is there instead of starting over.

## Rules

- **Map first.** If `MARKETING_MAP.md → Product, Audience` or `Positioning` is still `<...>`, stop and say to run `/brief` first. A page with no position is a list of adjectives.
- **Nothing without material.** Every section is built from an Evidence row, an artefact or the reader's words. A section with none of them is cut, not padded.
- **Marks at first write.** Every claim with no Evidence row gets `[NEEDS PROOF: reason]` in the same write that adds it (spelling from `claims-and-evidence.md`), not later. Quotes are copied verbatim from `Customer language` or `Evidence` with their source; a quote that isn't there is never written.
- **Slots, not assets.** Where a screenshot, demo, logo row or testimonial would go, write `[SLOT: what goes here, and what it must show]`. Never hotlink or describe an image that doesn't exist.
- **No offers you weren't given.** No price, trial, discount, guarantee or deadline the user didn't state.
- **Copy only.** Markdown text in one file. No HTML, layout, styling or a change to the site's code.

## Page structure

Use the sections in this order. Leave out any that has no material, and say which ones you left out.

| Section | What it holds | Built from |
|---|---|---|
| Hero | headline, one-line subhead, the CTA | `Positioning → One-liner, Why switch` and its Evidence row |
| The problem | the reader's situation, in their words | `Audience → Primary buyer, The job`, `Customer language` |
| How it works | 2–4 steps, each a real action (a command, a file, a screen) | README, docs, the code |
| Proof | 2–3 Evidence rows that matter to this reader | `Evidence` |
| Limits | who it's not for and what it doesn't do yet | `Audience → Not for`, stated limits in the README or changelog |
| CTA | the smallest true next step, and what happens after | `copywriting.md → Call to action` |

## Steps

1. **Load.** Read `MARKETING_MAP.md` (all of it) and the product's README, docs and changelog.
2. **Material.** List, per section, the Evidence rows, artefacts and Customer language lines you'll use. Show the list to the user in a few lines. If the hero has no proof (Why switch carries `[NEEDS PROOF]`), say so: the hero carries the mark too.
3. **Hero.** Write three headlines, each with a different pattern from `copywriting.md → The opening line`, each with the Evidence row it stands on. Pick one and say why; keep the other two in an HTML comment under the hero.
4. **Sections.** Write the rest of the page in the order above, under `##` headings, inside `copywriting.md → Body`. One idea per section. Put the one rough edge in the Limits section.
5. **Revise.** Go through `copywriting.md → Revising`, steps 1–4 and 6. Step 5 (limits) doesn't apply: a landing page has no channel row.
6. **Gate.** Run `slop-audit` and then `claim-audit` on the file, and apply only the rewrites the user approves.
7. **Report**, then stop:
   - the file path and the sections written or left out;
   - the hero you picked and why;
   - every `[NEEDS PROOF]` and `[SLOT: …]` still in the page;
   - every competitor comparison, number, guarantee or price, which need the user's approval before the page ships (`CLAUDE.md → Approval Required`);
   - that Verification step 3 (limits) doesn't apply here; the competitor test ran in `slop-audit` and the buyer read in step 5.
