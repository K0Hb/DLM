# auth-roles Specification

## Purpose
Covers authentication with Devise, role-based authorization with Pundit, superadmin user administration, and automated scenario tests for the main auth flows.
## Requirements
### Requirement: Users sign in with email and password
The system MUST authenticate employees via Devise using email and password.

#### Scenario: Successful login
- **WHEN** an active user submits valid email and password
- **THEN** the system starts an authenticated session and allows access to protected pages

#### Scenario: Invalid credentials
- **WHEN** a user submits invalid credentials
- **THEN** the system refuses access and shows an error

### Requirement: Inactive users cannot sign in
The system MUST deny authentication for users with `active=false`.

#### Scenario: Inactive login attempt
- **WHEN** an inactive user submits otherwise valid credentials
- **THEN** the system does not grant a session

### Requirement: Unauthenticated users are redirected to login
Protected application pages MUST require authentication (except health endpoints and future public order pages).

#### Scenario: Root without session
- **WHEN** an unauthenticated client requests `GET /`
- **THEN** the system redirects to the login page

### Requirement: Only superadmin manages users
User administration (list, create, update role/active, set/reset password) MUST be allowed only for `superadmin` via Pundit.

#### Scenario: Superadmin opens users
- **WHEN** a signed-in superadmin opens the users management area
- **THEN** the system shows the user list and allows creating a user

#### Scenario: Employee denied users admin
- **WHEN** a signed-in employee requests the users management area
- **THEN** the system denies access (redirect or 403)

#### Scenario: Admin denied users admin
- **WHEN** a signed-in admin requests the users management area
- **THEN** the system denies access

### Requirement: Only superadmin can assign superadmin role
The system MUST allow assigning role `superadmin` only by an existing `superadmin`.

#### Scenario: Superadmin assigns superadmin
- **WHEN** a superadmin creates or updates a user with role `superadmin`
- **THEN** the change is accepted

### Requirement: Auth scenarios covered by automated tests
Main authentication and authorization scenarios for this capability MUST be covered by Rails system and/or integration tests that run via `bin/rails test`.

#### Scenario: Test suite includes auth flows
- **WHEN** the phase test suite runs
- **THEN** it exercises login success, inactive denial, and role-gated user administration

