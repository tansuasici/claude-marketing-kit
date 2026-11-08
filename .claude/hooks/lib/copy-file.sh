#!/usr/bin/env bash
#
# copy-file.sh — which files the copy hooks (slop-scan, claim-scan) read
#
# Usage:
#
#   source "$HOOK_LIB/copy-file.sh"
#   is_copy_file "$FILE" "$ROOT" || exit 0
#
# Copy files: .md .mdx .markdown .txt .html .htm, except the kit's own files
# (agent_docs/, .claude/, CLAUDE.md, AGENTS.md, CLAUDE.project.md,
# MARKETING_MAP.md, CHANGELOG.md, linear.md) and research/ (competitor
# briefs and other notes that quote other people's marketing on purpose).
#

is_copy_file() {
  local file="$1" root="$2"
  case "$file" in
    *.md|*.mdx|*.markdown|*.txt|*.html|*.htm) ;;
    *) return 1 ;;
  esac
  case "/${file#"$root"/}" in
    */agent_docs/*|*/.claude/*|*/research/*|*/CLAUDE.md|*/AGENTS.md|*/CLAUDE.project.md|*/MARKETING_MAP.md|*/CHANGELOG.md|*/linear.md) return 1 ;;
  esac
  return 0
}
