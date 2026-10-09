# Checks — user manual

A check finds a problem a reader would actually hit. It is not a style score.
Report a finding only when you can say what the reader suffers ("stops at
step 3: the file it asks for is never explained"). If you cannot name the
harm, it is not a finding.

There are no numbers to hit. Where a number appears it is a hint of where to
look, never a pass/fail line.

Work through the levels in order. Level 1 findings are reported first and
fixed first; a page with a level 1 problem is not finished, however well it
reads.

Report format, grouped by level:

```
| Where (file:line) | Problem | What the reader suffers | Fix |
```

---

## Level 1 — Wrong or harmful

The reader does the wrong thing, loses data, or cannot continue at all.

1. **Doc does not match the product.** Labels, menus, options, defaults,
   states, messages.
   *Find:* compare every quoted label and value with the source strings, the
   running app or screenshots the user gave. *Fix:* correct it; if you cannot
   confirm it, mark `UNVERIFIED`.
2. **Dead end.** The reader is told to use something nobody explains: "download
   the agent", "ask your administrator", "resolve it with the editor options".
   *Find:* for each noun the reader must obtain or choose, ask "where from? which
   one?". *Fix:* name the source, person or option; if unknown,
   `TODO(author)`.
3. **Procedure cannot be followed literally.** A path that is never created, a
   step that depends on something done on another page, a command that fails
   if pasted.
   *Find:* walk the steps in order as someone who has read nothing else.
   *Fix:* add the missing step or prerequisite.
4. **Destructive action without warning.** Delete, overwrite, reset, revoke,
   anything irreversible.
   *Find:* look for these verbs in steps. *Fix:* warning before the step:
   what is lost and how to avoid or back up.
5. **Unsafe instruction.** Passwords on the command line, disabling security
   to make something work, permissions wider than needed.
   *Fix:* safe alternative, or state the risk plainly.
6. **Contradiction.** Two pages (or this manual and the technical docs) say
   different things: names, counts, paths, behaviour.
   *Fix:* report both; correct only if the source settles it.
7. **Broken links and anchors.**
   *Find:* build the site with broken-link errors on, if the generator
   supports it; otherwise follow each link. *Fix:* repair.

## Level 2 — Cannot finish or cannot find

The information exists, but the reader does not reach it or cannot act on it.

8. **Task told as prose.** "First you open…, then in the window that appears
   you…". *Fix:* numbered steps, one action each.
9. **Step hides several actions or a choice.** The reader does one and misses
   the other. *Fix:* split; turn the choice into separate short procedures or
   a table.
10. **Reader loses their place.** The procedure has sub-goals, or they must
    scroll back to check which step they are on. Hint: past roughly 7-10
    steps this usually happens. *Fix:* split by sub-goal, each with a heading.
11. **"Did it work?"** After a step that changes something there is nothing
    to check against. *Fix:* one result line naming what the reader sees.
12. **No way out.** A failure that plausibly happens (no connection, wrong
    rights, file in use) has no recovery. *Fix:* "If X happens, do Y" after
    the step, or a link to Troubleshooting.
13. **Missing prerequisite** that would stop the reader halfway: software,
    account, rights, files, time. Trivial procedures need none. *Fix:* list
    before step 1.
14. **Page mixes purposes.** Concepts, full option lists and tasks on one page;
    the reader looking for the steps wades through the rest. *Fix:* steps stay,
    the rest moves to its own page and is linked.
15. **Cannot find it.** Headings name features instead of goals or symptoms;
    no start page routes readers; the answer sits in an unrelated page. *Fix:*
    rename headings to the reader's words, add routes from the start page.
16. **Information only in an image.** Values, shortcuts or settings appear only
    in a screenshot; cannot be searched, copied or read by a screen reader.
    *Fix:* add them as text or a table.
17. **Lifecycle gap.** No install, upgrade, uninstall, troubleshooting or
    version info where the product needs it. *Fix:* add the page, or report
    the absence.

## Level 3 — Hard to read

The reader gets there, but slower or less sure than needed.

18. **One thing, several names.** "stage", "step", "action" for the same
    concept; the reader wonders if they differ. *Fix:* pick one, put it in the
    glossary, replace the rest.
19. **Mixed form of address** within a page or across pages. *Fix:* use the
    one the project already uses most.
20. **Sentence you have to read twice.** Several ideas, nested clauses, an
    aside that interrupts the instruction. Long sentences are where to look,
    but read them; a long, clear sentence is fine, and a short, ambiguous one
    is not. *Fix:* one idea per sentence; move asides out.
21. **Filler.** Reassurance, marketing, "simply", "easily", obvious statements,
    in whatever language the doc uses. *Fix:* delete; if nothing remains, the
    sentence had nothing to say.
22. **Unexplained jargon.** Internal names, acronyms or technical terms the
    user never sees in the product. *Fix:* replace with the user's word or
    define at first use.
23. **Warnings everywhere.** So many notes and warnings that readers stop
    reading them, or a harmless tip styled as a danger. *Fix:* keep warnings
    for real consequences; turn the rest into plain text or delete.
24. **Same content repeated** on several pages; when one copy changes, the
    others go wrong. *Fix:* one place, linked or included.
25. **Useless alt text** ("Step 1", "image") or alt text in another language.
    *Fix:* describe what the image shows, in the page language.
