## Why

Phase **P0** from [`docs/AGENT_PLAN.md`](../../../docs/AGENT_PLAN.md): the repo has product requirements ([`spec.md`](../../../spec.md) §§8–9) but no runnable application. We need a Rails 8 + PostgreSQL + Docker Compose bootstrap so later phases can add auth, domain models, and UI on a working base.

## What Changes

- Generate a Rails 8 application (Ruby 3.3+) in the repo
- Add Docker Compose (`app`, `postgres`) with a volume for Active Storage Disk
- Configure locale `ru`, default currency display ₽, configurable Active Storage root via ENV
- Optional HTTPS readiness (`force_ssl` / proxy trust via ENV; off by default)
- `db:seed` creates initial `superadmin` (minimal User model for seed; full Devise/Pundit in P1)
- Document how to run via Docker Compose (and optional `bin/dev`) in README
- Placeholder root page confirming the app boots

## Non-goals

- Devise login UI, Pundit policies, role matrix screens (P1)
- Domain CRUD, work orders, odontogram, reports, QR (P2–P6)
- S3, Swarm/k8s, SPA frontends
- Full production hardening / mandatory HTTPS

## Capabilities

### New Capabilities

- `platform-bootstrap`: runnable Rails+Postgres stack via Docker Compose, Disk storage config, ru locale, HTTPS-ready ENV toggles, seed of initial superadmin user, healthy root response

### Modified Capabilities

- _(none — no existing openspec/specs yet)_

## Impact

- New Rails app tree, `Dockerfile`, `compose.yaml` / `docker-compose.yml`, `.env.example`
- New dependency on Docker Desktop (Windows client) or Docker Engine (Unix)
- Minimal `users` table for seed (email, password digest, role, active, full_name) — will be aligned with Devise in P1
- README updated with run instructions
