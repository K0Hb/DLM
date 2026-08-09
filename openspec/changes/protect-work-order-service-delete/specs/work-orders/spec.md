## ADDED Requirements

### Requirement: Service line deletion is restricted
Admin and superadmin MUST delete a work-order service line only when its status is `assigned` and `technician_paid` is false. Deletion MUST be rejected when the line is `in_progress`, `completed`, or already marked paid to the technician. Employees MUST NOT delete service lines.

#### Scenario: Assigned unpaid line can be deleted
- **WHEN** an admin deletes a service line in `assigned` with `technician_paid=false`
- **THEN** the line is removed from the work order

#### Scenario: In-progress line cannot be deleted
- **WHEN** an admin attempts to delete a service line in `in_progress`
- **THEN** the line remains and the system shows a clear rejection

#### Scenario: Paid line cannot be deleted
- **WHEN** an admin attempts to delete a service line with `technician_paid=true` (any non-completed status that would otherwise allow UI)
- **THEN** the line remains and the system shows a clear rejection

#### Scenario: Completed line cannot be deleted
- **WHEN** an admin attempts to delete a `completed` service line
- **THEN** the line remains
