## Context

See proposal. P1 delivered Devise/Pundit/users. P2 adds catalogs + skills only. UI stays utilitarian.

## Goals / Non-Goals

**Goals:** models, admin CRUD UI, service pool assignment, policies, scenario tests.  
**Non-Goals:** work orders; visual design system; patient-customer ownership.

## Decisions

1. Models per spec §4.2–4.5; `active` boolean on Customer/Doctor/Service.
2. Join table `services_users` HABTM for service pool.
3. `CatalogPolicy`-style: `user.admin? || user.superadmin?` via shared concern/`ApplicationPolicy` helper `#admin_or_superadmin?`.
4. Service pool UI: `/employee_skills` index/edit for admin+superadmin (does not require full user CRUD for admin).
5. Superadmin users form also shows service checkboxes when editing.
6. Tests: integration for CRUD/authz; system rack_test for one happy path (create service + assign pool).

## Risks / Trade-offs

- [Admin cannot create users] → Mitigation: separate employee_skills for pool assignment (matches §3).
