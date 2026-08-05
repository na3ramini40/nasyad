# Ship PR

Git delivery after green CI. Read [`.cursor/rules/git-delivery.mdc`](../rules/git-delivery.mdc).

**Precondition:** `./tool/ci_verify.sh` exit 0 (run `/verify-ci` first).

## Commit (when user asks to ship or invoked from `/deliver-feature`)

Run in parallel:

```bash
git status
git diff
git log -5 --oneline
```

- Stage relevant files only; never commit secrets.
- Message: why > what; match repo style.
- Commit via HEREDOC; do not skip hooks.

## Push

```bash
git push -u origin HEAD   # when branch not tracking remote
```

Do not force-push `main`/`master`.

## Pull request

Only after green CI:

```bash
gh pr create --title "…" --body "$(cat <<'EOF'
## Summary
…

## Test plan
- [ ] …
EOF
)"
```

Return PR URL when done.
