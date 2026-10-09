---
description: Add a CHANGELOG.md entry for a version, built from git changes since the last tag
argument-hint: <version> [since-ref]
allowed-tools: Bash(git tag:*), Bash(git log:*), Bash(git diff:*), Bash(git describe:*), Bash(git rev-list:*), Bash(date:*), Read, Edit, Write
---

Add the changelog entry for version `$1` to `CHANGELOG.md` at the repo root.

## 1. Find the range

- If `$2` is given, it is the start ref (tag or commit).
- Otherwise start = `git describe --tags --abbrev=0` (latest tag).
- If the repo has no tags or `CHANGELOG.md` has no version section yet, this is the first version: use the whole history (`git rev-list --max-parents=0 HEAD` as start) and list the features that exist, not every commit.
- Range end = `HEAD`. If `$1` is already a tag, end = that tag and start = the tag before it.

Read `git log <start>..<end>` (subjects and bodies) and `git diff --stat <start>..<end>`. Open the diff of a file only when a commit message is too vague to describe the change.

## 2. Match the existing file

If `CHANGELOG.md` exists, read it first and copy its language, heading text, section names, bullet style and tone. If it does not exist, create it with the header below (Keep a Changelog + SemVer, in the language of the README, English if unsure).

```markdown
# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
```

Entry format, newest on top, directly under the header:

```markdown
## [$1] - YYYY-MM-DD

### Added
- ...

### Changed
- ...

### Fixed
- ...
```

- Date: today (`date +%F`).
- Use only the sections that have content, in this order: Added, Changed, Deprecated, Removed, Fixed, Security. Translate the names if the file is not English (e.g. Добавлено, Изменено, Удалено, Исправлено).
- A one-line summary sentence under the heading is allowed when the release has a single theme.

## 3. Write the bullets

- Describe the user-visible effect, not the commit: what changed and why it matters. Group related commits into one bullet.
- Name endpoints, flags, config keys and commands in backticks.
- Skip noise: version bumps, merge commits, typo/format-only commits, CI tweaks, README edits, and the changelog itself. Keep a CI or docs change only if users of the project notice it.
- Describe the net change versus the previous release, as a reader of that release sees it. Never narrate the path between: if a feature was added and later fixed or reworked inside the range, it is one `Added` bullet in its final form, with no `Fixed` bullet for it. A change that was reverted inside the range does not appear.
- Do not mention earlier versions or earlier behaviour by name ("since 1.1.0", "previously X was added"). Say what is different now; state the old behaviour only when the reader needs it to see the change (e.g. "filenames now keep the original name instead of a UUID").
- Never invent a change the git history does not show. Unsure about a commit: ask instead of guessing.
- First version: one `### Added` list of the capabilities of the project, not a commit replay.

## 4. Finish

Insert the entry, do not touch older entries, do not commit. Show the final entry and the range used (`<start>..<end>`).
