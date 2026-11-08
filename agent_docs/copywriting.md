# Copywriting

How to write the sentences once the position is set. Used by `landing-copy`, `social-post`, `email-sequence` and `repurpose`. Assumes `MARKETING_MAP.md` is filled; if Positioning is empty, stop and run `brief` first.

---

## Start from material, not from a blank page

Before the first draft, collect what the copy will be made of. Each item becomes a sentence or gets cut.

- **The proof.** Evidence rows that matter to this reader. Pick one per post, two or three per landing section.
- **The artefact.** A command, a screenshot, a diff, a config snippet, a before/after. Something a reader can look at.
- **The reader's words.** Lines from `MARKETING_MAP.md → Customer language`. If a user described the problem better than you can, use their phrasing (quoted, sourced) or let it shape the headline.
- **The moment.** What the reader was doing when they went looking (`Audience → Primary buyer`). The opening line meets them there.

If the list has no proof and no artefact, there is nothing to write yet. Say so instead of filling the gap with adjectives.

---

## The opening line

The visible part of the post (see `channels.md`) decides whether the rest is read. Write three openings, pick one, and say why.

Patterns that work for developer products, each tied to something real:

| Pattern | Shape | Example |
|---|---|---|
| The result | what happened, with the number from Evidence | "Our CI went from 14 min to 6 after we cached the Docker layers." |
| The command | the thing you type, and what it does | "`npx cmk init` adds a ruleset, a positioning file and four hooks to your repo." |
| The failure | the problem in the reader's own terms | "Cron jobs fail silently. You find out from a customer." |
| The change | what's new since the last version | "v2.1 resumes an interrupted upload instead of starting over." |
| The decision | a choice you made and the trade-off | "We dropped the web UI. Everything is a file in your repo now." |

Avoid as openings: a question to the reader, a greeting ("Hey devs 👋"), an announcement of an announcement ("Big news!"), anything from `slop-signs.md`.

---

## Body

- **One idea.** If you wrote "also", the rest is a second post.
- **Specific nouns.** "Postgres 16", "a 40 MB binary", "the `--dry-run` flag", not "your database", "lightweight", "flexible options".
- **Verbs that can be checked.** "Retries three times", "writes to `./out`". Not "handles", "manages", "empowers".
- **Show the cost.** Developers trust a product that states its limits: "macOS and Linux only", "needs Node 18". Put one rough edge in on purpose.
- **Short paragraphs, varied sentences.** One to three sentences per paragraph. Mix a long one with a short one.
- **Numbers as digits.** "3 hooks", "40 s". Round down, never up.

---

## Call to action

One next step, the smallest one that's true:

- A command they can run now beats "Sign up".
- A link to the exact page (the install section, the changelog entry), not the homepage.
- Say what happens after: "Opens a PR with the files; nothing is pushed."

No urgency that isn't real ("Limited spots!") and no price, trial or discount the user didn't state.

---

## Revising

Edit in this order, and stop when the draft passes:

1. **Cut the last sentence.** If nothing is lost, keep it cut. Repeat.
2. **Cut adjectives.** Each one either becomes a fact (with an Evidence row) or goes.
3. **Competitor test** (`slop-signs.md`). Rewrite any sentence that passes for a competitor.
4. **Claim check** (`claims-and-evidence.md`). Every claim backed or marked `[NEEDS PROOF]`.
5. **Limits** (`channels.md`). Count, don't guess, and report the count.
6. **Read it as the buyer.** Would they stop? Is the next step obvious?

---

## Variants

When asked for options, make them differ in **angle** (which proof, which opening pattern), not in wording. Three rewordings of the same sentence are one option. Label each variant with its angle and its Evidence row.
