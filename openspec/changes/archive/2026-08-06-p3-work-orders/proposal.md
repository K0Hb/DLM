## Why

Phase **P3**: catalogs exist; need the core lab workflow — work orders with services, statuses, odontogram, customer payment, and delivery marking ([`spec.md`](../../../spec.md) §4.6–4.9, §5, §6.3–6.4, §6.6).

## What Changes

- WorkOrder + WorkOrderService models and admin UI
- Status forward/rollback rules; payment fields; sequential `number`
- Odontogram JSONB + utilitarian interactive UI (FDI + tooth types)
- Delivery filter/actions for `ready` → `sent`
- Assignee must be in service pool; reassign only while `assigned`
- Integration/system tests for main scenarios
- Functional UI only (visual polish deferred)

## Non-goals

- Technician cabinet / photos (P4)
- Reports (P5), QR public page (P6)
- Full CAD/exocad connectors UX polish beyond basic connectors storage

## Capabilities

### New Capabilities

- `work-orders`: work order lifecycle, line services, odontogram, payment, delivery, scenario tests

### Modified Capabilities

- _(none)_

## Impact

- New tables/controllers/views/Stimulus controller for odontogram
- Nav: Наряды, Доставка
