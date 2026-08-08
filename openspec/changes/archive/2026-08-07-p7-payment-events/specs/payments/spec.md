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
Admin/superadmin MUST mark a work order customer-paid only as a whole (amount > 0 or 0), via confirmation, for one order or all unpaid orders of a customer.

### Requirement: Journal and reports
PaymentEvent is append-only. Employees see own technician events; admins see all with filters. Employees have a self earnings/payout report.
