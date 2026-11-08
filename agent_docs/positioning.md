# Positioning

How to fill `MARKETING_MAP.md → Product, Audience, Positioning` so the rest of the kit has something true to stand on. Used by the `brief`, `positioning` and `competitor-brief` skills.

Changing **Positioning**, **Audience** or **Voice** needs the user's approval (`CLAUDE.md → Approval Required`). Propose; don't overwrite.

---

## Sources, in order

1. **The repo.** README, changelog, docs, issues, the code itself. What the product actually does today.
2. **Users.** Issues, discussions, reviews, support threads, call notes. How they describe the problem and the product. Copy their words into `Customer language` with the source.
3. **The author.** Ask why they built it and what they used before. Their story is usually the sharpest position, and the voice is theirs.
4. **Alternatives.** The README or docs of what the reader uses today. Only facts you can link; never a competitor's weakness you inferred.

Do not position from category clichés ("the developer-first platform for…"). If the sources don't support a line yet, leave the `<...>` and say what would fill it.

---

## Filling each field

### Product
- **What it does, in one sentence a user would say.** Test it: could a user say this to a colleague without sounding like an ad? "It checks my marketing drafts against a list of facts I wrote down" passes. "An AI-powered marketing co-pilot" fails.

### Audience
- **Primary buyer.** A situation, not a demographic. "A solo dev who just shipped v1 and has to write the launch post tonight" is usable. "Developers" is not.
- **The job they hire it for.** The outcome in their terms.
- **What they use today instead.** Usually not a competitor: a script, a spreadsheet, a friend, "nothing, I just don't post". This is the real alternative.
- **Not for.** Who to stop trying to win. A position that fits everyone is not a position.

### Positioning
- **Category.** The shelf the buyer would look on. Use the words they'd search, even if a new category name is tempting.
- **Against.** One named alternative from "What they use today". Naming it is internal; using the name in public copy needs approval.
- **Why switch.** One concrete difference. It must have an Evidence row, or it is `[NEEDS PROOF]`. A difference you can't show is a hope.
- **One-liner.** Category + who + why switch, in a sentence. Run the competitor test on it (`slop-signs.md`).

---

## Testing a position

A position is ready when all of these hold:

- [ ] **Specific reader.** You could find ten of them this week (a subreddit, a GitHub topic, an issue tracker).
- [ ] **Real alternative.** "Against" is what they actually do today, not the competitor you'd like to be compared with.
- [ ] **Provable difference.** "Why switch" points at an Evidence row.
- [ ] **Survives the swap.** Put the alternative's name in the one-liner. If it still reads true, the difference isn't one.
- [ ] **Has a "not for".** Someone is explicitly left out.

---

## Competitor briefs

`competitor-brief` writes one page per alternative to `research/competitors/<slug>.md`. The copy hooks skip `research/`, since a brief quotes the alternative's own marketing on purpose; it is internal and never ships as copy. Keep it to what you can link:

| Field | Content |
|---|---|
| What it is | Their own one-line description, quoted, with URL |
| Who uses it | From their docs or public users, linked |
| What it does that we don't | Be honest; the reader will know |
| What we do that it doesn't | Each line has an Evidence row on our side |
| When to recommend them instead | The "not for" from their angle |
| Checked | Date. Competitor pages change. |

Never state a competitor's price, limit or flaw without a link, and never in public copy without approval.

---

## When the position changes

A new feature, a pivot, or a pattern in user feedback can move the position. When it does:

1. Propose the new line next to the old one, with the evidence for the change.
2. After the user approves, update the map and add a row to `Changes` with the next version number and what triggered it.
3. Flag drafts and pages that still carry the old position.
