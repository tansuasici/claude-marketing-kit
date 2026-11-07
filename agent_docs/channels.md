# Channels

Platform facts for the six v0.1 channels: limits, formats, what the first line does, counting quirks. Used by the `channel-limits` hook and the `social-post`, `repurpose` and `video-script` skills.

**Split of responsibility.** This file holds facts about the *platform*, the same for every user. `MARKETING_MAP.md → Channels` holds facts about *this project*: the account, the cadence, the `publish` flag. When the two disagree on a limit, this file wins; fix the map row.

---

## These numbers are claims too

Platforms change limits without notice, and most published numbers come from third-party tools, not the platform. Each limit below carries its source type and the date it was last checked. Apply the same rule as `claims-and-evidence.md`:

- **official**: the platform's own API reference or help center.
- **third-party**: scheduler and counter-tool docs; agree with each other but unconfirmed by the platform.
- **observed**: UI behaviour (where "see more" cuts in); varies by device and can change any week.
- **conflict**: sources disagree. Use the lower number, and say so in the draft summary.
- **unverified**: not checked yet. Do not state it as a limit; tell the user to check the composer.

Before a campaign, recheck any row older than ~90 days. When you report length, say whether you **counted** or are **estimating** (`CLAUDE.md → Verification`).

All rows below: last checked 2026-11-07.

---

## X

| Field | Limit | Source |
|---|---|---|
| Post, free account | 280 characters | third-party (consistent across sources) |
| Post, paid tiers | 4,000 or 25,000 by tier | conflict: sources disagree on which tier gets which |
| Links | count as 23 characters, any length | third-party |
| Emoji, CJK characters | count as 2 | third-party |
| Long posts | collapsed behind "Show more" in the feed | observed |

- Write to 280 unless the user confirms a paid tier. A long post still lives or dies on its first ~280.
- Threads: one idea per post in the thread too; the first post must stand alone.
- Hashtags: 0–2. X is search-by-keyword more than by tag.

## LinkedIn

| Field | Limit | Source |
|---|---|---|
| Post | 3,000 characters | third-party; several sources say LinkedIn's help center states it |
| Visible before "see more" | ~140 (mobile) to ~210–250 (desktop) | observed, varies |
| Comment | 1,250 characters | third-party |

- Hashtags and @mentions are plain text and count toward 3,000.
- The visible part is the post. Write the first ~140 characters as if nothing follows.
- Some authors put the link in the first comment instead of the body. Whether that helps reach is not measured here; ask the user which they prefer and record the result in `Learnings`.

## Instagram

| Field | Limit | Source |
|---|---|---|
| Caption (feed, carousel, Reels) | 2,200 characters | third-party (consistent) |
| Visible before "more" | ~125 characters | observed |
| Hashtags | 30 per post, caption + first comment combined | third-party |
| Reels aspect ratio | 9:16 | third-party |

- Hashtags count toward 2,200.
- The caption supports the image or Reel; it does not replace it. A post with no visual plan is not an Instagram post.
- Links in captions are not clickable. Point to "link in bio" only if the bio has one.

## Facebook

| Field | Limit | Source |
|---|---|---|
| Page post | ~63,000 characters is the commonly quoted figure | unverified |
| Visible before "See more" | unknown | unverified |

- Treat Facebook like LinkedIn for length until a row is checked: lead with the specific thing in the first two lines.
- Ask the user to check the composer before stating any limit.

## YouTube

| Field | Limit | Source |
|---|---|---|
| Title | 100 characters, no `<` or `>` | official (YouTube Data API reference) |
| Title visible in search / mobile | ~50–70 characters | observed, varies |
| Description | 5,000 characters | third-party (consistent) |
| Shorts length | up to 3 minutes | third-party (consistent) |
| Shorts aspect ratio | 9:16 | third-party |
| Shorts caption on player | first line only | observed |

- Front-load the title: the specific noun in the first 50 characters.
- Description: the first two lines show above the fold; links and timestamps after.

## TikTok

| Field | Limit | Source |
|---|---|---|
| Caption via API / schedulers | 2,200 characters | third-party, citing the Content Posting API |
| Caption in app | 4,000 characters | conflict: reported in 2026, not confirmed by TikTok |
| Hashtags | count toward the caption | third-party |
| Aspect ratio | 9:16 | third-party |

- Posts through Buffer or another scheduler use the API path: write to 2,200.
- The hook is the first 1–2 seconds of video and the on-screen text, not the caption. `video-script` handles that; the caption backs it up.

---

## Formats

What each format is for, so a draft picks one on purpose:

| Format | Channels | Use when |
|---|---|---|
| Single post | all | one idea, one proof point |
| Thread | X | a sequence where each step needs its own line (a changelog walk-through, a debugging story) |
| Carousel | Instagram, LinkedIn | a before/after, a list of 3–7 concrete steps |
| Short vertical video (Reels / Shorts / TikTok) | Instagram, YouTube, TikTok | the product does something visible in under 60 s |
| Long video + description | YouTube | a demo or walk-through worth searching for |

## Rewriting across channels

`repurpose` rewrites; it never truncates. For each target channel:

1. Re-pick the opening line for that channel's visible part (280 / ~140 / ~125 / title ~50).
2. Re-pick the format from the table above.
3. Keep the claim and its Evidence row; change the framing, not the facts.
4. Re-run the limits check on the new draft and report counted lengths.
