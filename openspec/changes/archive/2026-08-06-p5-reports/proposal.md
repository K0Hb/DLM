## Why

Phase **P5**: admin/superadmin need period reports — work orders, technician payroll, unpaid customer orders ([`spec.md`](../../../spec.md) §5.3, §7; §10 п.7, 12).

## What Changes

- Reports hub + three screens: work orders for period, technician payroll, unpaid orders
- Payroll only `completed` lines by `completed_at`; rollback removes from accrual
- CSV export for work-orders report (nice-to-have, included)
- Pundit: employees denied
- Integration tests for main report scenarios

## Non-goals

- QR / public page (P6)
- Partial payment statuses beyond amount==0 unpaid rule
- PDF exports

## Capabilities

### New Capabilities

- `reports`: three admin reports + CSV for work orders

### Modified Capabilities

- _(none)_

## Impact

- Routes `/reports`, controllers/views, nav «Отчёты»
