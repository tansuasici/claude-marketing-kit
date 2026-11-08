<p align="center">
  <img src="assets/logo.png" alt="Claude Marketing Kit" width="160">
</p>

<h1 align="center">Claude Marketing Kit</h1>

<p align="center">Drop-in templates that make Claude Code market a developer product like the person who built it: claims backed by evidence, drafts written for one channel at a time, nothing published without your approval.</p>

<p align="center">
  <a href="https://github.com/tansuasici/claude-marketing-kit/blob/main/CHANGELOG.md">Changelog</a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/status-pre--release-0f766e" alt="pre-release">
  <img src="https://img.shields.io/badge/license-MIT-0f766e" alt="MIT">
</p>

> **Status:** early skeleton. The ruleset, the map template and the hooks are
> in place; skills and agents land before 0.1.0.

## The Problem

Out of the box, Claude Code writes marketing that sounds like every other
launch post. It will:
- Call the product "revolutionary", "seamless" and "game-changing"
- Invent a user count, a benchmark or a testimonial to fill a gap
- Write one post and cut it down for every channel
- Offer to publish before anyone has checked a claim

## The Solution

A `CLAUDE.md` ruleset, a positioning file and hooks that enforce one loop:

**Research → Position → Create → Gate → Measure**, every time.

The cardinal rule: **every claim traces back to a row in
`MARKETING_MAP.md → Evidence`.** A claim without one is marked `[NEEDS PROOF]`.

## Quick Start

From your product repo:

```bash
npx @tansuasici/claude-marketing-kit init
```

Then start a Claude Code session and run `/brief`: Claude reads the repo and
fills `MARKETING_MAP.md` (Product, Audience, Positioning, Voice) with you, one
section at a time. The map is read first every session.

### Other ways to install

**As a Claude Code plugin**, inside Claude Code:

```
/plugin marketplace add tansuasici/claude-plugins
/plugin install marketing-kit@tansuasici
```

**From a clone:**

```bash
git clone https://github.com/tansuasici/claude-marketing-kit ~/claude-marketing-kit
bash ~/claude-marketing-kit/install.sh "$PWD"
```

### Installer options

| Flag | Description |
|------|-------------|
| `--upgrade` | Update kit-managed files |
| `--force` | Replace kit files that already exist |
| `--gitignore` | Keep the kit out of your repo |
| `--dry-run` | Print what would happen; change nothing |

Your overlay (`MARKETING_MAP.md`, `CLAUDE.project.md`, `linear.md`) is never
overwritten. `npx @tansuasici/claude-marketing-kit uninstall` deletes only the
files the kit installed; `--keep-project` also keeps the overlay.

Requirements: bash, git and python3 (Node 18+ for npx).

## Social media and video (opt-in)

Drafts are the default; the kit never needs an account. To publish, connect
your own scheduler and turn a channel on:

1. Add a scheduler MCP, for example Buffer: `claude mcp add --transport http buffer https://mcp.buffer.com/mcp`, then run `/mcp` to sign in.
2. Set `publish: on` for that channel in `MARKETING_MAP.md → Channels`.
3. Run `/social-publish <draft>`. It checks the draft, shows the exact text, channel, account and time, and sends only after your yes. One approval covers one post; `publish-gate.sh` blocks channels that are still `off` and asks again in the permission prompt.

Buffer takes no file uploads, so a video goes out through a link. Put the file on
a host you choose, at a public, direct, permanent HTTPS link, and list that link
under `media:` in the caption draft's frontmatter. The kit checks the link and
never uploads anything. A script with open marks stops the post. This hasn't been
tried with a real Buffer account yet.

Planned channels: X, LinkedIn, Instagram, Facebook, YouTube, TikTok.
`/video-script` writes the script, scene list and subtitles for any editing
tool. `/video-produce` turns that script into a local video file with Remotion
(code-based video) or Instagram Edits for Mac, and never publishes it. It hasn't
been run end to end yet.

To connect Edits (Apple silicon Mac, Instagram account): in the app, open
Settings → Automation, turn on the server, and run the Claude Code command it
shows in your own terminal. The command holds a token, so keep it out of chat
and out of your repo. Claude works only in a new project, and an export is a
local file, never a post. The tool map and rules are in
`agent_docs/video-tools.md`; only read-only calls have been tried so far.

