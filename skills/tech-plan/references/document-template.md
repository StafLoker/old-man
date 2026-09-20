# Document Structure Template

An initial skeleton, not a fixed form. *(conditional)* sections only
appear if Phase 0 marked them relevant — a CLI or library genuinely have
fewer sections than a multi-tenant web app, and that's not an incomplete
document. `[bracketed]` text is an example, not a mandatory heading:
swap it for whatever this project's actual stack is. Add, rename, split,
or remove sections as needed.

The order follows the phases: context → what it does → with what → how
it's built → contracts → how it's built out.

```markdown
# [Project Name]

[One-line description]

## Project Shape
[Type — web app / CLI / library / desktop / service / etc.]
[Applicability map: which sections apply, and a one-line reason per skip]

## Purpose
[What it does and what it replaces]

## Core Functionality
### [Module 1]
### [Module 2]

## Use Cases (conditional — multiple actors/roles)
### [Role/Module]
- [action] — [who]

## Technical Stack

## Dependency Management
[One subsection per real component — Frontend/Backend for a web app, a
single list for a single-language CLI or library]

## Architecture
### Pattern
### File/Module Structure
### Startup Initialization
### Background & Async Work (conditional)
### Caching (conditional)

## Configuration
### Environment / config file / flags — whatever this project actually uses
### [Reverse proxy / web server, if deployment needs one — nginx, Caddy, Traefik]

## Data Model (conditional — persists state)
**PK/identity strategy:** [e.g. UUIDv7 across all tables — reason]

**Table/structure `name`**
| Field | Type | Example |
|-------|------|---------|

## Interface Surface (conditional — shape depends on Phase 0)
[Pick the sub-shape that applies:]

### If it's an API
#### Response/Error Contract
#### Endpoints
##### [Resource]

### If it's a CLI
#### Commands and Flags
#### Output Formats and Exit Codes

### If it's a library/package
#### Public API Surface
#### Versioning and Compatibility Promise

## UX & Interaction (conditional — has a user-facing UI)
### Overall layout (mobile-first or desktop-first, if applicable)
### Pages / Screens
### Tables / Lists
### Notifications
### Error and retry UX

## Monetization & Licensing (conditional — charges money or has a license to document)
### Pricing and paywall boundary
### Trial mechanics and anti-abuse
### Product license

## Distribution & Initialization
[Shape depends on how it reaches users — running service, installed app,
or published package each need a different subset: first-run setup,
migrations, packaging/signing, registry and release process. See SKILL.md
Phase 10.]

## Design Principles
### SOLID
### Abstractions & Interfaces
### Generics
### Inheritance
### Exceptions
### [Language notes — "Python specifics" for a Python backend, "Rust
specifics" for a Rust core, whatever the stack is]

## Implementation Plan
[Stages ordered in terms of this project's real layers — see SKILL.md
Phase 12. Review + test gate between stages.]

## Decisions Log
### Closed
| Decision | Reason |
|----------|--------|
### Open
- [question that still needs the human's input]
```
