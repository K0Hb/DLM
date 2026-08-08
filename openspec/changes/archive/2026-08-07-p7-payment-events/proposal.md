## Why

P7 from `docs/AGENT_PLAN.md` / `spec.md` §5.4, §10.1: track **payment facts** (technician payouts per line, customer payment per work order) with confirmation pages, append-only journal, and technician self-reports — without building a cash/bank module.

## What Changes

- `WorkOrderService`: `technician_paid`, `technician_paid_at`, `technician_paid_by_id`
- `WorkOrder`: `customer_paid_by_id` (amount/at already exist)
- `PaymentEvent` append-only log
- Confirmation pages for technician and customer payment batches
- My Tasks filters/badges/actions; admin payout-by-assignee; customer one or all unpaid orders
- Payment journal UI; technician earnings report (§7.4)
- Green/red payment badges
- Integration tests for §10.1 scenarios

## Non-goals

Cash register, bank, refunds, partial amounts, multiple payments per object, PDF payroll.
