# work-orders Specification

## Purpose
Defines work-order lifecycle for the lab: create orders with optional patient, service lines with one assignee from the skill pool, status transitions, odontogram, customer payment fields, and delivery marking.
## Requirements
### Requirement: Admin creates work order with optional patient
Admin and superadmin MUST create a work order with required customer, optional patient and doctor, and sequential number. Employees MUST be denied. The work-order form MUST allow creating a new patient by name without leaving the form when a doctor is specified.

#### Scenario: Create order
- **WHEN** an admin creates a work order with customer and patient
- **THEN** the order is saved in `draft` with a unique sequential number

#### Scenario: Customer-only order
- **WHEN** an admin creates a work order with only a customer
- **THEN** the order is saved with null patient and doctor

#### Scenario: Create patient inline
- **WHEN** an admin submits a work order with a new patient full name and a doctor
- **THEN** a patient is created and linked to the order

### Requirement: Service lines require assignee in pool
Each work order service line MUST have one assignee who has that service in their pool at assignment time.

#### Scenario: Assignee outside pool rejected
- **WHEN** an admin assigns an employee who lacks the service in their pool
- **THEN** the line is not saved

### Requirement: Ready and closed require completed lines
A work order MUST NOT enter `ready`, `sent`, or `closed` without at least one service line and all lines `completed`.

#### Scenario: Ready blocked with incomplete line
- **WHEN** an admin tries to mark ready while a line is not completed
- **THEN** the transition is rejected

### Requirement: Status rollback except from closed
Admin and superadmin MUST be able to roll back statuses per spec §5.1.1 / §5.2.1; rollback from `closed` MUST be forbidden.

#### Scenario: Closed cannot roll back
- **WHEN** an admin attempts to move a closed order backward
- **THEN** the system rejects the change

### Requirement: Customer payment fields
While unpaid, admin and superadmin MUST set `customer_payment_amount` on the work order edit form. Marking paid, changing paid amount, or unpaying MUST go through the payment confirmation flow (Payments::Applier). `customer_paid_amount` and `customer_paid_at` MUST NOT be editable via the work order form.

#### Scenario: Store payment amount on unpaid order
- **WHEN** an admin sets `customer_payment_amount` on an unpaid order
- **THEN** the value persists and the order remains unpaid

#### Scenario: Record payment via confirmation
- **WHEN** an admin confirms customer payment with an explicit amount
- **THEN** `customer_paid_amount`, `customer_paid_at`, and `customer_paid_by` are set and a PaymentEvent is created

### Requirement: Delivery marks sent
Admin and superadmin MUST mark ready orders as `sent`.

#### Scenario: Mark sent
- **WHEN** an admin marks a ready order as sent
- **THEN** status becomes `sent` and `sent_at` is set

### Requirement: Work orders index searchable and linkable
The work orders list MUST allow filtering by patient name (surname / full name substring). Each row MUST provide a link to the work order show page (number, patient name, and/or explicit open action).

#### Scenario: Search by patient surname
- **WHEN** an admin opens `/work_orders` with patient query matching a surname fragment
- **THEN** only work orders for matching patients are listed

#### Scenario: Open work order from list
- **WHEN** an admin clicks the work order number or Open on a list row
- **THEN** the work order show page is displayed

### Requirement: Odontogram stored as FDI JSON
Work orders MUST store odontogram as JSONB with FDI notation. Tooth `type`, `material`, and order-level `shade` MUST be codes from `config/odontogram.yml` or null. Materials and shades MUST be chosen from selects, not free text. Plain chart click selects a tooth with null params; Ctrl/Cmd+click copies params; summary under the chart is read-only and groups teeth by type+material. The chart MUST color teeth by type (or untyped highlight) for feedback. Work order show MUST use a two-column layout on large screens (content + read-only odontogram sidebar).

#### Scenario: Save teeth types
- **WHEN** an admin saves odontogram with tooth 14 type crown
- **THEN** the JSON contains that tooth entry

#### Scenario: Save shade and per-tooth material
- **WHEN** an admin saves shade A3 and tooth 21 veneer with material `emax`
- **THEN** formula shade and tooth material persist (and `tooth_color` matches shade)

#### Scenario: Save selected tooth without type
- **WHEN** an admin saves a tooth entry with null type and null material
- **THEN** the tooth remains in the formula as selected without parameters


### Requirement: Work order scenarios covered by tests
Main work-order flows MUST have integration and/or system test coverage.

#### Scenario: Suite covers core flows
- **WHEN** phase tests run
- **THEN** create, pool rejection, ready-guard, payment amount, and delivery scenarios pass
