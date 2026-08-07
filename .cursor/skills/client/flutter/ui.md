# UI composition & a11y

Build bottom-up with Atomic levels; keep pages thin (layout + bloc wiring).

| Level | Where |
|-------|-------|
| Atoms/molecules shared by 2+ features | `lib/core/ui/` (tokens from `lib/core/theme/`) |
| Feature-only widgets | `lib/presentation/<feature>/widgets/` |
| Pages | `lib/presentation/<feature>/pages/` |

## Component API rules

- Minimal inputs — derive from `Theme`, never scattered color/TextStyle literals.
- Variants as enums/sealed types (`AppButtonVariant.primary`), not boolean soup.
- Extend via composition and slots (`Widget? leading`), not inheritance or prop explosion.
- No BLoC/domain types in leaf atoms — pass presentational values.
- Search `core/ui/` for reuse before building; extract there when a second feature needs it.

## Every screen

- Explicit loading / empty / error states; one obvious primary action.
- RTL-safe: `EdgeInsetsDirectional` or symmetric padding, never direction-blind `only(left:)`.

## a11y checklist

Semantics labels on icon-only controls · 48dp tap targets · contrast · text scaling survives · sensible focus order on forms.
