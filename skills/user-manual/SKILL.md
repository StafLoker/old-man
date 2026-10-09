---
name: user-manual
description: >
  Use this skill whenever the task is to write, review, fix or update documentation for the END USERS of a SOFTWARE product — a desktop, web or mobile application, CLI, or a service with a console: user manual, user guide, quick start, getting-started guide, how-to pages, troubleshooting, FAQ, install/upgrade/uninstall instructions, "docs de usuario", "manual de usuario", "guía de inicio rápido". Also use it when the user says "fix / improve / update the user docs" or after code changes that alter what users see. Teaches the way good product manuals are written (patterns taken from the paper that ships in the box): task-first, numbered one-action steps with a visible result, warnings by severity, plain short sentences, a way out when something fails. Software only: not for physical products, and not for developer-facing docs (use tech-docs).
---

# User Manual Skill

Write, fix and update documentation for people who want to **use** a product,
not understand it.

Core idea: the reader is busy doing, not reading. A manual is the shortest
path from "I want X" to "X is done", plus a way out when it fails. Everything
else is optional and must not sit in the way.

---

## Step 0 — Establish context (always first)

Find out, from the repo and existing docs before asking anything:

- **Product shape**: GUI app, web app, mobile app, CLI, service with a
  console. Decides whether steps are clicks, taps or commands.
- **Reader**: who they are, what they already know, what they want to get
  done. Two readers (operator and admin) = two doc sections, not one blend.
- **Language and address form**: copy the existing docs. If none, ask once.
  Use one form of address everywhere.
- **Project conventions**: glossary, terminology notes, component syntax
  (image components, admonitions), `memory/` or `CLAUDE.md` rules. Obey them.
  They override this skill on syntax and vocabulary.
- **What you can see**: you cannot see a UI from code. Never invent labels,
  menus, defaults or screens. Read the source for real strings, run the app
  if you can, or ask for screenshots. Anything unconfirmed gets `UNVERIFIED`
  in the draft and in your report.

Pick the mode: **Write** (nothing exists), **Fix** (docs exist, quality
issues), **Update** (docs exist, the product changed). Say which.

---

## Mode: Write

1. **List user goals**, not features. "Create a flow", "Restore a backup",
   not "The Flow menu". Each goal becomes one task page.
2. **Lay out the set** in this order (skip what the product has no use for):
   1. _Start here_ — what it is, who it is for, what you need, the paths
      ("first time → Quick start; upgrading → Upgrade").
   2. _Quick start_ — happy path only, first success in minutes.
   3. _Install / upgrade / uninstall / versions_.
   4. _Tasks_ — one page per goal.
   5. _Reference_ — settings, shortcuts, limits, formats, as tables.
   6. _Troubleshooting_ and _FAQ_.
   7. _Glossary_.
   8. _Security, legal, support contact_ — kept apart from the steps.
3. **Write each task page** from `references/page-templates.md`.
4. **Check** against `references/checks.md`. Fix before showing.

---

## Mode: Fix

1. Run the checks in `references/checks.md` on every page. Report findings
   first, grouped by level, each with what the reader suffers.
2. Fix: split pages that mix purposes, turn prose procedures into numbered
   steps, add missing prerequisites/results/recovery, unify terms, cut filler.
3. **Never change facts.** If a fix needs information you do not have (where
   a download comes from, what an option does, what a state means), leave a
   visible `TODO(author): …` and list it in your report. Do not guess.
4. Keep terminology, tone and component syntax of the existing docs.
5. Contradictions between pages (names, counts, paths) go in the report even
   if you cannot tell which side is right.

---

## Mode: Update

1. Get the change range: latest tag to `HEAD`, or a ref the user gives
   (`git log`, `git diff --stat`).
2. Translate code changes into **user-visible** changes (new option, renamed
   label, removed feature, changed default, new requirement). Pure internals
   change no page.
3. Find the affected pages by searching the docs for the old labels, names
   and settings. Edit only those pages.
