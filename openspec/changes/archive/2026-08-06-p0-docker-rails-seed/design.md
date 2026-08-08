## Context

See `proposal.md` — Why. Repo is greenfield: product `spec.md` exists, no Rails app yet. P0 must only bootstrap the platform for P1+ (Devise/Pundit come next).

## Goals / Non-Goals

**Goals:**
- Rails 8 app + PostgreSQL via Docker Compose
- Disk Active Storage with ENV/volume path
- `ru` locale, ₽ money unit config
- HTTPS toggle via ENV (off by default)
- Minimal `users` table + seed `superadmin`
- Documented run path for Windows Docker Desktop and Unix

**Non-Goals:**
- Devise sessions, Pundit, login UI (P1)
- Domain models / odontogram / reports / QR
- Production TLS termination inside the app container (proxy later)

## Decisions

1. **App layout:** Rails app lives at repo root (not `apps/web`), so Compose and OpenSpec stay simple. Existing `spec.md`, `docs/`, `openspec/` remain alongside Rails files; add `.dockerignore` to keep image lean.

2. **Ruby/Rails:** Ruby 3.3+ image (official `ruby:3.3-bookworm` or similar) + Rails 8. Generate with PostgreSQL, skip unused defaults where practical (`--css=tailwind` or default; prefer Hotwire-ready defaults).

3. **Compose services:** `db` (postgres:16) + `web` (app). Named volumes: `postgres_data`, `storage_data` mounted at Active Storage root inside the container.

4. **User for seed before Devise:** Create `users` with `email`, `password_digest` (has_secure_password), `full_name`, `role`, `active`. P1 will migrate to Devise fields; keep columns compatible where possible (`email` unique) so seed logic survives.

5. **Entrypoint:** Script waits for Postgres, runs `db:prepare`, `db:seed`, then `bin/rails server`.

6. **HTTPS:** `FORCE_SSL=true` enables `config.force_ssl`; `RAILS_ASSUME_SSL` / trusted proxies via ENV when behind reverse proxy. Default unset/false.

7. **Credentials:** `.env.example` with `POSTGRES_*`, `RAILS_MASTER_KEY` or `SECRET_KEY_BASE`, `SUPERADMIN_EMAIL`, `SUPERADMIN_PASSWORD`, `ACTIVE_STORAGE_ROOT`, `FORCE_SSL`. Dev defaults documented in README (change in production).

**Alternatives considered:**
- App in subdirectory → more path friction for Compose/OpenSpec; rejected for MVP.
- Full Devise in P0 → expands scope into P1; rejected.
- SQLite for bootstrap → contradicts locked PostgreSQL stack; rejected.

## Risks / Trade-offs

- [P1 will reshape User for Devise] → Mitigation: keep `email`/`role`/`active`/`full_name`; document migration note in P1 proposal.
- [Rails new may conflict with existing root files] → Mitigation: generate carefully; do not overwrite `spec.md` / `openspec/` / `docs/`.
- [Docker Desktop on Windows path/volume quirks] → Mitigation: use named volumes, not bind mounts to Windows paths for PG/storage by default.

## Migration Plan

N/A (greenfield). Operators: clone → copy `.env.example` → `docker compose up --build` → open `http://localhost:3000`.
