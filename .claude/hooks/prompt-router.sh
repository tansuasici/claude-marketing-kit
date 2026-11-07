#!/usr/bin/env bash
#
# prompt-router.sh — UserPromptSubmit hook
#
# Looks at the user's prompt and injects the matching marketing-discipline
# reminder when the task touches a known failure point (numbers and claims,
# publishing, social posts, landing copy). Emits nothing when no keyword
# matches. Always exits 0.
#

set -euo pipefail

INPUT=$(cat)
HOOK_LIB="$(cd "$(dirname "$0")/lib" 2>/dev/null && pwd)" || exit 0
source "$HOOK_LIB/json-parse.sh"
source "$HOOK_LIB/emit.sh"

PROMPT=$(parse_json_field "prompt")
[ -z "$PROMPT" ] && exit 0
LOWER=$(printf '%s' "$PROMPT" | tr '[:upper:]' '[:lower:]')

REMINDERS=""
append() { REMINDERS="${REMINDERS}${1}"$'\n'; }
# Whole words only: "postgres" is not "post".
has() { printf '%s' "$LOWER" | grep -qE "(^|[^a-z])($1)([^a-z]|$)"; }

# Copy of any kind: the map comes first
if has 'copy(writing)?|headlines?|taglines?|landing( page)?|hero|homepage|email(s)?|newsletter|launch|announcement|blog post'; then
  append "[Map first] Read MARKETING_MAP.md → Product, Audience, Positioning and Voice before writing. Describe only features that exist in the repo or changelog; if the map is the empty template, fill it in first."
fi

# Numbers, proof, social proof
if has 'stats?|numbers?|metrics?|percent(age)?|testimonials?|case stud(y|ies)|customers?|users?|reviews?|social proof|results?'; then
  append "[Evidence] Every number, customer name, quote or result needs a line in MARKETING_MAP.md → Evidence. Never invent one. Mark a gap [NEEDS PROOF] and ask."
fi

# Social posts
if has 'tweets?|threads?|x post|linkedin|instagram|facebook|youtube|tiktok|reels?|shorts|captions?|social( media)?'; then
  append "[Channel] Write to the channel's format and limit (MARKETING_MAP.md → Channels). One idea per post; no hashtag walls."
fi

# Publishing anything outside the repo
if has 'publish|post (it|this|now)|schedule|send (it|the|this)|go live|ship (it|the post)'; then
  append "[Publish gate] Nothing leaves the repo without the user's explicit yes in this session. Show the final text, the channel and the time, then wait. publish-gate.sh repeats them in the permission prompt."
fi

[ -z "$REMINDERS" ] && exit 0
emit_context "UserPromptSubmit" "$REMINDERS"
exit 0
