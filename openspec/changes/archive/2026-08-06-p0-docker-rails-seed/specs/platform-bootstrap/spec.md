## Purpose

Defines the runnable platform bootstrap for DLM: Docker Compose stack, Disk file storage configuration, Russian locale defaults, optional HTTPS toggles, initial superadmin seed, and a healthy root page before domain features land.

## ADDED Requirements

### Requirement: Docker Compose stack boots the application
The system MUST provide a Docker Compose configuration that starts the web application and PostgreSQL together so a client can run the stack on Windows (Docker Desktop) or Unix.

#### Scenario: Fresh compose up
- **WHEN** an operator runs `docker compose up` (or equivalent) with the provided compose file and builds images as needed
- **THEN** the PostgreSQL service becomes healthy and the application service starts listening for HTTP requests

#### Scenario: Persistent database data
- **WHEN** the compose stack is stopped and started again without removing named volumes
- **THEN** PostgreSQL data from the previous run is still available

### Requirement: Active Storage uses configurable Disk root
The system MUST store Active Storage blobs on local Disk using a configurable path (ENV and/or Docker volume), not a hardcoded Unix-only absolute path and not S3.

#### Scenario: Storage root from environment
- **WHEN** `ACTIVE_STORAGE_ROOT` (or equivalent documented ENV) is set to a writable directory or volume mount
- **THEN** Active Storage Disk service uses that path for blob files

### Requirement: Russian locale and currency defaults
The application MUST default to Russian locale (`ru`) and display currency as ₽ where money formatting is configured for the platform.

#### Scenario: Default locale
- **WHEN** the application boots without an overriding locale ENV
- **THEN** the default locale is `ru`

### Requirement: Optional HTTPS readiness
The system MUST support enabling HTTPS-related Rails settings via environment variables while keeping HTTPS off by default for LAN/HTTP use.

#### Scenario: HTTPS disabled by default
- **WHEN** no HTTPS-enabling ENV is set
- **THEN** the application serves over HTTP without forcing SSL redirect

#### Scenario: HTTPS enabled via ENV
- **WHEN** the documented HTTPS ENV flag is enabled (e.g. behind a reverse proxy)
- **THEN** the application applies SSL-forcing / proxy-trust settings appropriate for that mode

### Requirement: Seed creates initial superadmin
Running database seeds MUST create at least one user with role `superadmin` using email and password from ENV or documented development defaults.

#### Scenario: Seed on empty database
- **WHEN** an operator runs `db:seed` (or the compose entrypoint equivalent) on a migrated empty database
- **THEN** a user with role `superadmin` exists and can authenticate with the seeded credentials once auth (P1) is available

#### Scenario: Seed is idempotent for the default superadmin
- **WHEN** seed is run twice with the same default superadmin email
- **THEN** the system does not fail due to duplicate key; one superadmin with that email remains

### Requirement: Root page confirms the app is up
The application MUST respond to `GET /` with a successful HTML page indicating DLM is running (placeholder until feature UI arrives).

#### Scenario: Root request
- **WHEN** a client requests `GET /`
- **THEN** the response status is 200 and the body identifies the DLM application
