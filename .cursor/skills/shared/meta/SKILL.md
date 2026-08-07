---
name: cursor-assets
description: >-
  Governs creating and maintaining every asset in this repo's .cursor folder —
  rules, skills, agents, and commands. Use whenever the user states a durable
  do/don't/always/never policy, asks to add or change a rule, skill, agent, or
  command, or the .cursor structure needs updating.
---

# .cursor asset governance

Every rule, skill, agent, and command in this repo is created through this skill. Structure is fixed by Cursor's discovery:

```text
.cursor/rules/{shared,client,server}/*.mdc     # gates — OFF by default; client/server attach via globs
.cursor/skills/{shared,client,server}/<name>/  # knowledge — loaded on demand via description
.cursor/agents/*.md                            # flat, required by Cursor
.cursor/commands/*.md                          # flat, required by Cursor
```

**Off-by-default policy:** shared rules use `alwaysApply: false`; root `AGENTS.md` is the always-present router and agents decide what to read. A new shared rule must get a row in the `AGENTS.md` "Before you… / Read" table, or it will never load. Sole exceptions — `delivery.mdc` and `security.mdc` stay `alwaysApply: true` because they guard irreversible mistakes (secrets, git); do not add more always-on rules without the owner's sign-off.

## Decision: which asset type?

| The new thing is… | Create |
|-------------------|--------|
| A hard gate (always/never before PR, git, secrets, release) | **Rule** — `rules/shared/`, or `rules/client|server/` with globs if one-sided |
| Knowledge the agent needs on demand (how a subsystem works, patterns, checklists) | **Skill** — or, usually better, a shard inside an existing skill |
| A repeatable user-invoked workflow with steps | **Command** |
| A genuinely distinct role needing its own context and delegation | **Agent** — rare; extend a skill first |
| A one-off instruction for the current task | **Nothing** — session only |

Living product data goes in the existing files: screens → `shared/product/app-map.md`, persona facts → `shared/product/end-user.md`.

## Creation checklist (all asset types)

1. **No duplication** — grep `.cursor/` first; one fact lives in exactly one file, others link to it.
2. **Right home** — shared vs client vs server by who needs it, not where it was mentioned.
3. **Short** — rules ≤30 lines; SKILL.md ≤60 lines, split into shards (one level deep) past that; commands ≤15 lines.
4. **Frontmatter** — rules need `description` + `alwaysApply: false` (shared) or `globs:` (client/server); skills need `name` (lowercase-hyphens) + third-person `description` stating WHAT it does and WHEN to use it (the description alone triggers loading — include trigger terms).
5. **Index** — update root `AGENTS.md`: the contents table, and the trigger→rule routing table for shared rules.
6. **Report** — one line: what changed, where, why.

Copy-paste templates for each asset type: [templates.md](templates.md).

## Maintenance

- Prefer a durable `.cursor` update over obeying a stated policy once in chat.
- When editing, keep terminology consistent with existing files; fix stale cross-links you encounter.
- Deleting an asset: remove the file, its `AGENTS.md` row, and every link to it.
