# Vehicle Inspection System — First-time Setup Guide

This guide helps you get the project running locally (Windows / PowerShell). It assumes you cloned the repository and have Docker + Git installed.

## Prerequisites

- Windows (PowerShell) or Linux/Mac (use analogous Bash commands)
- Docker Desktop (with Compose v2+)
- Git (configured with your credentials)
- Optional: Python 3.10+ if you want to run services manually

## Quick overview

Repository layout (top-level):

- `docker-compose.yml` — Compose orchestration (Postgres + 7 services + frontend)
- `init-databases.sql` — Creates the 7 service databases and extensions
- `backend/*` — FastAPI microservices
- `frontend/` — Static site for UI
- `report_images/`, `report.tex`, `presentation.tex` — documentation and slides (not required to run)
- `*.ps1` — PowerShell helpers (see below)

## Provided automation scripts (PowerShell)

Existing helpers (you can use these directly):

- `docker-setup.ps1` — Creates `.env` (if missing), builds Docker images, and `docker compose up -d`.
- `docker-start.ps1` — Lightweight start (build + up) and quick status output.
- `START_COMPLETE_SYSTEM.ps1` — Starts Python services (not Docker) in separate PowerShell windows (for local dev without Docker).
- `check-admin.ps1` — Quick check of admin account inside the postgres container.
- `bootstrap.ps1` — convenience script that runs `docker-setup.ps1`, waits for Postgres, runs service migrations if present, and runs `check-admin.ps1`.

> Note: `docker-setup.ps1` already covers the common “build + up” flow and ensures `.env` exists.

## Recommended first-time steps (one-liner)

Open PowerShell in the repo root and run:

```powershell
# If you want docker-based deployment (recommended)
.\docker-setup.ps1
.\bootstrap.ps1
```

The above will:
- create `.env` with sensible defaults (if missing)
- build Docker images
- start all containers
- wait for Postgres to be ready
- run migration scripts (if available within service containers)
- perform a basic admin existence check

## Manual step-by-step (if you prefer to run commands yourself)

1. Create `.env` (if you want to override defaults)

```powershell
# Example .env (you can edit values)
DB_USER=postgres
DB_PASSWORD=your_db_password
JWT_SECRET_KEY=change-me
AUTH_SERVICE_PORT=8001
APPOINTMENT_SERVICE_PORT=8002
PAYMENT_SERVICE_PORT=8003
INSPECTION_SERVICE_PORT=8004
LOGGING_SERVICE_PORT=8005
NOTIFICATION_SERVICE_PORT=8006
FILE_SERVICE_PORT=8007
UI_SERVICE_PORT=3000
```

2. Build and start containers

```powershell
docker compose build
docker compose up -d
```

3. Confirm Postgres initialized the databases (the compose mounts `init-databases.sql` into the container entrypoint so DBs should be created automatically on first run):

```powershell
# show container status
docker compose ps

# tail postgres logs
docker compose logs -f postgres
```

4. (Optional) If you need to re-run the SQL initialization manually (for example after a fresh database reset), copy the SQL into the container and execute it:

```powershell
# copy and run init SQL
$cid = docker compose ps -q postgres
docker cp .\init-databases.sql $cid:/tmp/init-databases.sql
docker compose exec -T postgres psql -U postgres -f /tmp/init-databases.sql
```

5. Run migrations inside service containers (if service provides a migrate script). Example:

```powershell
# run migrations for services that include migrate_db.py
docker compose exec -T payment-service python migrate_db.py
docker compose exec -T appointment-service python migrate_db.py
```

6. Verify admin existence (helper):

```powershell
.\check-admin.ps1
```

7. Access the system

- Frontend: http://localhost:3000
- APIs: http://localhost:8001 .. 8007 (see `docker-compose.yml` ports)

## Running without Docker (local dev)

If you prefer to run services locally (for development/debugging), the `START_COMPLETE_SYSTEM.ps1` helper starts each Python service in its own terminal window. Ensure you created the databases and set the `.env` files appropriately for each service.

## Troubleshooting tips

- If a service fails to start, run `docker compose logs <service> --tail=200` and inspect the error messages.
- If Postgres reports missing extensions, connect and create `uuid-ossp` extension for the database in question (see `init-databases.sql`).
- If ports conflict, modify the `*_SERVICE_PORT` variables in `.env`.

## Security notes

- The default `.env` contains placeholder secrets. Change `DB_PASSWORD` and `JWT_SECRET_KEY` before deploying to a public environment.
- Do not commit secrets to source control.

## Files added by this setup

- `bootstrap.ps1` — convenience wrapper that calls `docker-setup.ps1`, waits for Postgres, runs known migration scripts, and runs `check-admin.ps1`.
- `FIRST_TIME_SETUP.md` — this guide (you are reading it).

## Next steps

- (Optional) Add CI pipeline to run smoke tests after `docker compose up` (GitHub Actions / Azure Pipelines).
- Add automated migration checks and health endpoints to the compose startup flow.

---

If you want, I can now:

- A) Commit `FIRST_TIME_SETUP.md` and `bootstrap.ps1` and push to the repository (I will exclude report/presentation files from the commit), or
- B) Make additional edits to the scripts (e.g., add more robust wait/retry logic) before committing.

Which do you prefer? 
