# technician-cabinet Specification

## Purpose
Employee personal cabinet for assigned work-order service lines.
## Requirements
### Requirement: Employee sees only own assignments
An employee MUST list and open only `WorkOrderService` rows where they are the assignee. They MUST NOT see other employees’ assignments or lab-wide payment reports.

#### Scenario: Index scoped to assignee
- **WHEN** an employee opens `/my_tasks`
- **THEN** only their assigned lines are listed

### Requirement: Filters by status and period
The cabinet MUST allow filtering by line status (`assigned` / `in_progress` / `completed`) and by a date period.

#### Scenario: Filter completed in period
- **WHEN** an employee filters status completed with from/to dates
- **THEN** only matching completed lines are shown

### Requirement: Start and complete own lines
An employee MUST be able to move their line `assigned → in_progress → completed` from the cabinet. Completing a line MUST NOT require photos.

#### Scenario: Take into work
- **WHEN** an employee starts an assigned line
- **THEN** status becomes `in_progress` and the work order may move to `in_progress` if it was `draft`

#### Scenario: Mark completed
- **WHEN** an employee completes an in-progress line
- **THEN** status becomes `completed` and `completed_at` is set

### Requirement: Own earnings for period
The cabinet MAY show the employee’s own sum for completed lines in the filtered period (`quantity * technician_price_snapshot`). Lab-wide totals MUST NOT be shown.

#### Scenario: Show own sum
- **WHEN** completed lines exist in the period filter
- **THEN** the index shows the sum of those lines’ amounts for the current user
