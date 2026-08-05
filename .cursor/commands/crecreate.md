# Crecreate

Implement tests from a natural-language scenario.

## Input

User describes **what should happen** — not file paths or test API. Example:

> When a device becomes due, home shows it in reminders with a Due badge.

## Steps

1. Read [`.cursor/skills/crecreate/SKILL.md`](../skills/crecreate/SKILL.md).
2. Restate the scenario in Nasyad terms; pick test layer.
3. Read existing code + sibling tests; reuse helpers in `test/helpers/`.
4. Implement the smallest test that proves the scenario.
5. Run:

```bash
source tool/pub_env.sh && flutter test <path-or-name>
```

Fix until green. For PR-bound work, run `/verify-ci` after.
