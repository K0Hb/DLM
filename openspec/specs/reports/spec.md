# reports Specification

## Purpose
Admin/superadmin laboratory reports: work orders for period, technician payroll/accruals, unpaid customer orders, workload funnel, customers and services summaries.

## Requirements
### Requirement: Only admin and superadmin access reports
Employees MUST be denied access to reports screens.

#### Scenario: Employee denied
- **WHEN** an employee opens `/reports`
- **THEN** access is denied (redirect)

### Requirement: Work orders for period
Admin MUST filter work orders by `created_at` period and optionally by status, customer, and customer-paid flag, and see number, dates, customer, patient, status, due, paid flag. CSV export MUST apply the same filters and be available.

#### Scenario: Filter by created_at
- **WHEN** an admin opens work-orders report with from/to dates
- **THEN** only orders created in that period are listed

#### Scenario: Filter by status and customer
- **WHEN** an admin sets status and/or customer filters
- **THEN** only matching orders in the period are listed

#### Scenario: CSV export
- **WHEN** an admin requests the work-orders report as CSV
- **THEN** a CSV download is returned with UTF-8 BOM, semicolon separators, and the same columns (Excel-friendly Cyrillic)

### Requirement: Technician payroll from completed lines
Payroll MUST sum `quantity * technician_price_snapshot` for lines with `status=completed` and `completed_at` in the period, grouped by assignee, with line detail. Admin MUST be able to filter by assignee, technician-paid flag, and service. Rolled-back completed lines MUST NOT appear. Soft-removed completed lines MUST still count.

#### Scenario: Completed line counted
- **WHEN** a line is completed in the period
- **THEN** its amount appears under that technician in the payroll report

#### Scenario: Filter by assignee and paid flag
- **WHEN** an admin filters payroll by assignee and/or paid/unpaid
- **THEN** only matching completed lines in the period are shown

#### Scenario: Rollback excludes from payroll
- **WHEN** a completed line is rolled back to in_progress
- **THEN** it no longer appears in the payroll report for that period

### Requirement: Unpaid customer orders
Admin MUST list work orders with `customer_paid_amount = 0`, with optional filters: status, creation period, customer, and “only with customer_payment_amount > 0”.

#### Scenario: Unpaid listed
- **WHEN** an admin opens the unpaid report
- **THEN** orders with zero paid amount are shown

#### Scenario: Filter by customer and positive due amount
- **WHEN** an admin filters unpaid by customer and “only with amount due”
- **THEN** only unpaid orders for that customer with `customer_payment_amount > 0` are shown

### Requirement: Workload funnel and in-hand services
Admin MUST see a Russian-language report of current work-order counts by status, plus active service lines (`assigned` / `in_progress`, not soft-removed) grouped by assignee.

#### Scenario: Status counts shown
- **WHEN** an admin opens the funnel report
- **THEN** counts of work orders for each status are shown

#### Scenario: In-hand lines by assignee
- **WHEN** there are active assigned or in_progress service lines
- **THEN** they appear under the corresponding assignee in the funnel report

### Requirement: Customers summary for period
Admin MUST see a per-customer summary for work orders created in a date range: order count, paid sum, and debt (unpaid `customer_payment_amount`).

#### Scenario: Customer row for period
- **WHEN** an admin opens the customers report with from/to dates
- **THEN** each customer with orders created in that period appears with counts and money totals

### Requirement: Services summary for period
Admin MUST see a per-service summary of completed lines with `completed_at` in the period: quantity sum and accrued amount. Soft-removed completed lines MUST still count.

#### Scenario: Service row for completed work
- **WHEN** completed lines exist in the period for a service
- **THEN** that service appears with total quantity and accrued amount
