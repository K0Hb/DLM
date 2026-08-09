## 1. Spec and routes

- [x] 1.1 Update `spec.md` §7 with new reports and filters; keep Russian product wording
- [x] 1.2 Add routes `funnel`, `customers`, `services` under reports scope
- [x] 1.3 Extend `ReportPolicy` with `funnel?`, `customers?`, `services?`

## 2. Filters on existing reports

- [x] 2.1 Work orders report: filters status, customer_id, paid; apply to HTML + CSV; update view
- [x] 2.2 Payroll: filters assignee_id, paid, service_id; update view
- [x] 2.3 Unpaid: filters customer_id, amount>0 flag; update view

## 3. New reports

- [x] 3.1 Funnel action + view (status counts + in-hand by assignee)
- [x] 3.2 Customers summary action + view (period, money totals)
- [x] 3.3 Services summary action + view (completed_at period)
- [x] 3.4 Update `/reports` hub cards (Russian copy)

## 4. Tests

- [x] 4.1 Integration: employee denied; admin sees funnel/customers/services; filter smoke on work_orders/payroll/unpaid
- [x] 4.2 Run `bin/rails test test/integration/reports_test.rb` (and related) green