To use Remotion, check its licence first: free for individuals, for teams of up
to 3 and, with limits, for non-profits; a company of 4 or more needs a paid
licence. Remotion's own skills install into your Remotion project, not through
this kit:

```bash
npx create-video --yes --blank my-video
cd my-video
npx remotion skills add
```

The steps and rules are in `agent_docs/video-tools.md`. This kit hasn't rendered
a video with them yet.

## Hooks

| Hook | Event | Does |
|---|---|---|
| `session-start.sh` | SessionStart | Reports whether `MARKETING_MAP.md` is filled, shows Product and Positioning, lists `linear.md → Now`. |
| `prompt-router.sh` | UserPromptSubmit | Adds reminders for claims, channel limits and publishing. |
| `branch-protect.sh` | PreToolUse (Bash) | Blocks pushes to `main`/`master` and force-pushes. |
| `block-dangerous-commands.sh` | PreToolUse (Bash) | Blocks destructive shell commands. |
| `slop-scan.sh` | PostToolUse (Write, Edit) | Warns about hype words, filler phrases, soft-word clusters, em-dash density and emoji bullets in copy files, using `agent_docs/slop-signs.md` and `MARKETING_MAP.md → Banned words`. |
| `claim-scan.sh` | PreToolUse + PostToolUse (Write, Edit) | Blocks invented social proof in copy files (an attributed quote, `trusted by N teams`, `as seen on`) unless `MARKETING_MAP.md → Evidence` backs it or the line carries `[NEEDS PROOF]` / `[SLOT: …]`. After the write, warns about numbers, prices and superlatives with no Evidence row and counts open `[NEEDS PROOF]` marks. |
| `channel-limits.sh` | PostToolUse (Write, Edit) | Counts a draft against its channel's limits in `agent_docs/channels.md` (X links as 23 and emoji as 2, hashtag caps, the visible opening, YouTube title rules) and reports the counted lengths. The channel comes from `channel: x` frontmatter or the path (`drafts/x/`, `launch.linkedin.md`). |
| `publish-gate.sh` | PreToolUse (MCP tools) | Turns a scheduler call that publishes, schedules or queues a post into a permission prompt showing the channel, time and text; your answer is the approval for that one post. Denies it when the channel (or, if the call doesn't name one, every channel) has `publish: off` or there is no `MARKETING_MAP.md`. Drafts and ideas pass. Limits: Buffer's `channelId` doesn't name the service, so the channel is read from `metadata` keys or a `service` field when present; it can't read the conversation, and `bypassPermissions` mode may skip the prompt. |

## What's Inside

```
CLAUDE.md                 ruleset (tiered boot, the loop, cardinal rule, approvals, verification)
MARKETING_MAP.md          Product, Audience, Positioning, Voice, Banned words,
                          Evidence, Channels, Customer language, Learnings, Changes
CLAUDE.project.md         your project overlay (never touched by upgrades)
linear.md                 open work: Now / Next / Later (created on install)
.claude/hooks/            8 hooks + lib/
.claude/skills/           /brief (fills MARKETING_MAP.md with you),
                          /claim-audit (checks a draft's claims against Evidence)
                          /slop-audit (hype, filler, competitor test, voice)
                          /landing-copy (writes a landing page from the map)
                          /positioning (tests the position, proposes a new one)
                          /competitor-brief (one linked page per alternative)
                          /social-post (one post, one channel, counted)
                          /repurpose (rewrites one idea for another channel)
                          /video-script (one video: scenes, spoken lines, subtitles; no tool settings)
                          /video-produce (one script, one tool, one local file; checked against the script)
                          /email-sequence (one trigger, one goal, 5 emails at most)
                          /launch-plan (readiness, pieces, go/no-go, what to measure)
                          /voice-of-customer (users' words, verbatim, with source and permission)
                          /seo-audit (one page, every check says how it ran, no rank promises)
                          /campaign-report (numbers with sources, what can't be concluded, Learnings)
                          /social-publish (opt-in, one draft, your yes on the exact post, never sent twice)
.claude/settings.json     hook wiring and permissions
```

## Contributing

PRs welcome. Open an issue first for a new skill or channel.

## License

MIT. See [LICENSE](LICENSE).
