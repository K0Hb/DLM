## Decisions

1. **Routes:** `/reports` index hub; `/reports/work_orders`, `/reports/payroll`, `/reports/unpaid`.
2. **Work orders period:** filter by `created_at` (minimum per §7.1); optional `date_field` param later not needed — stick to created_at.
3. **Payroll:** lines `status=completed` with `completed_at` in [from, to]; group by assignee with totals; detail table below or expandable sections.
4. **Unpaid:** `customer_paid_amount = 0` with optional status + created_at period filters.
5. **CSV:** same columns as HTML work-orders report, `format.csv`.
6. **Authorization:** `ReportPolicy` — admin/superadmin only; employee redirected.
