# Components and Atomic Design

## Mapping

| Level | Examples | Flutter |
|-------|----------|---------|
| Atoms | buttons, badges, fields, spacers | `lib/core/theme/` tokens; `lib/core/ui/` |
| Molecules | label+field, list tiles, chip groups | `core/ui` if shared |
| Organisms | forms, device lists, app bars | feature sections |
| Templates | scaffold + slots | `AppPageScaffold`, `AppContent` |
| Pages | routed screens | `presentation/<feature>/pages/` |

## API rules

1. **Minimal inputs** — derive from `Theme` when possible.
2. **Default-first** — `const` constructors; sensible optional params.
3. **Variants** — enums/sealed types (`AppButtonVariant.primary`), not boolean soup.
4. **Open/Closed** — extend via composition, slots (`Widget? leading`), wrappers.
5. **Composition over inheritance** for layout flexibility.

## Design system

- Read colors, type, spacing from `ThemeData` — not scattered literals.
- Extend component themes over one-off `TextStyle` copies.
- Feature pages assemble organisms; they do not redefine atom styles.

## a11y checklist

- Semantics labels on icon-only controls
- Contrast and minimum tap targets (48dp)
- Support text scaling / large fonts
- Focus order on forms

## Anti-patterns

- Boolean prop explosion (`isPrimary`, `isLarge`, `isDense`…)
- Rewriting large widgets instead of composing
- Leaking BLoC/state into leaf atoms
- Aspirational folders without `docs/AGENTS.md` update

## Tests

Add widget tests when component behavior is non-trivial.
