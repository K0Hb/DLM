## 1. Schema
- [x] 1.1 Migration: technician_paid fields on work_order_services; customer_paid_by on work_orders; payment_events
- [x] 1.2 Models PaymentEvent, associations, helpers/scopes

## 2. Domain
- [x] 2.1 Payments::Applier + 30-day lock + eligibility
- [x] 2.2 Policies for payments and payment_events

## 3. UI / routes
- [x] 3.1 Confirmation flows technician + customer
- [x] 3.2 My tasks filters/badges/actions; work order customer pay; admin by assignee
- [x] 3.3 Payment journal + my earnings report + badges

## 4. Tests & docs
- [x] 4.1 Integration tests §10.1
- [x] 4.2 Mark AGENT_PLAN P7 done; archive OpenSpec after green tests
