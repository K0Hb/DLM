# reports Specification

## Purpose
Admin/superadmin laboratory reports: work orders for period, technician payroll, unpaid customer orders.
## Requirements
### Requirement: Only admin and superadmin access reports
Employees MUST be denied access to reports screens.

#### Scenario: Employee denied
- **WHEN** an employee opens `/reports`
- **THEN** access is denied (redirect)

### Requirement: Work orders for period
Admin MUST filter work orders by `created_at` period and see number, dates, customer, patient, status, due, paid flag. CSV export MUST be available.

#### Scenario: Filter by created_at
- **WHEN** an admin opens work-orders report with from/to dates
- **THEN** only orders created in that period are listed

#### Scenario: CSV export
- **WHEN** an admin requests the work-orders report as CSV
- **THEN** a CSV download is returned with UTF-8 BOM, semicolon separators, and the same columns (Excel-friendly Cyrillic)

### Requirement: Technician payroll from completed lines
Payroll MUST sum `quantity * technician_price_snapshot` for lines with `status=completed` and `completed_at` in the period, grouped by assignee, with line detail. Rolled-back completed lines MUST NOT appear.

#### Scenario: Completed line counted
- **WHEN** a line is completed in the period
- **THEN** its amount appears under that technician in the payroll report

#### Scenario: Rollback excludes from payroll
- **WHEN** a completed line is rolled back to in_progress
- **THEN** it no longer appears in the payroll report for that period

### Requirement: Unpaid customer orders
Admin MUST list work orders with `customer_paid_amount = 0`, with optional status and period filters.

#### Scenario: Unpaid listed
- **WHEN** an admin opens the unpaid report
- **THEN** orders with zero paid amount are shown
