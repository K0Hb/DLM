## Why

Admin UX feedback on work-order form: teeth in odontogram do not respond to clicks (Stimulus data attribute JSON broken), tooth types should be an admin-managed catalog with seeded defaults, and patients should be creatable inline on the work-order form.

## What Changes

- Fix odontogram Stimulus wiring so tooth clicks work
- New `ToothWorkType` catalog (CRUD for admin/superadmin) + seed default pool
- Odontogram validation uses catalog codes (historical codes remain readable)
- Work-order form: create patient inline (name → create & select)
- Scenario tests for clicks-related save path, tooth type CRUD, inline patient

## Non-goals

- Visual polish of odontogram
- Connectors UI redesign

## Capabilities

### New Capabilities

- `tooth-work-types`: admin-managed odontogram tooth type catalog with defaults

### Modified Capabilities

- `work-orders`: inline patient create; odontogram uses catalog types; clickable chart

## Impact

- Migration + seed; nav link; form/JS changes
