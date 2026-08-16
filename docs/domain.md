# Domain bible

**Structure of the application** — what every client and every server (any language, platform, or tool) must fit to.

This tree (`docs/domain.md` + `docs/domain/`) is the **only** documentation under `docs/`. Ground rule for correctness:

- Implementations may differ. **Observable results must match.**
- Domain rules can be tagged **Where: both | client | server** — some can only be enacted on one side, but they still live here so a rewrite elsewhere yields the same product.
- If code or other docs disagree with this tree, **the bible wins**. Fix the code, or change the matching shard in the **same** change.
- New capabilities, entities, fields, enums, or where-tags land in the right shard first — then implementations follow.

Screen chrome and copy: `.cursor/skills/shared/product/` (app-map wins for UX detail). Wire checklist: `.cursor/skills/shared/api-contract/`. Repo path maps: client/server `domains.md` shards.

## Map

| Part | File |
|------|------|
| Principles + Where tags | [domain/principles.md](domain/principles.md) |
| Structure (capabilities & surfaces) | [domain/structure.md](domain/structure.md) |
| Device | [domain/device.md](domain/device.md) |
| DeviceLog | [domain/device-log.md](domain/device-log.md) |
| Birthday | [domain/birthday.md](domain/birthday.md) |
| User (account / OTP / profile) | [domain/user.md](domain/user.md) |
| App config / feature flags | [domain/app-config.md](domain/app-config.md) |
| Local-only capabilities (tags, home grouping, …) | [domain/local.md](domain/local.md) |
| Enums (wire strings) | [domain/enums.md](domain/enums.md) |
| Sync | [domain/sync.md](domain/sync.md) |
| Client local store | [domain/client-store.md](domain/client-store.md) |
| Client layout (this repo) | [domain/client-layout.md](domain/client-layout.md) |
| Release & install | [domain/release.md](domain/release.md) |
| GitHub release notes (per version) | [domain/releases/](domain/releases/) |
| Progress log | [domain/ailogs.md](domain/ailogs.md) |

Read the index; open the shard that owns the fact.
