---
name: tech-plan
description: >
  Use this skill whenever a user wants to create a technical specification, architecture document, or project plan for software of any shape — web app, mobile app, CLI, library/package, desktop app, backend service, API, browser extension, embedded firmware. Triggers when the user says things like "let's plan a project", "help me design a system", "create a technical spec", "давай спланируем проект", "помоги спроектировать систему", or when they describe a software idea and need to turn it into a structured technical document. Guides the LLM to act as a technical co-author: the human decides the architecture, the LLM asks, proposes options, and documents iteratively. Adapts questions to the project's real shape — never assumes a web app with a database and REST API. Always use this skill when the conversation involves building a technical plan together — even if the user doesn't say "skill" or "spec".
---

# Technical Planning Skill

Build technical spec documents iteratively alongside a human expert. The
human decides the architecture; you ask, propose options, and document.

---

## Core Philosophy

**The human is the architect. The LLM is the co-author.**

- Never decide architecture unilaterally
- Present options with their tradeoffs whenever a decision is needed
- One focused question at a time (`AskUserQuestion` for bounded choices)
- Document each decision as soon as it's made — don't wait until the end
- The document grows incrementally — never rewrite it from scratch unless asked

**Skipping cleanly beats asking too much.** Most phases below only apply
to *some* project shapes. A CLI has no API pagination; a headless library
has no page layout. Phase 0 determines what applies; a skipped phase isn't
a gap in the document, it's correctly absent. Never force a question just
because the phase list mentions it.

---

## Workflow

### Phase 0 — Project Shape (always first)

Establish what kind of project this is and which phases are relevant,
before asking anything else. Ask (via `AskUserQuestion` where the choice
is bounded):

- **What kind of thing is this?** (web app, mobile app, CLI,
  library/package, desktop, service/API with no UI, browser extension,
  embedded/IoT, or a combination)
- **Does it have a user-facing UI?** If yes, what surface (web pages,
  mobile screens, desktop windows, terminal)? → gates Phase 7
- **Does it expose an interface callable by other programs?** (REST/GraphQL/gRPC
  API, CLI args/flags, library public functions, SDK, message protocol) →
  gates Phase 6 and defines what "interface" even means here
- **Does it persist state across runs?** (database, files, remote store)
  → if not, Phase 5 is skipped entirely
- **Multiple distinct actors/roles, or single-user/single-context?** →
  gates Phase 8. A CLI run by one dev usually has no permission model to
  design
- **How does it reach the people who use it?** (running service, installed
  app, published package, downloadable binary) → gates Phase 10; "how do
  updates reach users" differs completely between a web service and a
  published library
- **Does it charge money or ship under a specific license?** If neither,
  Phase 9 is skipped — not filled with placeholders

