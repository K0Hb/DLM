## Decisions

- Domain service `Payments::Applier` applies toggles + writes one `PaymentEvent` per object inside a transaction.
- Confirmation is a dedicated GET `new` + POST `create` (not modal).
- 30-day lock from `technician_paid_at` for employee/admin; `superadmin` bypasses.
- Customer paid: set `customer_paid_amount` to sum of line amounts (or keep existing amount if already >0 when only updating date) — on mark paid use max(sum of services amounts, 0.01) so amount > 0; on unpay set amount 0 and clear paid_at/by.
- Employee report at `/my_earnings` (not under admin `/reports` hub).

## Risks

- Closed work orders: structure locked but customer payment still allowed (existing rule).
- Paying lines before `completed` is allowed by spec; payroll «начислено» stays completed-only.
