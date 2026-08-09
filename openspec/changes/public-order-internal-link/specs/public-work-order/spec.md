## MODIFIED Requirements

### Requirement: Public page without login
GET `/o/:public_token` MUST work without authentication and show the full work-order content for reading: number, status, due, customer, doctor, patient, description, readonly odontogram, services with statuses/assignees/snapshot prices/amounts, customer payment fields, and photos.

#### Scenario: Anonymous opens valid token
- **WHEN** an anonymous user opens `/o/:public_token` for an existing work order
- **THEN** the page renders without requiring login and includes patient name and payment amount fields

### Requirement: Signed-in user can open internal work order from public page
When a signed-in user who is allowed to view the work order internally (`WorkOrderPolicy#show?`) opens the public page, the page MUST show a control linking to the internal work-order show (`/work_orders/:id`). Signed-in users without internal show access MUST NOT see that control.

#### Scenario: Assigned employee sees internal link
- **WHEN** a signed-in employee who is an assignee on the order opens `/o/:public_token`
- **THEN** the page includes a link to `/work_orders/:id` for that order

#### Scenario: Admin sees internal link
- **WHEN** a signed-in admin opens `/o/:public_token`
- **THEN** the page includes a link to `/work_orders/:id` for that order

#### Scenario: Anonymous has no internal link
- **WHEN** an anonymous user opens `/o/:public_token`
- **THEN** the page does not include a link to the internal work-order show

### Requirement: Anonymous visitor can sign in from public page
When an anonymous visitor opens the public page, the page MUST show a control linking to the sign-in page. The public content MUST remain readable without signing in.

#### Scenario: Anonymous sees sign-in button
- **WHEN** an anonymous user opens `/o/:public_token`
- **THEN** the page includes a link to the sign-in page