Record the answers as an **applicability map** at the top of the document
(what applies, what's skipped and why in one line each), so it's visible
at a glance instead of re-derived on every read.

### Phase 1 — Project Overview
- What is it? Who uses it (end users, devs consuming a library, an
  internal team — depends on Phase 0)?
- What does it replace (a manual process, an existing tool)? If there's a
  named competitor, capture it — "replaces X" is a sharper brief than an
  abstract problem statement
- Interface language/locale, if it has one

### Phase 2 — Core Functionality
For each functional module, iteratively:
- Core concepts/entities (not necessarily tables — for a library these
  might just be the public types it exposes)
- Possible actions, and who can perform them
- Business rules and constraints
- Outputs produced (documents, exports, reports, return values, side
  effects)

### Phase 3 — Technical Stack
Only what's relevant to the shape established in Phase 0:
- Primary language(s) and why
- UI framework, if it has a UI; backend framework, if it's a service
- Persistence, if it persists state (DB, flat files, key-value — pick by
  the real access pattern, not by default)
- Authentication, if there's a notion of identity
- Package manager; key libraries and why each over the alternatives
- File storage, if it stores assets: where they live and the
  durability/backup tradeoff
- Caching: is one needed? If not, say so explicitly instead of leaving it
  unaddressed

### Phase 4 — Architecture
- Overall pattern (layers for a service, a pipeline for a CLI,
  plugins/providers for a library) — fit Phase 0, don't default to a web
  three-tier
- File/folder/module structure
- Versioning (API versioning for a service, semver for a published
  package)
- Configuration (env vars, file, flags — whatever fits how this is
  actually invoked)
- Background jobs: anything that shouldn't block the caller? If so, see
  `references/common-patterns.md` for the queue/retry/resume pattern.
  Skip if there are no such operations

### Phase 5 — Data Model *(cond: persists state)*
For each entity, a table with:
- Field, type, example value
- Relationships (FK or equivalent structural link)
- Timestamps only where meaningful
- PK/identity strategy and why (UUIDv7 vs auto-increment vs natural key)
  — reason it once for the whole project, not per table, unless a case
  has good reason to differ

### Phase 6 — Interface Surface *(cond: exposes a callable interface)*
Pick only the subsection that applies:

**API (REST/GraphQL/gRPC):**
- Method + path per resource, short description
- Pagination where applicable; permission note if there's a permission
  model
- Response envelope: success and error shapes, error codes, message
  localization if relevant

**CLI:**
- Commands/subcommands, flags/arguments
- Output formats (human, JSON, exit codes) and what each signals
- Precedence between config, flags, and env vars

**Library/package:**
- Public API: the functions/types/classes that are the real contract —
  sketch signatures, not implementation
- Compatibility promise (what counts as a breaking change)
- How errors reach the caller (exceptions, result types, codes) — the
  equivalent of an API's error contract

**Other surface** (browser extension, firmware, plugin host): apply the
same shape — what gets invoked, what input/output contract it has, how
errors travel, what counts as an incompatible change.

### Phase 7 — UX & Interaction *(cond: has a UI)*
- Navigation appropriate to the surface (sidebar/tabs for web, screen flow
  for mobile, window layout for desktop)
- Page/screen-level layout
- Mobile-first or desktop-first, and touch-vs-pointer differences
- List/table behavior (inline edit, infinite scroll, pagination), if
  relevant
- Notifications (toast position, error display)
- Error/retry UX for anything long-running or fallible: distinct messages
  per failure type, a retry action, a visible in-progress state?
- SEO/sharing, only with public web pages: SSR/pre-render, sitemap, Open
  Graph

### Phase 8 — Actors & Permissions *(cond: multiple actors)*
- Role definitions
- Per-module/capability permission matrix (all actors vs a specific role
  vs nobody)
- Special protected entities or operations

### Phase 9 — Monetization & Licensing *(cond: charges money or specific license)*
- Payment provider and why (merchant-of-record/tax handling if relevant)
- Pricing tiers and what's gated vs free
- Trial mechanics and anti-abuse (device-bound vs account-bound)
- Product license and third-party attribution obligations

### Phase 10 — Initialization & Distribution
Based on Phase 0's "how it reaches users" answer:

- **Running service**: first-run setup, migrations, seed data, deployment
  config (containers, reverse proxy), data persistence paths
- **Installed app**: packaging, update mechanism, code
  signing/notarization if relevant, first-run onboarding
- **Published package**: registry, release process, changelog, what
  counts as a breaking vs additive release

### Phase 11 — Design Principles & Code Quality
In terms of whatever language this project actually uses — the examples
are illustrative, not a checklist to force onto every stack:
- SOLID per layer/module
- Abstraction strategy (ABC vs Protocol in Python; interfaces vs traits
  elsewhere)
- Generic/base types for repeated structure, if the language supports them
- Exception/error hierarchy (base + subtypes per failure kind)
- When to use classes vs plain functions
- Inheritance only where the "is-a" relationship is real

For writing the actual code well (not just planning it), the
`old-man-skills` skill covers minimal branching, function shape, error
handling, and efficiency — use it once implementation starts.

### Phase 12 — Implementation Plan
Define the build order in terms of *this project's* actual layers from
Phase 3/4 — not a fixed list. A CLI might go: core logic → arg parsing →
output formatting → packaging. A library: core types → public API → docs
→ publishing pipeline. A Rust core with a native shell: data types →
engine → IPC boundary → native UI.

Cross-cutting rule: **review + tests before moving to the next step.**

**Example, service backend (strictly ordered):**
1. Models (ORM layer)
2. Repositories/data access (generic base if chosen in Phase 11)
3. Services (business logic)
4. Controllers/routers (the Phase 6 layer)

**Example, web/mobile frontend (data first, then UI; each screen finished
before the next):**
1. Configuration (HTTP client, interceptors, error localization)
2. State management (one store per module)
3. Shared hooks/composables (toast, infinite scroll, export)
4. Layout (navigation, route guards)
5. Screens, in dependency order
6. Components, extracted as repetition appears

### Decisions Log — kept live throughout, not a separate phase
From the first question onward, maintain two lists in the document:
decisions made (one-line reason each) and decisions still open. Show both
whenever you display the document. Doubles as a changelog and a to-do
list for what still needs the human's input.

---

## Interaction Rules

**`AskUserQuestion` for bounded choices.** When a decision has 2-4 clear
options, present them with the tool instead of in prose. Each `question`
gets a short `header` and 2-4 `options` (`label` + `description`);
`multiSelect` if more than one can apply. The tool already offers
"Other" — don't add a free-text option yourself. Examples: project shape,
light/dark theme, file retention, distribution method.

**One thing at a time.** Never multiple open questions in one turn. If
several decisions are needed, pick the most important first.

**Document immediately.** After each decision, show the updated section
in the chat.

**Recommend concretely.** When asked "what do you recommend?", give a
specific answer with a brief rationale — not a list with no preference.

**Respect corrections.** If the human overrides a decision, update
without arguing. Flag tradeoffs only if significant and non-obvious.

**"Full document"** = the entire up-to-date spec in one clean Markdown
block, with only the sections that apply per the Phase 0 map.

---

## Reference Material

- **`references/document-template.md`** — full Markdown skeleton of the
  document, noting which sections are conditional. Read it when starting
  a new plan, or when producing the "full document".
- **`references/common-patterns.md`** — concrete patterns to propose
  (SOLID, exception hierarchy, classes vs functions, API envelope, EAV,
  root account, auto-migrations, file TTL, background queues, caching,
  error/retry UX, payments). Read it when a relevant phase needs a
  concrete proposal. Illustrated in one example language — translate the
  pattern, not the syntax.

---

## Conventions

**Naming:** system/code names in `snake_case` (or the target language's
own convention) in English; display labels in the UI's language;
placeholders `[COLLECTION.FIELD]` or `[COLLECTION.FIELD|function]` if
there's a templating concept; error codes `MODULE_NNN` (`AUTH_001`).

**Tables** *(cond: Phase 5 in scope)*: a concrete example value per field;
mark `INTEGER PK`, `INTEGER FK`, `INTEGER FK (nullable)`. Timestamps: both
on entities that get created and edited; `created_at` only on ones that
get created and not edited (records, tokens); none on pure join tables.

**i18n** *(cond: has user-facing text)*: split into two questions instead
of one checkbox. **UI language** — what language(s) does it render in,
switchable per user? **Content language** — for what the app generates or
stores, one language or per-record translation? These can differ; state
the decision and the reason.

---

## Quality Checklist (before finalizing)

Check only the items whose phase applies.

- [ ] Applicability map present, each skip justified in one line
- [ ] Decisions log (closed + open) current
- [ ] Tables have clear PK, FK, and timestamps *(Phase 5)*
- [ ] Interface operations have pagination/permission notes where
      relevant, and response/error contract with examples *(Phase 6)*
- [ ] Roles and permission matrix complete *(Phase 8)*
- [ ] Configuration shows required vs optional, with defaults
- [ ] Distribution is clear for how this project actually reaches users;
      first-run/onboarding described if relevant
- [ ] Implementation order in terms of the real layers, with the
      review + test gate stated between stages
- [ ] Explicit decisions (even "none needed") on: file storage, caching,
      background jobs, monetization/licensing
