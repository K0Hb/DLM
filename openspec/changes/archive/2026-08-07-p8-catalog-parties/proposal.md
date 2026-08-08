## Why

P8: catalog cards are too thin; domain needs patient→doctor required, and work orders that can be customer-only (no patient/doctor), e.g. a private person ordering a model.

## What Changes

- `Patient` requires `doctor_id`; doctor may optionally belong to a customer
- `WorkOrder.patient_id` becomes optional (doctor already optional); customer remains required
- Show pages for patients, doctors, customers with related work orders (and patients for doctors)
- Richer indexes; work order form supports no patient and inline patient only with a doctor
- Update `spec.md` acceptance accordingly

## Non-goals

Clinic/doctor portal, hard-filter doctors by work-order customer, customer billing.
