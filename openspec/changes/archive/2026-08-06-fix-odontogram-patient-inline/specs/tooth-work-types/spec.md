## Purpose

Admin-managed catalog of odontogram tooth work types, seeded with a default set, editable without code changes.

## ADDED Requirements

### Requirement: Admin manages tooth work types
Admin and superadmin MUST create, update, deactivate, and delete tooth work types (code + name). Employees MUST be denied.

#### Scenario: Admin creates type
- **WHEN** an admin creates a type with unique code and name
- **THEN** it appears in the odontogram type selector on work-order forms

### Requirement: Default types are seeded
The system MUST seed a default pool of common types (crown, pontic, veneer, etc.) on `db:seed`.

#### Scenario: Seed includes crown
- **WHEN** seeds run on an empty types table
- **THEN** a type with code `crown` exists
