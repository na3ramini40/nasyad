# User (account & profile)

Online account identity. Optional — local-first use needs no account ([principles.md](principles.md), [local.md](local.md)).

## Profile fields (wire)

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | Server-issued unique **public hash** (read-only). Not the Django numeric PK. Shown on profile; clients never invent or edit it. |
| `phone` | string | E.164 preferred (e.g. `+98912…`). Unique. Sign-in identifier. |
| `name` | string \| null | Display name; editable. Empty/null allowed until set. |
| `image_url` | string \| null | Profile image URL after upload; null if none. Editable via multipart upload. |
| `created_at` | datetime | ISO 8601 UTC |
| `updated_at` | datetime | ISO 8601 UTC |

## Device registration (push / client install)

One **authenticated user** (phone) may have several physical installs. Each install has a stable client-generated `device_id` and the latest FCM token for that install. Rows are keyed by `(user, device_id)` — not a single last-writer-wins token on the user. Schema is extensible: more per-install fields may be added later without redesign.

| Field | Type | Notes |
|-------|------|-------|
| `device_id` | string | Client-generated stable install id (opaque, ≤64 chars). Persisted locally for the life of the install. |
| `fcm_token` | string | Current Firebase Cloud Messaging token for this install. |
| `created_at` | datetime | ISO 8601 UTC |
| `updated_at` | datetime | ISO 8601 UTC |

Do not confuse with product **Device** entities (tracked assets) under [device.md](device.md).

## Auth (phone OTP)

| Field / concept | Notes |
|-----------------|-------|
| `phone` | Same as profile phone |
| `code` | OTP string (6 digits) |
| `token` | DRF auth token key after successful verify |
| `cooldown_seconds` | Seconds until resend allowed (fixed **120**) |

## Rules

| Rule | Where |
|------|-------|
| Online account uses **phone OTP only** (request → verify; create and sign-in are the same flow) | both |
| Resend OTP allowed only after **120 seconds** from last successful send for that phone | both |
| OTP expires after a short TTL (server: 10 minutes); invalid/expired codes reject verify | server |
| Successful verify creates the user if phone is new, else signs in; returns `token` + profile | both |
| Sign-out invalidates the current token; one tap, **no confirmation** UI | both |
| Profile `id` is server-issued, unique, immutable, displayed as a hash — never editable | both |
| Profile edits: `name` and `image` only | both |
| Each signed-in install upserts its FCM token under a stable `device_id`; only the authenticated user may create/update their own registrations | both |
| Registration sync is silent (no dedicated UI); failures retry on next obtain/refresh/sign-in without blocking the app | client |
| Unauthenticated clients work fully offline; sign-in is available later from Profile / intro | client |
| First install shows intro that prefers online but allows skip to local-only | client |
| Auth secrets / SMS provider credentials live in env only — never in repo | server |
| DEBUG without SMS provider: OTP may be logged to server console and shown on Django admin (`debug_code`); never return OTP in API responses; production never stores plaintext | server |

## Surfaces

| Surface | Shows / does |
|---------|----------------|
| **Intro** | First install only: prefer sign-in; clear skip to continue offline |
| **Sign-in** | Phone → OTP (resend after 2 min) |
| **Profile** | View/edit name & image; show read-only `id`; sign out |
| **Profile (guest)** | Sign-in CTA only |

## Wire (API contract)

Base: `/api/accounts/`. Auth header after verify: `Authorization: Token <token>`.

JSON is `snake_case`. Errors: DRF-style `{ "detail": "..." }` or field errors. Never return the OTP code in any response (DEBUG may **log** it and show it in Django admin only).

| Method | Path | Auth | Request | Success |
|--------|------|------|---------|---------|
| `POST` | `/api/accounts/otp/request/` | no | `{ "phone": string }` | `200` `{ "phone": string, "cooldown_seconds": 120, "expires_in_seconds": 600 }` |
| `POST` | `/api/accounts/otp/resend/` | no | `{ "phone": string }` | Same as request; `429` if within cooldown with `{ "detail", "retry_after_seconds" }` |
| `POST` | `/api/accounts/otp/verify/` | no | `{ "phone": string, "code": string }` | `200` `{ "token": string, "user": <profile> }` |
| `GET` | `/api/accounts/profile/` | yes | — | `200` profile |
| `PATCH` | `/api/accounts/profile/` | yes | JSON `{ "name"?: string }` and/or multipart `image` file | `200` profile |
| `PUT` | `/api/accounts/registrations/` | yes | `{ "device_id": string, "fcm_token": string }` | `200` registration |
| `POST` | `/api/accounts/logout/` | yes | — | `204` empty (deletes current token) |

**Profile object:** `{ "id", "phone", "name", "image_url", "created_at", "updated_at" }` per fields above.

**Registration object:** `{ "device_id", "fcm_token", "created_at", "updated_at" }` per device-registration fields above. Upsert by authenticated user + `device_id` (create or update `fcm_token` / `updated_at`). Reject empty `device_id` / `fcm_token`. Row-level isolation: never read or write another user's registrations via this endpoint.

**OTP delivery:** If `SMS_PROVIDER` / provider credentials unset → DEBUG console log of OTP + `PhoneOtp.debug_code` for admin; if DEBUG is false and no provider → `503` with clear detail. Placeholders only in `env.example/server.env` (local control plane: `.env/server.env`).

**Phone:** normalize to digits with leading `+` where possible; reject empty/invalid.

Legacy username/password under `/api/auth/` may remain for internal tests but product path is OTP only.

Index: [../domain.md](../domain.md)
