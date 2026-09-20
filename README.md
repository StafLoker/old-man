<div align="center">
   <h1><b>Old Man Skills</b></h1>
   <p><i>~ Write code like a senior who's been woken at 3am by someone else's clever code ~</i></p>
   <p align="center">
      <a href="https://github.com/StafLoker/old-man/releases">Releases</a>
   </p>
</div>

<div align="center">
   <a href="https://github.com/StafLoker/old-man/blob/main/LICENSE"><img src="https://img.shields.io/github/license/StafLoker/old-man.svg?style=flat" alt="license"/></a>

   <p>A collection of agent skills for disciplined, no-nonsense software engineering.</p>
</div>

# Skills

- **[old-man](skills/old-man/SKILL.md)** — enforces old-school senior-dev code discipline while writing any code: few exit points, explicit loop conditions, no hidden global state, differentiated error types, deterministic resource cleanup, minimal comments, no premature abstraction. Meant to trigger automatically whenever the agent is about to write code, in any language.
- **[tech-plan](skills/tech-plan/SKILL.md)** — turns a conversation into a collaborative technical specification / architecture document. You make the decisions, the agent asks focused questions, proposes options, and writes the spec incrementally. Adapts to the project's shape (web app, CLI, library, service, etc.) instead of forcing a generic template.

Each skill is self-contained: a `SKILL.md` with the instructions/description, plus a `references/` folder with extra material the agent reads as needed (language-specific guidance, templates, patterns).

# Installation

How you install a skill depends on which agent/tool you use. In general: clone this repo, then point your tool at the skill folder(s) you want.

## Claude Code

Skills load from `~/.claude/skills/` (all projects) or `.claude/skills/` (one project).

```bash
# whole repo, all skills available everywhere
git clone git@github.com:StafLoker/old-man.git ~/.claude/skills/old-man-skills

# or just one skill (symlink to keep it updatable via git pull)
git clone git@github.com:StafLoker/old-man.git /tmp/old-man-skills
ln -s /tmp/old-man-skills/skills/old-man ~/.claude/skills/old-man
```

For project-only scope, put a skill under `.claude/skills/` at the root of that project instead.

## Other agents / tools

Clone the repo and copy or symlink the skill folder(s) into wherever your tool looks for custom instructions/skills/rules. Each `SKILL.md` is plain Markdown with a YAML frontmatter (`name`, `description`) — read that file directly, or paste its contents into a system prompt / project rules file, if your tool has no dedicated skills mechanism.

```bash
git clone git@github.com:StafLoker/old-man.git
```

# Usage

Skills with a broad `description` (like `old-man`) are meant to trigger automatically when the task matches — no need to invoke them by name. Skills meant to be started explicitly (like `tech-plan`) get invoked by asking for what they do, e.g. *"let's plan a project"* / *"help me design a system"*.

# Updating

```bash
cd ~/.claude/skills/old-man-skills   # or wherever you cloned it
git pull
```

# License

See [LICENSE](LICENSE).
