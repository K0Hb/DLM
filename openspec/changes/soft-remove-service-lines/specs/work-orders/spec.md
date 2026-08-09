## ADDED Requirements

### Requirement: Soft-remove preserves payment history
Admin and superadmin MUST be able to remove a non-hard-deletable service line from the active work-order composition by setting `removed_at` (soft-remove) instead of destroying the row. Soft-removed lines MUST remain in the database so PaymentEvents keep their `work_order_service_id` and payroll still counts completed work. Hard destroy MUST remain only for `assigned` and unpaid lines.

#### Scenario: Soft-remove completed paid line
- **WHEN** an admin removes a `completed` line with `technician_paid=true`
- **THEN** the line has `removed_at` set, remains in the database, is absent from the active service list on the work order, and its PaymentEvent still references the line

#### Scenario: Hard delete assigned unpaid line
- **WHEN** an admin deletes an `assigned` unpaid line
- **THEN** the row is destroyed

#### Scenario: Soft-removed line does not block ready
- **WHEN** all active (non-removed) lines are `completed` and at least one active line exists
- **THEN** the work order MAY advance to `ready` even if a soft-removed incomplete line exists

#### Scenario: Tasks hide removed; earnings keep completed removed
- **WHEN** an employee opens `/my_tasks` tasks tab
- **THEN** soft-removed lines are not listed as active tasks
- **WHEN** the same employee opens the earnings tab
- **THEN** soft-removed completed lines still appear in earnings
