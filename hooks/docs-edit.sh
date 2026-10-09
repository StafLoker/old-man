#!/bin/bash
# PreToolUse (Write|Edit): remind to load a docs skill before touching Markdown.
file=$(jq -r '.tool_input.file_path // empty')
case "$file" in
  *.md|*.mdx)
    printf '%s' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"If this file is documentation, load old-man:tech-docs (developers, operators) or old-man:user-manual (end users) first and follow it."}}'
    ;;
esac
