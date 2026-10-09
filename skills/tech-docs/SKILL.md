---
name: tech-docs
description: >
  Use this skill whenever the task is to write, review, fix or update documentation for DEVELOPERS and OPERATORS of a software project: README, architecture overview, component docs, design explanations, decision records (ADR), developer setup/build/test guides, deployment and operations guides, API/CLI/config reference, glossary, "docs técnicos", "documentación técnica", "arquitectura". Also use it when the user says "fix / improve / update the technical docs" or after code changes that alter behaviour, interfaces, configuration or deployment. Teaches how well-regarded hand-written technical docs are built: separate pages by reader need (learn, do, look up, understand), fixed skeletons per page type, short plain sentences, constraints inline, rationale kept apart, docs that resist going stale. Not for end-user manuals (use user-manual) or for planning a project that does not exist yet (use tech-plan).
---

# Technical Docs Skill

Write, fix and update documentation that lets another engineer understand,
run, change and operate a system without asking its author.

Core idea: **a reader arrives with one need.** Learn the system, do a task,
look up a fact, or understand why. A page serves one need. Mixed pages serve
none well.

---

## Step 0 — Establish context (always first)

From the repo and existing docs, before asking anything:

- **System shape**: service, CLI, library, desktop/mobile app, monorepo of
  several components. Decides which page types apply. A library has no
  deployment page; a CLI has no REST reference.
- **Readers**: contributors, integrators calling the API, operators running
  it. Name them; each page names its reader in the first sentence.
- **Language, tone, site generator, component syntax, templates, glossary**:
  copy what exists. Project templates and memory notes override this skill
  on syntax and vocabulary.
- **Ground truth**: code, config files, schemas, CI, existing docs. Docs
  state what the system does, so read the code; never write from a name or
  a guess. Anything you could not confirm is marked `UNVERIFIED`.

Pick the mode: **Write**, **Fix** or **Update**. Say which.

---

## Page types (one per page)

| Type                       | Reader's need     | Voice                     | Contains                                                 | Never contains                       |
| -------------------------- | ----------------- | ------------------------- | -------------------------------------------------------- | ------------------------------------ |
| **Overview / explanation** | Understand        | Impersonal, present tense | What, why, how parts relate, trade-offs, diagrams        | Step lists, exhaustive option tables |
| **Tutorial**               | Learn by doing    | "We"/"you", guided        | One safe path to a first result, with output shown       | Choices, theory, alternatives        |
| **How-to**                 | Get a task done   | Imperative                | Prerequisites, numbered steps, result, failure modes     | Background explanation (link it)     |
| **Reference**              | Look up a fact    | Impersonal, terse         | Every item, same shape, types/units/defaults/constraints | Instructions, rationale (link it)    |
| **Decision record**        | Know why it is so | Impersonal, past/present  | Context, options, decision, consequences                 | Implementation detail                |

Test a paragraph: is it about doing or knowing, learning or working? If the
answer is unclear it belongs on two pages. Move the stray part and link.

---

## Doc set (adapt to the system shape)

1. **README** — what it is, who it is for, 60-second start, links.
2. **Architecture overview** — see `references/page-templates.md`
   (context, building blocks, runtime flow, deployment, cross-cutting
   concerns, risks).
3. **Component pages** — one per component, same skeleton every time.
4. **How-tos** — set up the dev environment, build, run, test, debug,
   release, deploy, upgrade, back up, recover.
5. **Reference** — configuration, CLI, API, errors, data formats, ports,
   environment variables.
6. **Decision records** — one file per significant decision, immutable once
   accepted.
7. **Glossary** — one term per concept, used everywhere.

Only create what the system needs. Missing-by-design is stated in one line,
not left as a gap.

---

## Mode: Write

1. Read the code. List components, interfaces, configuration, runtime flow,
   deployment, external dependencies.
2. Choose pages from the doc set; assign each one reader and one type.
3. Write from the skeletons in `references/page-templates.md`.
4. Run the checks in `references/checks.md`.
5. **Execute every how-to** (or have the user run it) on a clean checkout
   or machine. A guide never run is a guess. Say which ones you did not
   execute.

## Mode: Fix

1. Run the checks; report findings first, grouped by level, each with what
   the reader suffers.
2. Fix: split mixed pages by type, shorten sentences, replace
   volatile identifiers with behaviour, add missing skeleton sections,
   unify terms, repair links.
