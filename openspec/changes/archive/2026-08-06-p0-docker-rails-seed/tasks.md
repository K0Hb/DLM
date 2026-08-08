## 1. Rails application scaffold

- [x] 1.1 Generate Rails 8 app at repo root (PostgreSQL, Hotwire) without overwriting `spec.md`, `docs/`, `openspec/`, `ZTLHelp.pdf`
- [x] 1.2 Configure locale `ru`, time zone `Moscow` (or Europe/Moscow), and ₽ as default currency unit
- [x] 1.3 Configure Active Storage Disk service with root from `ACTIVE_STORAGE_ROOT` ENV (fallback: `storage`)
- [x] 1.4 Add HTTPS readiness: `FORCE_SSL` ENV toggles `config.force_ssl` (default off)

## 2. User seed foundation

- [x] 2.1 Create `users` migration/model: email, password_digest, full_name, role, active
- [x] 2.2 Implement idempotent `db/seeds.rb` creating superadmin from `SUPERADMIN_EMAIL` / `SUPERADMIN_PASSWORD` (documented defaults)
- [x] 2.3 Add placeholder `GET /` page showing DLM is running

## 3. Docker Compose

- [x] 3.1 Add Dockerfile for the Rails app (Ruby 3.3+)
- [x] 3.2 Add `compose.yaml` with `db` (Postgres) + `web`, volumes for DB and Active Storage
- [x] 3.3 Add entrypoint: wait for DB, `db:prepare`, `db:seed`, start server
- [x] 3.4 Add `.env.example` and `.dockerignore`

## 4. Docs and verify

- [x] 4.1 Update README with Docker Compose run instructions (Windows Docker Desktop / Unix) and seed credentials note
- [x] 4.2 Verify stack: `docker compose up --build` (or equivalent) and `GET /` returns 200
