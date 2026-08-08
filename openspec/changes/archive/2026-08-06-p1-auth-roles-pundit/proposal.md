## Why

Phase **P1** from [`docs/AGENT_PLAN.md`](../../../docs/AGENT_PLAN.md): platform boots (P0) but has no real authentication UI or authorization. Need Devise login, role-based access via Pundit, and superadmin user management per [`spec.md`](../../../spec.md) §3, §6.1, §6.8 — with automated scenario tests.

## What Changes

- Replace `has_secure_password` bootstrap with **Devise** (email + password)
- Block login when `active=false`
- Add **Pundit** and enforce role matrix for available surfaces
- Superadmin UI: list/create/edit users, role, active, password reset
- Protect app routes (login required) except health check
- **System and/or integration tests** for main auth scenarios (policy from AGENT_PLAN / spec §9.10)

## Non-goals

- Domain catalogs, work orders, reports, QR (P2–P6)
- Full Pundit policies for entities that do not exist yet (stubs / home access only where needed)
- Omniauth / 2FA / invite emails beyond Devise recoverable basics if unused in MVP UI

## Capabilities

### New Capabilities

- `auth-roles`: Devise session auth, inactive lockout, Pundit role helpers, superadmin user administration, scenario tests for login and authorization

### Modified Capabilities

- _(none)_

## Impact

- `User` model migrates from `password_digest` to Devise columns
- Seeds use Devise API
- New gems: `devise`, `pundit`
- Docker image rebuild needed after Gemfile change
