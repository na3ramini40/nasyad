# Nasyad

Monorepo for the Nasyad maintenance tracker.

| Side | Path | Stack |
|------|------|-------|
| **Client** | [`client/`](client/) | Flutter — local-first UI, Drift, BLoC |
| **Server** | [`server/`](server/) | Django REST API |
| **Local secrets** | [`.env/`](.env/) (gitignored) | From [`env.example/`](env.example/) |

## Control plane (`.env/`)

One folder holds modes, API URL, app id, GitHub update channel, version, Django secrets, and Android signing:

```bash
cp -a env.example .env   # once — then edit .env/ for your machine
./tool/env_apply.sh      # sync version + Android local files
```

| You (owner) | Contributors / forks |
|-------------|----------------------|
| Official `APP_APPLICATION_ID`, GitHub repo, release keystore in `.env/android/` | Example ids (`com.example.nasyad`), empty GitHub channel, debug signing |
| Production Django secrets / admin | Their own `.env/server.env` + their own admin user |

Never commit `.env/`.

## Run everything (one command)

```bash
./tool/dev.sh --setup    # first time
./tool/dev.sh
```

| Flag | What |
|------|------|
| `./tool/dev.sh` | Django API + `flutter run` (dart-defines from `.env/`) |
| `./tool/dev.sh --client-only` | Flutter only |
| `./tool/dev.sh --server-only` | API only |
| `./tool/dev.sh --docker` | Server in Docker; Flutter on host |
| `./tool/dev.sh -- -d linux` | Pass flags to `flutter run` |

Requires: **Flutter** SDK (+ device/emulator). Server path needs **Python 3.12+** or **Docker** with `--docker`.

## Verify (one command)

```bash
./tool/ci_verify.sh      # client + server — required before any PR
```

## Client (Flutter)

```bash
cd client
source tool/pub_env.sh
flutter pub get
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

Prefer `./tool/dev.sh` so defines and Android id come from `.env/`.

## Server (Django)

```bash
cp -a env.example .env   # if missing
./tool/env_apply.sh
cd server
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
python manage.py migrate
python manage.py runserver
```

Health: http://127.0.0.1:8000/api/health/

API docs (DEBUG only): http://127.0.0.1:8000/api/schema/swagger-ui/. `NASYAD_MODE=release` / `DJANGO_DEBUG=false` hides docs and requires SMS for OTP.

## Agent entry

- [`AGENTS.md`](AGENTS.md) — engineering layout + `.cursor` index

## Feature delivery

Cross-cutting features usually touch **both** `client/` and `server/`. Keep domain apps isolated.
