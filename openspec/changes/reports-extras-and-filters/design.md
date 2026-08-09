## Context

See proposal.md. Existing hub: `ReportsController` + three actions; policy methods per action; Russian UI on `/reports`.

## Goals / Non-Goals

**Goals:**
- Three new read-only report actions with clear Russian copy
- Shared filter UX patterns (period, selects) consistent with current reports
- Spec.md §7 updated to match

**Non-Goals:**
- CSV for the three new reports (can add later)
- Charts / dashboards
- Overdue-as-separate-report (explicitly deferred)
- Changing payment/payout action screens

## Decisions

1. **Routes** — add `funnel`, `customers`, `services` under existing `reports` scope; Pundit methods `funnel?`, `customers?`, `services?` mirroring others.

2. **Funnel data** — snapshot “now” (no period): `WorkOrder.group(:status).count`; in-hand = `WorkOrderService.active.where(status: %w[assigned in_progress])` grouped by assignee. Link assignee block to technician payouts / my tasks not required; link to work order is enough.

3. **Customers period** — filter by `work_orders.created_at`. Per customer:
   - `orders_count`
   - `paid_sum` = sum of `customer_paid_amount` where paid
   - `debt_sum` = sum of `customer_payment_amount` for unpaid (`customer_paid_amount = 0`)
   - optional `due_sum` = paid_sum + debt_sum for “оборот к оплате” clarity  
   Soft math stays on `customer_payment_amount` / `customer_paid_amount` (no service-line totals).

4. **Services period** — same accrual rule as payroll: `status=completed`, `completed_at` in range; group by `service_id`; include soft-removed completed lines (join without `.active` scope) so accruals match §7.2.

5. **Filters on existing reports** — reuse query params already known from list UIs (`status`, `customer_id`, `paid`, `assignee_id`, `service_id`, plus `amount=yes` for unpaid positive due). CSV for work_orders uses the filtered scope.

6. **Pagination** — funnel/customers/services are aggregated; usually small. Paginate only if row count likely > 40 (customers/services); funnel sections stay unpaginated.

## Risks / Trade-offs

- [Funnel without period] → good for ops “сейчас”; if user wants historical funnel later, add period as follow-up  
- [Customers debt vs payment_amount] → unpaid with zero `customer_payment_amount` still counts as debt 0 but order in count — filter “только с суммой” on unpaid report covers noise  
- [Services include removed] → consistent with payroll; document in UI one line

## Migration Plan

No DB migration. Deploy code; update `spec.md` §7 in same change.
