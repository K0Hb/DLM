## MODIFIED Requirements

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
