#!/bin/bash
# UserPromptSubmit: remind to load a docs skill when the prompt is about docs.
# jq regex is Unicode-aware, so Spanish and Russian match regardless of locale.
# Broad on purpose: stems for document/instruction/tutorial, whole words for short ones.
jq -e '.prompt // "" | test("\\b(docs?|readme|wiki|faq|how-?tos?|guides?|manuals?|manuales|gu[ií]as?|help|ayuda|ридми|мануал|доки|гайды?)\\b|document|instruc|tutorial|troubleshoot|docstring|руководств|инструкц|справк|туториал|документ"; "i")' >/dev/null || exit 0
printf '%s' '{"hookSpecificOutput":{"hookEventName":"UserPromptSubmit","additionalContext":"DOCS TASK. Before writing or editing documentation load old-man:tech-docs (README, docs/, for developers and operators) or old-man:user-manual (end users of the software), and follow it."}}'
