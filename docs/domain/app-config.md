# App config (remote feature flags)

Server-provided capability map the client applies for gradual rollout / A/B. Local-first: the app never blocks on this; defaults live on device until a successful fetch.

## Rules

| Rule | Where |
|------|-------|
| Client ships **safe local defaults** (unknown / unset keys → `false`) and works offline with no server | client |
| Client **caches** the last successful evaluated config and uses it until a newer fetch succeeds | client |
| Fetch failures (offline, 5xx, timeout) keep last-known cache; if none, keep local defaults — never crash or block launch | client |
| Server exposes `GET /api/app_config/` returning an evaluated `features` map of string keys → bool | server |
| Endpoint is **AllowAny**; optional Token auth personalizes sticky cohorts for signed-in users | both |
| JSON is additive `snake_case`; clients ignore unknown top-level fields and unknown feature keys | both |
| Master kill switch: flag `is_enabled=false` → evaluated `false` for everyone | server |
| Rollout: when `is_enabled=true`, authenticated users are sticky via stable hash of `(user_id, key)` against `rollout_percent` (0–100) | server |
| Anonymous / unauthenticated requests: flag is `true` only when `is_enabled` and `rollout_percent >= 100`; otherwise `false` | server |
| Config is **not** user domain data — not synced via Drift entity sync; not part of export/import | both |

## Wire (`GET /api/app_config/`)

Auth: optional `Authorization: Token <token>`.

```json
{
  "updated_at": "2026-08-08T12:00:00Z",
  "features": {
    "example_remote_flag": false
  }
}
```

| Field | Type | Notes |
|-------|------|-------|
| `updated_at` | ISO 8601 UTC | Server clock at evaluation time (or latest flag row change — implementations may use either; clients treat as opaque freshness) |
| `features` | object string→bool | Evaluated for this caller; missing key on client → local default `false` |

## Server control plane

| Field | Meaning |
|-------|---------|
| `key` | Stable snake_case flag id (e.g. `example_remote_flag`) |
| `description` | Admin-facing note |
| `is_enabled` | Kill switch |
| `rollout_percent` | 0–100; sticky cohort when authenticated |

Admin (Django admin) is enough for v1 — no end-user UI.

## Client cache

Preference-store JSON (not Drift): last `features` map + `fetched_at`. Read path is sync from cache; refresh is best-effort in background after session restore / when online.

## Example flag

`example_remote_flag` — plumbing proof only; default evaluated `false`. Product screens must not depend on it until a real gated feature opts in.

Index: [../domain.md](../domain.md)
