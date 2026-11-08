---
name: video-script
description: Write one video script for one channel (Instagram Reels, YouTube, TikTok) about one idea the product can show, with three openings for the first 1-2 seconds, a scene list of what is shown, said and on screen, subtitle lines, counted words and estimated seconds, and [NEEDS PROOF] on every unbacked claim. Independent of any editing tool; drafts only, never films, renders or publishes. Use when the user asks for a video script, Reel, Short, TikTok, demo video or scene list.
---

# video-script

Write the script for one video. The formats and platform facts are in `agent_docs/channels.md`, the sentence rules in `agent_docs/copywriting.md`, what counts as proof in `agent_docs/claims-and-evidence.md`; read all three first. This file is the procedure.

## Input

From `$ARGUMENTS` or the user's request: **the channel** (`instagram`, `youtube` or `tiktok`) and **the idea** (a release, a fix, a decision, a user's problem). If the channel is missing, ask; `channels.md → Formats` has no video format for the others. If the idea is missing, offer two or three from the latest changelog entries and Evidence rows that have something to show, and let the user pick. One channel and one idea per run.

The file is `drafts/video/<slug>.md`, with the frontmatter in "File shape". `channel: video` is required, not a label: it keeps `channel-limits` from counting the script as a caption, and `social-publish` from sending it (`channels.md → Draft files`). If the file already exists, ask whether to revise it or pick a new slug; never overwrite it.

## Rules

- **Map first.** If `MARKETING_MAP.md → Product, Audience` or `Positioning` is still `<...>`, stop and say to run `/brief`.
- **Something visible.** A video needs the product doing something on screen (`channels.md → Formats`). If the idea has nothing to show, say so and suggest `social-post` instead of writing talk over stock images.
- **One idea.** If a scene needs "also", the rest is a second video. Say so and stop at one.
- **What's shown is a claim.** Output on screen, a number in a terminal or a before/after has to be true of the real product, the same as a sentence. No mocked UI and no made-up output. A diagram or animation is fine if it can't pass as a recording.
- **Marks at first write.** A claim with no Evidence row gets `[NEEDS PROOF: reason]` in the same write, in the spoken line, the on-screen text or the shown scene.
- **Slots, not assets.** Whatever has to be recorded or made goes in as `[SLOT: what it must show, aspect ratio]`, specific enough to record from. Name a recording the user already has by its path.
- **No invented people.** The voice is the user's or a voiceover's. No actor, customer or presenter who doesn't exist. A customer's words appear only verbatim, with their source, from `Customer language` or `Evidence`.
- **Music and footage stay open.** Don't pick a track, stock clip or paid tool. Leave a slot and list it for approval, since paid ones are spending (`CLAUDE.md → Approval Required`).
- **Works with the sound off.** The opening's on-screen text has to make sense without the audio, and subtitles cover everything said.
- **No tool settings.** No clip IDs, keyframes, effects or editor names. The script has to work in whatever tool cuts it.
- **Drafts only.** Never film, render, publish, schedule or queue. The post text that goes with the video is a separate draft (step 9).

## File shape

```markdown
---
channel: video
for: <instagram or youtube or tiktok>
format: <short vertical or long>
ratio: <9:16, or what the user chose>
---

<!-- Stands on: <Evidence row or artefact> -->
<!-- Openings not used: <the other two> -->

## Scenes

| # | Shown | Said | On screen | Words | Est. s |
|---|---|---|---|---|---|
| 1 | [SLOT: the install command running in a clean folder, 9:16] | <spoken line, or none> | <short text, or none> | 9 | 4 |

## Subtitles

1. <first subtitle line>
   <next subtitle line>
2. <first subtitle line>
```

Scene 1 is the opening. In a table cell, write "or" between alternatives, never a pipe.

## Steps

1. **Load.** Read `MARKETING_MAP.md` (Product, Audience, Positioning, Voice, Banned words, Evidence, Customer language, the channel's row in Channels, Learnings) and the changelog entry or source behind the idea.
2. **Material.** Name the Evidence row or artefact the video stands on, what the viewer will actually see happen, and the reader's moment (`Audience → Primary buyer`). Check `Learnings` for what worked or didn't on this channel before.
3. **Format.** Pick one from `channels.md → Formats` and say why. Short vertical is 9:16 and under 60 s unless the user says otherwise. For a long YouTube video, `channels.md` has no ratio or length, so ask for both.
4. **Opening.** The first 1-2 seconds are the picture and the on-screen text, not the caption (`channels.md → TikTok`). Write three with different patterns from `copywriting.md → The opening line`, each with what's shown, what's said and what's on screen. Pick one and say why; keep the other two in an HTML comment.
5. **Scenes.** Write the table: one thing happening per scene, in the order the viewer needs it. Each spoken line follows `copywriting.md → Body` and is written to be said aloud. On-screen text is short and adds to the spoken line instead of repeating it. The last scene is the call to action from `copywriting.md → Call to action`, with the command or the exact page visible.
6. **Subtitles.** Under `Subtitles`, write every spoken line word for word, numbered by scene and broken into short lines at natural pauses. Change no words. Timing comes from the recording, so don't write timestamps. If nothing is spoken, say so and leave the on-screen text to carry it.
7. **Count.** Count the words in each spoken line (`printf '%s' "<line>" | wc -w`), and don't judge them by eye. Estimate seconds at about 2.5 words per second for English, plus the time a scene holds with nothing said. That rate is a rule of thumb, so ask the user to time a read-aloud. If the total is over the target, cut a scene, not the pace.
8. **Revise and gate.** `copywriting.md → Revising`, all six steps; step 5 here is step 7's counts against the target. Then run `slop-audit`, then `claim-audit`, on the file and apply only the rewrites the user approves.
9. **Report**, then stop:
   - the file path, channel, format and ratio;
   - the opening you picked and why;
   - the counted words, and the seconds marked as estimated, per scene and in total, against the target;
   - every `[NEEDS PROOF]` and `[SLOT: …]` still in the script, as the list of what to record or prove;
   - every competitor comparison, number, guarantee, price, music or footage choice, which need the user's approval (`CLAUDE.md → Approval Required`);
   - that nothing has been filmed or published, that `video-produce` makes the video once the slots are filled, that the caption comes from `social-post` with this script as the artefact, and that publishing needs that caption, the finished video at a public link, and `social-publish`.
