# Asset templates

## Rule — `.cursor/rules/<group>/<name>.mdc`

```markdown
---
description: <one line — what this gate enforces>
alwaysApply: false         # shared gates are off by default — add a row to the
                           # AGENTS.md trigger table so agents know when to read it
# one-sided gates use globs instead:
# globs: client/**
---

# <Title>

- <imperative gate — always/never, with the exact command or path>
- <second gate>
```

## Skill — `.cursor/skills/<group>/<name>/SKILL.md`

```markdown
---
name: <lowercase-hyphens>
description: >-
  <WHAT it covers>. Use when <trigger scenarios and terms the user would say>.
---

# <Title>

<Essential knowledge only — the agent is smart; add what it cannot know.>

## Shards — read the one you touch     # only if the skill outgrows 60 lines
| Topic | File |
|-------|------|
| <topic> | [<file>.md](<file>.md) |
```

## Command — `.cursor/commands/<name>.md`

```markdown
# <Verb phrase>

<Precondition if any. Link the governing rule instead of restating it.>

1. <step with exact command>
2. <step>
```

## Agent — `.cursor/agents/<name>.md`

```markdown
---
name: <name>
description: >-
  <Role in one sentence>. Use for <delegation trigger>.
---

You <role>. Primary knowledge: <skill path>. Gates: <rule paths>.

## Do
- <focused responsibilities>

## Don't
- <boundaries — e.g. never commits; defers X to Y>
```
