# public-work-order Specification

## Purpose
Anonymous full read of a work order via `public_token`, plus QR and copy-link on the admin work-order card.
## Requirements
### Requirement: Public page without login
GET `/o/:public_token` MUST work without authentication and show the full work-order content for reading: number, status, due, customer, doctor, patient, description, readonly odontogram, services with statuses/assignees/snapshot prices/amounts, customer payment fields, and photos.

#### Scenario: Anonymous opens valid token
- **WHEN** an anonymous user opens `/o/:public_token` for an existing work order
- **THEN** the page renders without requiring login and includes patient name and payment amount fields

### Requirement: Unknown token is not found
#### Scenario: Bad token
- **WHEN** an anonymous user opens `/o/not-a-real-token`
- **THEN** the response is 404

### Requirement: Token is stable
`public_token` MUST be created with the work order and MUST NOT be reissued or revoked in MVP.

### Requirement: QR and copy on admin card
The work-order show page for admin/superadmin MUST display a QR code for the public URL and a control to copy that URL.

#### Scenario: Admin sees public link tools
- **WHEN** an admin opens a work order show page
- **THEN** the page includes the public URL and a QR representation

### Requirement: Configurable public URL base
Public QR and copy-link URLs MUST use `PUBLIC_BASE_URL` (ENV, no trailing slash) when set; otherwise the host of the current HTTP request (`request.base_url`).

#### Scenario: Explicit base URL
- **WHEN** `PUBLIC_BASE_URL=https://dlm.example.com` is set
- **THEN** QR and copy-link on the work-order card use that host even if the admin opened the page via another host
