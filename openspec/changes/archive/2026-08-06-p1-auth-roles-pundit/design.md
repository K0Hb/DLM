## Context

See `proposal.md`. P0 left a minimal `User` with `has_secure_password`. P1 upgrades to Devise + Pundit and adds scenario tests per project testing policy.

## Goals / Non-Goals

**Goals:**
- Devise email/password sessions; `active_for_authentication?` respects `active`
- Pundit `ApplicationPolicy` + `UserPolicy`; `authenticate_user!` on ApplicationController
- Superadmin users CRUD (list/create/edit/role/active/password)
- Russian Devise/UI strings where practical
- System tests (Capybara headless Chrome) for happy-path login + users UI; integration tests for authz denials

**Non-Goals:**
- Policies for WorkOrder/Service (not built yet)
- Public QR bypass (P6)
- Mailer-driven password reset UX (Devise recoverable may be enabled; full email flow optional if no SMTP)

## Decisions

1. **Devise modules:** `:database_authenticatable`, `:recoverable`, `:rememberable`, `:validatable`. Keep `email`, `role`, `active`, `full_name`.
2. **Migration:** rename/replace `password_digest` → Devise `encrypted_password`; add Devise columns; re-seed passwords (dev defaults). Existing Docker volume DB may need `db:migrate` + reseed.
3. **Authorization:** Pundit; rescue `NotAuthorizedError` → redirect with flash.
4. **Role helpers:** `User#superadmin?`, `admin?`, `employee?`.
5. **Tests:** prefer system for login + create user; integration for 403/redirect cases to keep suite faster. Expose Postgres `5432:5432` for host `bin/rails test` against compose DB, or run tests in a one-off container.
6. **Chrome:** system tests use headless Chrome; document dependency (Chrome/Chromium available on host or use selenium image later).

## Risks / Trade-offs

- [Docker volume has old schema] → Mitigation: migrate on deploy; document `docker compose run web bin/rails db:migrate db:seed`.
- [No Chrome in WSL] → Mitigation: integration tests always run; system tests skip/fail clearly if driver missing — prefer install chromium or run with available driver.
