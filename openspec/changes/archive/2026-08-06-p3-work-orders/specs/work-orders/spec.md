## Purpose

Defines work-order lifecycle for the lab: create orders with required patient, service lines with one assignee from the skill pool, status transitions, odontogram, customer payment fields, and delivery marking.

## ADDED Requirements

### Requirement: Admin creates work order with required patient
Admin and superadmin MUST create a work order with customer, required patient, optional doctor, and sequential number. Employees MUST be denied.

#### Scenario: Create order
- **WHEN** an admin creates a work order with customer and patient
- **THEN** the order is saved in `draft` with a unique sequential number

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
Admin and superadmin MUST set `customer_paid_amount` and `customer_paid_at` on the order (including after closed).

#### Scenario: Record payment
- **WHEN** an admin sets a positive paid amount and date
- **THEN** the values persist on the work order

### Requirement: Delivery marks sent
Admin and superadmin MUST mark ready orders as `sent`.

#### Scenario: Mark sent
- **WHEN** an admin marks a ready order as sent
- **THEN** status becomes `sent` and `sent_at` is set

### Requirement: Odontogram stored as FDI JSON
Work orders MUST store odontogram as JSONB with FDI notation and tooth types from the allowed enum.

#### Scenario: Save teeth types
- **WHEN** an admin saves odontogram with tooth 14 type crown
- **THEN** the JSON contains that tooth entry

### Requirement: Work order scenarios covered by tests
Main work-order flows MUST have integration and/or system test coverage.

#### Scenario: Suite covers core flows
- **WHEN** phase tests run
- **THEN** create, pool rejection, ready-guard, payment, and delivery scenarios pass
