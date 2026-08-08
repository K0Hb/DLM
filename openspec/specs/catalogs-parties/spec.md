# catalogs-parties Specification

## Purpose
Party relationships and richer catalog cards for customers, doctors, and patients.
## Requirements
### Requirement: Patient always has a doctor
A Patient MUST belong to a Doctor (`doctor_id` required). A Doctor MAY optionally belong to a Customer.

#### Scenario: Create patient without doctor
- **WHEN** admin tries to create a patient without `doctor_id`
- **THEN** the record is rejected

### Requirement: Work order patient optional
A WorkOrder MUST have a Customer. Patient and Doctor on the work order MUST be optional. A work order MAY have at most one patient.

#### Scenario: Customer-only order
- **WHEN** admin creates a work order with only a customer
- **THEN** the work order is saved with null patient and doctor

#### Scenario: Inline patient requires doctor
- **WHEN** admin creates a work order with a new patient name but no doctor
- **THEN** the patient is not created and an error is shown

### Requirement: Catalog show pages
Admin/superadmin MUST see show pages for Patient, Doctor, and Customer listing related work orders (and for Doctor: patients). Nested tables on show pages MUST include an «Открыть» action per row linking to the related record show page.
