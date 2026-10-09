# Checks — technical docs

A check finds a problem an engineer would actually hit. It is not a style
score. Report a finding only when you can say what the reader suffers
("deploys with a unit file systemd never loads"). If you cannot name the
harm, it is not a finding.

There are no numbers to hit. Where a number appears it is a hint of where to
look, never a pass/fail line.

Work through the levels in order. Level 1 findings are reported and fixed
first.

Report format, grouped by level:

```
| Where (file:line) | Problem | What the reader suffers | Fix |
```

---

## Level 1 — Wrong or harmful

The reader builds, deploys or decides on something false.

1. **Docs disagree with the code.** Options, defaults, ports, endpoints,
   states, error codes, behaviour, dependencies.
   *Find:* for every concrete claim, open the code, config or schema that
   defines it. Read; do not infer from names. Also the reverse: important
   options or endpoints in code that no doc mentions. *Fix:* correct the doc;
   when unsure which side is right, report both.
2. **How-to does not work.** Missing step, path never created, wrong file
   name or location, command that fails when pasted, wrong working directory.
   *Find:* run it on a clean checkout or machine, or walk it literally step by
   step. Say which ones you could not run. *Fix:* add or correct the step.
3. **Unsafe instruction.** Secrets on the command line or in examples,
   security disabled to make it work, ports or permissions wider than needed.
   *Fix:* safe alternative, or state the risk.
4. **Security silence.** What is protected and what is not is left unsaid
   (auth scope, trust boundaries, data at rest). The reader assumes protection
   that is not there. *Fix:* state the limits plainly.
5. **Contradiction.** Two pages, or technical docs and user docs, disagree on
   names, counts, paths, status codes. *Fix:* settle it against the code.
6. **Broken links and anchors.** *Find:* build the site with broken-link
   errors on, if the generator supports it. *Fix:* repair.

## Level 2 — Cannot use or cannot find

The information exists, but the reader cannot act on it or does not reach it.

7. **Page mixes needs.** Steps buried in an explanation, rationale inside a
   reference table, a tutorial that stops to list every option. The reader
   who came for one thing reads all of them. *Fix:* split by page type and
   link.
8. **First sentence says nothing.** The reader cannot tell from the opening
   what the page or component is, does and covers. *Fix:* one sentence: what
   it is, what it does, scope.
9. **Reference entry incomplete.** Missing type, unit, default, required or
   not, allowed values, what happens on bad input. The reader has to read the
   code anyway. *Fix:* add the missing fields.
10. **Example cannot be run or has no output.** Pseudo-code presented as real,
    missing imports or setup, no expected result. *Fix:* minimal runnable
    example with its output.
11. **How-to without a check or failure modes.** The reader cannot tell it
    worked, or what to do when it did not. *Fix:* expected output after state
    changes; symptom, cause, fix after the steps.
12. **Component page missing a section** of the project's template (or of the
    skeleton in `page-templates.md` if the project has none), with no stated
    reason. *Fix:* add it or state "not applicable: …".
13. **Decision without a record.** An important choice (storage, protocol,
    framework, security model) is explained nowhere, or explained inside
    another page where it gets edited away. *Fix:* decision record, linked.
14. **Cannot find it.** Headings are not what a reader would search; index
    pages are bare link lists; no path from overview to detail. *Fix:*
    rename, one line per link, add the route.

## Level 3 — Will go stale or is hard to read

Fine today; misleading after the next change, or slower to read than needed.

15. **Volatile identifiers in explanations.** File names, function names,
    constants, line numbers in prose or folder trees. They break silently on
    refactor. *Fix:* describe the behaviour or responsibility; link to the
    source for exact names.
16. **Copied volatile values.** Full config samples, schemas or version lists
    pasted instead of linked. *Fix:* link to the source of truth or generate.
17. **Unpinned versions.** "latest", "newest release", unversioned image tags.
    *Fix:* pin.
18. **`covers:` / `verified:` missing or stale** — only if the project uses
    this convention; otherwise propose it once in the report, do not flag every
    page.
19. **One thing, several names**, or prose words in another language where
    the doc language has a normal term. *Fix:* glossary term everywhere; keep
    foreign words only for code, protocols, product names and established
    terms.
20. **Sentence you have to read twice.** Several ideas, chains of asides,
    nested clauses. Long sentences are where to look, but read them; length
    alone is not the problem. Dashes are a punctuation choice, not a fault (in
    Russian they are grammar). *Fix:* one idea per sentence.
21. **Diagram does not answer one question.** Mixes structure and flow, too
    many boxes to follow, or replaces the sentence that should state the
    point. *Fix:* one question per diagram, named in the caption; split.
22. **Same content repeated** across pages. *Fix:* one place, linked.
23. **Filler and hedging.** "simply", "just", "it is important to note",
    marketing adjectives, in whatever language the doc uses. *Fix:* delete.
