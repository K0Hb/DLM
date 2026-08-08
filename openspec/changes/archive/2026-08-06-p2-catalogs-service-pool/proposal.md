## Why

Phase **P2**: auth exists; next we need domain catalogs (customers, doctors, patients, services) and the technician service pool so later work-order assignment can enforce skills ([`spec.md`](../../../spec.md) §4.2–4.5, §6.5; acceptance §10 п.2–3).

## What Changes

- CRUD for Customer, Doctor, Patient, Service
- HABTM (or equivalent) service pool on User; assignable by admin and superadmin
- Pundit: catalogs for admin+superadmin; employees cannot access
- Doctor.customer_id optional; no filter-by-customer required in UI
- Integration/system tests for main catalog and pool scenarios
- Functional UI only (visual polish deferred)

## Non-goals

- Work orders, statuses, odontogram (P3)
- UI visual redesign / brand polish
- Soft-delete cascades beyond simple `active` flags where already specified

## Capabilities

### New Capabilities

- `catalogs-and-skills`: domain catalogs CRUD and employee service-pool assignment with role checks and scenario tests

### Modified Capabilities

- _(none)_

## Impact

- New models/migrations/controllers/views
- Nav links for admin/superadmin
- User association to services
