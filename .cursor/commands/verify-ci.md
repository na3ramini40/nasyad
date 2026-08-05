# Verify CI

Run local Verify before any GitHub PR/MR, push meant for an open PR, or “PR ready” claim.

```bash
./tool/ci_verify.sh
```

Sources `tool/pub_env.sh` (Runflare mirror — local only) and `tool/check_no_release_secrets.sh` automatically. GitHub CI uses default `pub.dev` hosts.

Must exit **0**. On failure: fix → re-run until green.

Release-tag check (when tagging `vX.Y.Z`):

```bash
./tool/ci_verify.sh --tag vX.Y.Z
```

Authoritative rule: [`.cursor/rules/ci-before-pr.mdc`](../rules/ci-before-pr.mdc).

Do **not** skip because analyze alone looked fine or only a subset of checks ran.