4. Add pages for new goals; delete or redirect pages for removed ones.
5. Update version statements.
6. Report: pages changed, pages added/removed, user-visible changes found
   with no page yet, anything `UNVERIFIED`.

---

## Rules that apply in every mode

### Procedures

- Numbered list, one action per step, imperative verb first
  ("Click **Start**."), present tense, short.
- When the reader could lose their place, split into sub-procedures by
  sub-goal, each with its own heading.
- Before step 1: what the reader needs (software, rights, files, time) when
  it is not obvious, and which branch applies ("Already signed in? Skip to
  step 4.").
- After a step that changes something, one unnumbered result line naming
  something observable: "The status shows **Connected**." "The list shows 3 rows."
- Name UI elements exactly as on screen, in **bold**. Never paraphrase a label.
- Branches ("if A… if B…") become separate short procedures or a table,
  never one paragraph.
- Where failure is plausible, say what it looks like and the cheapest fix:
  "If nothing happens, check your network connection. If it still fails, see
  _Troubleshooting_."

### Warnings

Three tiers, by consequence, used rarely:

- **Danger / Warning**: data loss, security exposure, irreversible action. Says what
  happens and how to avoid it.
- **Caution**: may damage or break the task.
- **Note / Tip**: helpful, harmless.

A prohibition always carries its reason ("Do not X; it deletes Y."). Warnings
sit right before the step they affect. Never put steps or commands inside a
warning box.

### Language

- Present tense, active voice, you-form. One form of address.
- One idea per sentence. A sentence the reader must read twice gets split.
- **One term per concept.** Choose it, put it in the glossary, use it
  everywhere, including UI labels and other doc sets. Never alternate
  synonyms for variety.
- Define a term at first use or link to the glossary. Avoid jargon, internal
  names and acronyms the user never sees.
- No reassurance or marketing ("easy", "powerful", "don't worry"). Every
  sentence carries an action or a fact.
- Units with a space and the same notation throughout ("15 s", "Ctrl+S").
- Say what to do, not what the product "allows" or "lets you".

### Structure and navigation

- One page, one purpose. A page that mixes concepts, reference and steps is
  split: steps stay, the rest is linked.
- Every page opens with one sentence: what you will achieve, and who needs it.
- Headings are the reader's goals or symptoms, not feature names.
- Cross-link to the exact section; no "see above".
- Say each fact once. Repeated notes go in one shared place and are included
  or linked.

### Images

- An image supports the text; it never replaces it. Settings, shortcuts and
  values must exist as text or tables.
- One annotated image per step group, callouts numbered in step order.
- Describe the image in alt text in the page language; never "Step 1".
- Screenshots go stale: crop to the relevant area and avoid version numbers
  and personal data.

### Cover the long tail

Before finishing, ask for each task: what does the reader need first, what if
it fails, how do I undo it, what does it not do, what does it cost
(time, data loss, licence). Missing answers become sections or `TODO(author)`.

---

## Reference material

- **`references/page-templates.md`** — skeletons for: start-here, quick
  start, task, install/upgrade/uninstall, reference, troubleshooting, FAQ,
  glossary. Read when writing or restructuring a page.
- **`references/checks.md`** — checks by severity: wrong or harmful, cannot
  finish, hard to read. Read in Fix mode and before finalising any mode.

---

## Quality checklist (before finalising)

- [ ] Mode stated; context (reader, language, conventions) established
- [ ] Every task page: goal sentence, prerequisites, numbered steps, result
      lines, recovery pointers
- [ ] No level 1 finding left open; every step is one action
- [ ] Warnings tiered, with reasons, before the step they affect
- [ ] One term per concept; glossary current; address form consistent
- [ ] Nothing invented: unknowns are `UNVERIFIED` or `TODO(author)`
- [ ] Troubleshooting, upgrade and uninstall exist or their absence is
      reported
- [ ] Links and anchors resolve
