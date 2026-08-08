# payments Specification

## Purpose
Payment facts for technician lines and customer work orders, with confirmation, journal, and technician self-report.
## Requirements
### Requirement: Technician payout on service line
A work order service MUST support `technician_paid` boolean with timestamp and actor. Marking paid/unpaid MUST require assignee, work order not `draft`, and go through a confirmation page. Partial payout of a line MUST NOT be allowed.

#### Scenario: Employee marks own line paid
- **WHEN** an assignee confirms payout for an eligible own line
- **THEN** the line is `technician_paid` and a `technician_paid` PaymentEvent is stored with that actor

#### Scenario: Lock after 30 days
- **WHEN** a line has been paid for more than 30 days
- **THEN** employee and admin MUST NOT change payout status, but superadmin MAY with a journal event

### Requirement: Customer payment whole order
Admin/superadmin MUST mark a work order customer-paid only as a whole (`customer_paid_amount` > 0 or 0), via confirmation, for one order or a batch from the customer payment orders screen.

The confirmation page MUST require a manually entered payment amount per order. Amount MUST NOT be auto-filled from technician service line totals. The amount MAY be pre-filled from `customer_payment_amount` stored on the work order.

#### Scenario: Confirm with stored amount
- **WHEN** admin opens customer payment confirmation for an order with `customer_payment_amount` > 0
- **THEN** the amount field is pre-filled with that value and admin may edit before confirming

### Requirement: Customer payment amount on work order
Work orders MUST have `customer_payment_amount` (decimal ≥ 0) for the planned customer billing amount while unpaid. Admin/superadmin MUST set it on the work order edit form. Lists (customer show, customer payment orders) MUST display this as «Сумма оплаты» for unpaid orders.

### Requirement: Admin payment screens
Admin/superadmin MUST have index screens for technician payouts (`/technician_payouts`) and customer payment orders (`/customer_payment_orders`) with checkboxes leading to confirmation pages.

### Requirement: Separate payment journals
Technician payout events (`technician_*`) and customer payment events (`customer_*`) MUST be shown in separate journal screens. `/payment_events` MUST list only technician events. `/customer_payment_events` MUST list only customer events and MUST be accessible to admin/superadmin only.

### Requirement: Journal and reports
PaymentEvent is append-only. Employees see own technician events at `/payment_events`; admins see all technician events there and all customer events at `/customer_payment_events`. Employee earnings/payout summary lives on `/my_tasks` tab «Начисления и оплаты»; `/my_earnings` redirects there with `tab=earnings`.
