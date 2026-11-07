# Slop Signs

The patterns that make marketing copy read as machine-written or interchangeable. Used by `slop-audit`, the `slop-scan` hook and the `brand-voice-reviewer` agent.

This file is the **baseline** list, shipped with the kit. `MARKETING_MAP.md → Banned words` is the **per-project** extension: words this product's voice rules out on top of the baseline. A hook reads both.

The lists below sit in fenced blocks, one entry per line, so a hook can read them without parsing prose. Lines starting with `#` are comments. Keep that shape when you edit.

---

## Hype words (hard)

Words that describe any product, so they describe none. Flag every occurrence.

```slop-hard
revolutionary
revolutionize
game-changing
game-changer
groundbreaking
cutting-edge
next-generation
next-gen
state-of-the-art
world-class
best-in-class
seamless
seamlessly
effortless
effortlessly
supercharge
turbocharge
unlock
unleash
unparalleled
unprecedented
transformative
disruptive
innovative
magic
magical
delve
tapestry
elevate
empower
10x
```

## Soft words (verify in context)

Often fine in a sentence with a specific object ("robust to network drops" can be true). Flag only when several appear together or the word has no concrete object.

```slop-soft
powerful
robust
leverage
streamline
optimize
comprehensive
intuitive
simple
easy
blazing
fast
lightning
modern
smart
ultimate
journey
landscape
ecosystem
solution
```

## Filler phrases

Regular expressions, case-insensitive. Each one is a sentence that says nothing.

```slop-filler
in today'?s (fast-paced|digital|modern) (world|landscape|age)
whether you'?re an? .{1,40} or an? .{1,40}
take your .{1,30} to the next level
look no further
say goodbye to
say hello to
the future of .{1,30} is here
we'?re (thrilled|excited|delighted) to (announce|share|introduce)
(it'?s|is) never been easier
all-in-one (platform|solution|tool)
designed with you in mind
built for (the )?modern
(join|trusted by) (thousands|millions)
at the end of the day
it'?s worth noting that
```

---

## Structural tells

A hook can count some of these; a reviewer judges the rest.

- **Rhetorical-question opener.** "Tired of flaky deploys?" The reader wasn't asked. Open with the specific thing instead.
- **Rule of three, every time.** "Fast, simple, and powerful." One concrete point beats three adjectives.
- **"It's not X, it's Y."** A contrast with a claim nobody made.
- **Emoji bullets and rocket ships.** 🚀✨🔥 at the start of lines. One emoji where the channel expects it is fine; a column of them is a template.
- **Hashtag walls.** More hashtags than the channel row allows, or tags nobody searches.
- **Em-dash density.** Several em-dashes per paragraph. Use a period or a colon.
- **Closing hype line.** "The future is here." "Try it today and see the difference." Cut the last sentence and check whether anything was lost.
- **Equal-length sentences.** Five sentences in a row of the same length. Vary it.
- **Unattributed superlative.** "The best way to…" with no comparison behind it. That is a claim (see `claims-and-evidence.md`).

---

## The competitor test

The one check no list can do. Replace the product name with a competitor's. If the sentence still reads true, it is slop for this product, even with no banned word in it.

> "A faster, simpler way to ship your app." Fits every deploy tool. Fails.
> "Rolls back the last deploy when the health check fails twice in 60 s." Fits one. Passes.

---

## Allowing a word

A banned word can be the literal truth: a product called "Magic Link", a feature named "Unlock". Two ways through:

- Add the term to `MARKETING_MAP.md → Voice` as an allowed exception, with why.
- Quote it: a customer's verbatim words keep their wording (see `claims-and-evidence.md`), and the source is shown.

Never silently rewrite a customer quote to remove a banned word.