3. **Never change facts.** If a fix needs knowledge you lack, leave
   `TODO(author): …` and list it. When docs and code disagree, report both
   and say which you believe and why; do not silently pick one.
4. Contradictions between pages (counts, names, paths, status codes) go in
   the report.

## Mode: Update

1. Take the change range: latest tag to `HEAD`, or a ref the user gives.
2. Turn the diff into **documentation-relevant changes**: new/removed/renamed
   component, interface, option, default, error, dependency, port, build
   step, deployment requirement. Pure refactors change no page.
3. Find affected pages through the `covers:` line of each page (see
   Staleness), then by searching docs for the old names. Edit only those.
4. Add pages for new components; mark pages of removed ones. A changed
   decision gets a _new_ record that supersedes the old one, never an edit.
5. Update the page's "verified" marker. Report: pages changed, added,
   removed, changes with no page home, `UNVERIFIED` items.

---

## Writing rules

### Language

- Present tense, active voice, plain declaratives.
- One idea per sentence; no chains of asides. A sentence the reader must
  read twice gets split.
- The **first sentence** of every page and section says what the thing is or
  does and its scope, in its own terms.
- One term per concept, from the glossary. No synonyms for variety. Prose
  in the doc language; keep English only for code, identifiers, protocol and
  product names, and established terms without a natural translation.
- "You/we" only in tutorials. Reference is impersonal.
- Cut filler, hedging, and marketing words. No "simply", "just", "easily".

### Facts

- Constraints inline where the item is described: type, unit, default,
  required or optional, allowed values, since-version, error on violation.
- Examples are minimal, realistic and runnable; show the output.
- State limits and security properties, including what is _not_ protected.
  Silence is not documentation.
- Rationale ("why") lives in a labelled section or decision record, linked
  from the place it matters.

### Procedures (how-to, tutorial)

- Numbered, imperative, one action per step. Prerequisites first. Split by
  sub-goal when the reader could lose their place.
- Every command is copy-pasteable: paths created before use, versions
  pinned, no secrets on the command line, working directory stated.
- After a step that changes state, show the expected output or check.
- Failure modes after the steps: symptom, cause, fix, cost of the fix.

### Diagrams

- Diagrams as code (Mermaid/PlantUML), versioned with the docs.
- One diagram, one question (context, structure, flow, deployment). Name the
  question in the caption. Split when it gets hard to follow.
- A diagram never replaces the sentence that states the point.

### Staleness resistance

Docs rot when they name things that change. So:

- Describe **behaviour and responsibilities**, not file names, function
  names or constants. Folder trees show layers and domains only.
- Link to the source of truth for volatile values (schema, config sample,
  OpenAPI file, lockfile) instead of copying them. Generate reference from
  source when a tool exists.
- Pin versions; never "latest".
- Each page ends with a `covers:` line listing the **directories or
  modules** it describes, and a `verified:` line with date or commit. Update
  mode uses these to find pages; humans use them to judge trust.
- Say each fact once; link to it elsewhere.
- If a component's detailed docs live in its own repo, say so at the top of
  the page.

### Navigation

- Index pages give one line per link.
- Each page lists what comes next and what it assumes.
- Sidebar order follows the reader's journey: overview → set up → tasks →
  reference → decisions.
- Headings are phrases a reader would search for.

---

## Reference material

- **`references/page-templates.md`** — skeletons: README, architecture
  overview, component page, how-to, reference entry, decision record,
  glossary. Read when writing or restructuring a page.
- **`references/checks.md`** — checks by severity: wrong or harmful, cannot
  use, will go stale or hard to read. Read in Fix mode and before finalising
  any mode.

---

## Quality checklist (before finalising)

- [ ] Mode stated; system shape, readers, conventions established
- [ ] Every page has one reader and one type; first sentence says what/why
- [ ] No level 1 finding left open
- [ ] Facts verified against code/config; the rest marked `UNVERIFIED`
- [ ] How-tos executed, or reported as not executed
- [ ] Constraints inline in reference; rationale linked, not mixed in
- [ ] No file names or volatile constants in explanation prose
- [ ] `covers:` and `verified:` present on every page
- [ ] One term per concept; glossary current
- [ ] Contradictions between pages and with code reported
- [ ] Links and anchors resolve
