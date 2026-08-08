## Purpose

Delta for work-order UX: fix odontogram interaction and allow creating a patient from the order form.

## MODIFIED Requirements

### Requirement: Admin creates work order with required patient
Admin and superadmin MUST create a work order with customer, required patient, optional doctor, and sequential number. Employees MUST be denied. The work-order form MUST allow creating a new patient by name without leaving the form.

#### Scenario: Create order
- **WHEN** an admin creates a work order with customer and patient
- **THEN** the order is saved in `draft` with a unique sequential number

#### Scenario: Create patient inline
- **WHEN** an admin submits a work order with a new patient full name and no existing patient selected
- **THEN** a patient is created and linked to the order

### Requirement: Odontogram stored as FDI JSON
Work orders MUST store odontogram as JSONB with FDI notation. Tooth `type` MUST be a code from the tooth work types catalog (active types for new edits). The odontogram chart on the form MUST respond to tooth clicks to assign or clear the selected type.

#### Scenario: Save teeth types
- **WHEN** an admin saves odontogram with tooth 14 type crown
- **THEN** the JSON contains that tooth entry

#### Scenario: Click assigns type
- **WHEN** the odontogram controller toggles a tooth with a selected catalog type
- **THEN** the hidden dental_formula field JSON includes that tooth
