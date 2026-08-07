# Verify

Local CI — mandatory before any PR claim (shared delivery rule).

```bash
./tool/ci_verify.sh                        # client + server (always)
```

Must exit **0**. On failure: fix → re-run until green; never skip because a subset looked fine.

Optional: copy `env.example/` → `.env/` and run `./tool/env_apply.sh` so version/signing match your local control plane.

Release-tag variant: `./tool/ci_verify.sh --tag vX.Y.Z`.
