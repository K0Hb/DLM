# attachments Specification

## Purpose
Active Storage Disk photos on work orders and service lines with MVP limits.
## Requirements
### Requirement: Disk storage only
Photos MUST be stored with Active Storage Disk service (configurable root). S3 MUST NOT be required.

#### Scenario: Local disk service
- **WHEN** a photo is uploaded
- **THEN** it is stored on the configured disk path

### Requirement: Work order and line attachments
`WorkOrder` MUST allow up to 20 photos; `WorkOrderService` MUST allow up to 10. Formats MUST be JPEG, PNG, or WebP; each file MUST be ≤ 10 MB. Photos on complete are optional.

#### Scenario: Reject wrong type
- **WHEN** a user uploads a non-image or disallowed type to a line
- **THEN** the upload is rejected

#### Scenario: Reject over limit count
- **WHEN** a work order already has 20 photos
- **THEN** further uploads are rejected

### Requirement: Who can attach
Admin/superadmin MUST attach photos on the work-order card. The assignee (or admin) MUST attach photos on their line from the cabinet/line UI.

#### Scenario: Assignee attaches on own line
- **WHEN** an employee uploads a valid JPEG on their in-progress line
- **THEN** the photo is attached and visible on the line
