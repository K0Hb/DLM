# catalogs-and-skills Specification

## Purpose
Provides laboratory reference data (customers, doctors, patients, services with technician rates) and assignment of which services each employee may perform, gated by admin/superadmin roles.
## Requirements
### Requirement: Admin manages customers
Admin and superadmin MUST be able to create, list, update customers. Employees MUST be denied.

#### Scenario: Admin creates customer
- **WHEN** an admin submits a new customer with a name
- **THEN** the customer is stored and appears in the list

#### Scenario: Employee denied customers
- **WHEN** an employee requests the customers index
- **THEN** access is denied

### Requirement: Admin manages doctors
Admin and superadmin MUST CRUD doctors with optional customer association. Employees MUST be denied.

#### Scenario: Doctor without customer
- **WHEN** an admin creates a doctor without a customer
- **THEN** the doctor is saved successfully

### Requirement: Admin manages patients
Admin and superadmin MUST CRUD patients (global catalog). Employees MUST be denied.

#### Scenario: Admin creates patient
- **WHEN** an admin creates a patient with full name
- **THEN** the patient appears in the patient list

### Requirement: Admin manages services with technician price
Admin and superadmin MUST CRUD services with unique name and non-negative `technician_price`. Services MUST have a show page opened from the index via «Открыть». Delete MUST be available on the show page only, not on the index list. Employees MUST be denied.

#### Scenario: Admin creates priced service
- **WHEN** an admin creates a service with name and technician_price
- **THEN** the service is stored with that price and redirects to its show page

#### Scenario: Delete from show only
- **WHEN** an admin views the services index
- **THEN** no delete button is shown on list rows; delete is on the service show page

#### Scenario: Delete blocked when used in orders
- **WHEN** an admin tries to delete a service referenced by work order service lines
- **THEN** deletion is rejected with a clear message

### Requirement: Admin assigns service pool to employees
Admin and superadmin MUST assign a set of services to an employee on the employee user card (`/users/:id`). Employees MUST not manage pools. The dedicated service-pool list/edit UI (`/employee_skills`) MUST NOT be exposed in navigation or as a management surface.

#### Scenario: Admin assigns services on user card
- **WHEN** an admin opens an employee card and saves a selected set of services
- **THEN** those services are associated with the employee and the admin remains on the user card

#### Scenario: Employee denied service pool on user card
- **WHEN** an employee requests a user card or attempts to update another user's service pool
- **THEN** access is denied

#### Scenario: No separate pool navigation
- **WHEN** an admin views the main application header
- **THEN** there is no «Пул услуг» navigation entry to a separate pool index

### Requirement: Catalog scenarios covered by tests
Main catalog and service-pool flows MUST be covered by Rails integration and/or system tests.

#### Scenario: Suite covers catalogs and pool
- **WHEN** `bin/rails test` runs for this phase
- **THEN** create-customer, create-service, assign-pool, and employee-denial scenarios pass

