## Context

See proposal. Pool HABTM (`users` ↔ `services`) already exists; only the management UI moves from `EmployeeSkillsController` onto `UsersController#show` / `#update`. Admin already may `update?` employees via `UserPolicy`.

## Goals / Non-Goals

**Goals:**
- Single place to manage an employee's service pool: `/users/:id`
- Remove `/employee_skills` routes and nav
- Keep assignment rules for work-order lines unchanged

**Non-Goals:**
- Changing HABTM schema or assignee-in-pool validation
- Giving employees access to user cards
- Bulk pool edit across many employees

## Decisions

1. **Inline form on `users#show`** (not only `users#edit`) — matches product contract «на карточке». Save via `PATCH /users/:id` with `service_ids`.
2. **Update `service_ids` only when the pool form submits** — regular profile edit must not clear the pool; detect presence of `user[service_ids]` (with empty hidden field to allow clearing all).
3. **Delete `EmployeeSkillsController` and policy** — avoid two entry points; authorize via existing `UserPolicy#update?`.
4. **Product contract `/spec.md`** — remove «Пул услуг — только `/employee_skills`»; keep §6.8 wording about pool on the card.

## Risks / Trade-offs

- [Bookmarks to `/employee_skills`] → 404 after deploy; acceptable for internal admin tool
- [Clearing all services] → intentional; hidden empty `service_ids[]` preserves Rails multi-checkbox pattern

## Migration Plan

Deploy with route removal; no DB migration. Update docs/`spec.md` in the same change.
