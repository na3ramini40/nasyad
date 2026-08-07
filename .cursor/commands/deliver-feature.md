# Deliver feature

Run the full delivery pipeline as the **conductor** (`.cursor/agents/conductor.md`).

1. Restate the goal (one sentence) and scope: client / server / both.
2. Emit the phase plan (intake+UX → contract if both → build → integrate → verify → ship on request).
3. Execute in order; delegate client work to flutter-agent and server work to django-agent.
4. Never claim done before `/verify` is green. Ship (`/ship-pr`, `/release`) only on explicit user intent.
