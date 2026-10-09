# Page templates — technical docs

Skeletons, not forms. Skip a section that has no content for this system
and say so in one line if the absence is not obvious. Keep the order.

---

## README

```
# <Name>
One sentence: what it is and what problem it solves. Who it is for.

## Quick start      (shortest path to a visible result, copy-pasteable)
## Requirements     (platforms, runtime versions)
## Documentation    (one line per link)
## Contributing / License
```

## Architecture overview

Fits arc42 in short form. One page, or one page per section if large.

```
# Architecture
One paragraph: what the system does and its main shape.

## Context and scope        who/what it talks to; diagram (system + neighbours)
## Building blocks          components and their responsibilities; diagram
## Runtime flow             1-3 key scenarios end to end; sequence diagram
## Deployment               where each block runs, networks, storage
## Cross-cutting concerns   auth, logging, errors, config, i18n, security limits
## Decisions                links to decision records
## Risks and limits         known weak points, scale limits, tech debt
## Glossary                 link
```

## Component page

Same section order for every component. Project-specific templates win.

```
# <Component>
(optional notice: detailed docs live in <repo>; this page may lag)

## Role            what it does in the system, which problem it solves
## Language / version / platform
## Architecture    pattern + diagram of its internal structure
## Layout          layers/domains only; no file names
## Configuration   mechanism (file, env, flags) + link to reference
## Dependencies    table: name, version, why
## Interfaces      what it exposes and what it consumes
## Contents        one line per sub-page
covers: <directories/modules>   verified: <date or commit>
```

## How-to

```
# <Verb> <object>
One sentence: the task, and who does it.

## Before you begin     requirements, versions, rights
## Steps                numbered, one action, copy-pasteable
## Check                expected output or observable state
## If it fails          symptom → cause → fix → cost of the fix
## See also
covers: …   verified: …
```

## Tutorial

```
# <Learn X by building Y>
What you will build and what you will know afterwards. Time.

## Prerequisites
## Step-by-step (each step: do, then show the output)
## What you built
## Where next
```
One path. No options, no digressions; link them.

## Reference entry

Every entry has the same shape so readers can scan.

```
### `name`
One sentence: what it is.
- Type / unit:
- Default:
- Required: yes/no
- Allowed values / constraints:
- Since: version
- Errors: what happens when violated
Example (minimal, realistic) with output.
```
For APIs add: method and path, auth, request, response, error codes. For CLI
add: synopsis, options, exit codes, examples. For libraries add: signature,
parameters, returns, raises, complexity if relevant.

## Decision record (ADR / MADR)

One file per decision, numbered, immutable once accepted. Supersede with a
new record.

```
# NNNN. <Decision as a short phrase>
Status: proposed | accepted | superseded by NNNN | deprecated
Date:

## Context       forces at play, constraints, what must be decided
## Options       2-4, each with pros and cons
## Decision      what was chosen and the main reason
## Consequences  good, bad, follow-ups
```

## Glossary

```
**Term** — one-sentence definition. Not: banned variants.
```
Alphabetical. One entry per concept; every doc set in the project uses
exactly these terms.

## Operations (deployment, upgrade, backup, recovery)

How-to pages, plus:
- A table of ports, volumes, users and secrets (names only, never values).
- Upgrade: order of steps, migration notes, rollback.
- Backup/restore: what is saved, how to verify a restore.
- Health: how to tell it works (command and expected output), where the
  logs are.
