---
name: fdm-meta
description: >-
  How Feature Delivery Manager routes stakeholder policies and maintains
  .cursor assets. Use when the user changes do/don't/always/never rules, adds
  skills, or updates the delivery roster.
---

# FDM meta — routing and maintenance

## Stakeholder routing

| Signal | Land in | Action |
|--------|---------|--------|
| Always/never before PR, push, tag | `.cursor/rules/*.mdc` | Create/update rule; `alwaysApply: true` when global |
| New/changed screen, section, nav | `nasyad-product/app-map.md` | Update in same delivery |
| UX feel, copy, calendar tone | `nasyad-ux/` + `end-user.md` | Durable facts → `end-user.md` |
| Architecture, Drift, stack | `nasyad-flutter/` and/or `docs/AGENTS.md` | Do not bury in FDM agent |
| Widgets, theme, a11y | `nasyad-ui/` | Update skill shards |
| Orchestration sequence | `agents/feature-delivery-manager.md` | Patch core only when role changes |
| One-off for this task | Session plan | Do not write a rule |

Prefer durable updates over obeying once in chat. Report: *what changed, where, why* (one line).

## Adding or updating assets

1. Create file under `.cursor/skills/`, `.cursor/rules/`, or `.cursor/commands/`.
2. Keep instruction files ≤ **60 lines**; split into reference shards if needed.
3. Every skill needs YAML `name` + rich `description` for discovery.
4. Add row to [`fdm-roster/roster.md`](../fdm-roster/roster.md).
5. Run `wc -l` on changed instruction files before closing.

## Updating FDM agent

Edit `agents/feature-delivery-manager.md` only when orchestration role changes — not for routine delivery tweaks (those go to roster, commands, or rules).

## Roster vs disk

`roster.md` is authoritative. Scan `.cursor/skills/*/SKILL.md` and `.cursor/rules/*.mdc` to detect drift; fix roster — do not invent parallel routing.

## Missing asset

Skip phase with one-line note; offer to create the asset. Do not invent skill content inline.
