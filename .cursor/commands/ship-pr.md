# Ship PR

Commit, push, and open a PR. Precondition: `/verify` green. Full git gates: `.cursor/rules/shared/delivery.mdc`.

1. In parallel: `git status`, `git diff`, `git log -5 --oneline`.
2. Stage relevant files only — never secrets. Commit via HEREDOC, why over what, no hook skipping.
3. `git push -u origin HEAD` (never force-push main).
4. `gh pr create` with Summary + Test plan body; return the PR URL.
