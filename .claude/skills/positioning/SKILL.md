---
name: positioning
description: Test the Positioning in MARKETING_MAP.md against what changed since it was written (changelog, user feedback, Learnings), propose a sharper or new position next to the old one with its evidence, and after approval update the map, log it in Changes and list the drafts that carry the old line. Use when the position feels off, after a release or pivot, or before a launch.
---

# positioning

Check whether the current position still holds, and change it if it doesn't. The field rules and the checklist are in `agent_docs/positioning.md`; read it first. This file is the procedure.

`brief` fills an empty map. This skill works on a filled one: it tests it and moves it.

## Input

What prompted the run, if the user said (`$ARGUMENTS`): a release, a pattern in feedback, a launch, "it feels off". If nothing is given, test the position as it stands.

## Rules

- **Filled map only.** If `Product`, `Audience` or `Positioning` is still `<...>`, stop and say to run `/brief`.
- **Propose, don't overwrite.** Changing Positioning or Audience needs the user's explicit yes (`CLAUDE.md → Approval Required`). Show old and new side by side; write nothing to the map before the yes.
- **Evidence or a mark.** A new `Why switch` points at an Evidence row, or carries `[NEEDS PROOF]` with what would prove it. A new Evidence row needs a source you found and showed (a changelog entry, a code ref, an issue link, a measured number); add it after the user confirms.
- **Alternatives from links only.** Facts about `Against` come from its own README or docs, linked. Never a weakness you inferred.
- **No change is a valid result.** If the position passes and nothing moved, say so and stop.

## Steps

1. **Load.** Read `MARKETING_MAP.md` (Product, Audience, Positioning, Evidence, Customer language, Learnings, Changes). The newest `Changes` row is the date and version the current position was set.
2. **What moved since then.** Read what is newer than that date:
   - the changelog and merged PRs: a feature that gives a new or stronger `Why switch`, or one that removed the old one;
   - issues, discussions and `Customer language`: who is actually showing up, which alternative they name, the words they use;
   - `Learnings`: which angle got a measured response and which didn't.
   Copy new user phrases into the report verbatim with source and date, so they can go into `Customer language`.
3. **Test.** Go through `positioning.md → Testing a position`, box by box, and say for each whether it holds now, with the source. Run the swap test on the one-liner with the current `Against`.
4. **Propose.** If a box fails or step 2 found a shift, write the new lines for the fields that change only (Category, Against, Why switch, One-liner, and Audience fields if the reader moved). Show:

```
positioning: v<current> → v<next> (proposed)

<Field>
  now:  <current line>
  new:  <proposed line>
  why:  <what moved, with source>
  proof: <Evidence row> | [NEEDS PROOF: what would prove it]

Testing a position (with the new lines)
- [x] / [ ] <box> — <source or what's missing>

Proposed Evidence rows
| <claim> | <source> | <today> |
```

   If two directions are both supported, show both and say which you'd pick and why. Then stop and wait.
5. **Write, after the yes.** Update only the approved fields. Add the approved Evidence rows. Add a `Changes` row on top: next version, today's date, the sections changed, the change in a few words, and the trigger from step 2.
6. **Flag old copy.** Search the drafts and copy files (`drafts/`, README, site pages in the repo) for the old one-liner, the old `Why switch` wording and the old `Against` name. List each file and line that still carries the old position; don't edit them in this skill. Suggest `landing-copy` or a revision pass for the ones that matter.
