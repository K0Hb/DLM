## Why

Admin needs to remove mistaken or obsolete service lines even after work/payment, without erasing payroll and payment journal history. Hard delete orphans PaymentEvents and drops earnings visibility.

## What Changes

- Soft-remove via `removed_at` for lines that are not hard-deletable (`in_progress`, `completed`, and/or `technician_paid`).
- Keep hard delete only for `assigned` + unpaid (draft noise).
- Active composition (show, public, ready rules, tasks tab) excludes removed lines; payroll and payment journal keep them.

## Capabilities

### New Capabilities

- (нет)

### Modified Capabilities

- `work-orders`: hard vs soft removal of service lines with history preserved

## Impact

- Migration `removed_at` / `removed_by_id` on `work_order_services`
- Model scopes, `WorkOrder#assigned_service_lines`, destroy controller branch
- my_tasks tasks vs earnings filtering
- `spec.md` §4.7
