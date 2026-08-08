## Why

Phase **P4**: technicians need a personal cabinet for their assigned service lines, and the lab needs Active Storage photo attachments on work orders and lines ([`spec.md`](../../../spec.md) §4.8, §6.2; §10 п.5, 11).

## What Changes

- Employee cabinet (`/my_tasks`): own lines only; filters by status and period; start/complete; optional own earnings for period
- Active Storage Disk photos on `WorkOrder` (≤20) and `WorkOrderService` (≤10); JPEG/PNG/WebP ≤10 MB
- Policies: employee cannot see others’ assignments or lab-wide money reports
- Integration/system tests for cabinet flow and photo limits
- Functional UI (utilitarian Russian)

## Non-goals

- Reports P5, QR public page P6
- S3 / external object storage
- Photo required to complete a line

## Capabilities

### New Capabilities

- `technician-cabinet`: employee personal task list and line actions
- `attachments`: Active Storage photos with MVP limits

### Modified Capabilities

- `work-orders`: photo upload on order/line for admin; employee transitions via cabinet

## Impact

- Active Storage tables + Disk service
- Nav: «Мои задачи» for employees
- Controllers/views/policies/tests
