# Page templates — user manual

Skeletons, not forms. Drop a section when it has no content; never fill it
with filler. Keep the order.

---

## Start here

```
# <Product>
One sentence: what it does and for whom.

## Before you begin
- What you need (OS, account, rights, network access)

## Choose your path
- First time → Quick start
- Upgrading → Upgrade
- Something is wrong → Troubleshooting
```

Under 150 words. Links only; no feature tour.

## Quick start

```
# Quick start
Goal in one sentence. Time needed.

## Before you begin
## Steps            (numbered, happy path only)
## Result           (what you should see)
## Next             (3 links at most)
```

No settings, no theory, no branches except platform differences, declared
before step 1.

## Task page

```
# <Verb> <object>            e.g. "Create a flow"
One sentence: what you achieve and who needs it.

## Before you begin
- Requirements, with links to how to meet each

## Steps
1. Imperative, one action.
   Result line (unnumbered) when something observable happens.
2. ...

## If it does not work
- Symptom → cheapest fix → link to Troubleshooting

## Related
- Next task, reference page
```

If the page needs more than 7 steps, split into sub-procedures with
headings. If it needs a concept explained, link a short explanation page; do
not embed it.

## Install / upgrade / uninstall

One page each, same skeleton as a task page, plus:
- Install: supported platforms and versions, where to get the file (named
  source and checksum if offered), first-run check ("Run `x --version`; it
  prints …").
- Upgrade: what is kept, what changes, how to back up first, how to roll back.
- Uninstall: what is removed, what is left behind (data, config) and how to
  remove it.

## Reference

Tables, alphabetical or in the order they appear on screen:

```
| Setting | What it does | Values | Default |
```
Also: shortcuts, limits (max sizes, counts), file formats, error messages.
No procedures; link to the task page that uses each item.

## Troubleshooting

Headings are symptoms in the user's words ("The robot does not start"), not
causes.

```
## <Symptom>
Cause (one line, if the user can recognise it).
1. Cheapest fix first.
2. Next fix.
3. Drastic fix — state what is lost ("deletes local drafts").
Still failing? <where to get help, what to send>
```

## FAQ

Questions as users ask them. Answer in 1-3 sentences, link out for more.
Only questions that really recur; otherwise it belongs in a task page.

## Glossary

```
**Term** — one-sentence definition in plain words. Not: synonyms, internals.
```
Alphabetical. Lists the banned variants once ("not: step, stage"), so
authors and reviewers can grep for them.

## Security and legal

Separate page, never mixed into steps. Data handling, permissions the
software needs, what is stored and where. Order by severity.
Contact, licence, regulatory text last.
