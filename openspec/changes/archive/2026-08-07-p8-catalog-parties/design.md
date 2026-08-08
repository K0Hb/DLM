## Context

Admin catalogs are CRUD tables without show. Spec required a patient on every work order; product now allows customer-only orders and requires every patient to have a doctor.

## Decisions

- Patient `belongs_to :doctor` required; doctor's `customer_id` stays optional
- Work order: `patient_id` and `doctor_id` both optional; selecting a patient prefills doctor from the patient (overridable)
- Inline new patient on work order form requires a doctor on the form; otherwise error
- Doctor show lists patients and related work orders (by `doctor_id` or patient's orders)
- Customer without doctors/patients is valid

## Migration

Backfill `patients.doctor_id` from first available doctor (or create a placeholder doctor if none), then NOT NULL. Change `work_orders.patient_id` to nullable.
