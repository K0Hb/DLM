# odontogram-tooth-types Specification

## Purpose
Odontogram tooth work types, materials, and shades are configured in code (`config/odontogram.yml`). Shade is order-level from a fixed list; material is chosen per tooth from a fixed dropdown. Chart selection does not auto-fill type/material unless copying with Ctrl.
## Requirements
### Requirement: Types come from YAML config
Tooth types MUST be defined in `config/odontogram.yml` with `code`, `name`, and `color`. There MUST NOT be an admin CRUD catalog table for types. The MVP set MUST include exactly these nine types: `antagonist`, `healthy`, `crown`, `coping`, `veneer`, `inlay`, `abutment`, `missing`, `bridge`.

#### Scenario: Crown type available
- **WHEN** the odontogram type selector is rendered
- **THEN** it includes the types from the YAML config (including `crown` and `healthy`)

### Requirement: Materials come from YAML config
Tooth materials MUST be defined in `config/odontogram.yml` with `code` and `name`. UI MUST offer materials only via select (no free-text material). The MVP set MUST include: `zirconia` (Zr), `emax`, `cocr`, `titanium` (Ti), `pmma`, `pfm` (Металлокерамика), `precious` (Драгоценный сплав). Unknown material codes MUST be cleared (tooth kept).

#### Scenario: Material select options
- **WHEN** the odontogram material selector is rendered
- **THEN** it lists materials from YAML (including `zirconia`) plus an empty “not selected” option

#### Scenario: Free-text material rejected
- **WHEN** an admin saves a tooth with material value not in the config
- **THEN** that tooth keeps its type but material is stored as null

### Requirement: Legacy type codes mapped on read
Legacy type codes from earlier config versions (e.g. `pontic`, `inlay_onlay`) MUST map to current codes for display and normalization.

#### Scenario: Pontic displays as bridge
- **WHEN** a stored formula contains tooth type `pontic`
- **THEN** the UI shows the bridge label and color

### Requirement: Shades come from YAML config
Order-level tooth color (`dental_formula.shade` / `tooth_color`) MUST be a code from `config/odontogram.yml` `shades` (or null). UI MUST offer shade only via select (no free-text shade). Unknown shade codes MUST be cleared.

#### Scenario: Shade select options
- **WHEN** the odontogram shade selector is rendered
- **THEN** it lists shades from YAML (including `A2`) plus an empty “not selected” option

#### Scenario: Free-text shade rejected
- **WHEN** an admin saves odontogram with shade not in the config
- **THEN** shade is stored as null

### Requirement: Click selects without auto-assign; Ctrl copies
A plain click on a new tooth MUST select it with `type: null` and `material: null`. Type/material MUST be set via the top selects for the active tooth. Ctrl/Cmd+click MUST copy parameters from the active (or last parameterized) tooth. The summary list under the chart MUST be read-only (type and material labels only).

#### Scenario: Plain click leaves nulls
- **WHEN** an admin clicks an unselected tooth without Ctrl
- **THEN** the tooth is stored with null type and null material

#### Scenario: Ctrl click copies params
- **WHEN** a tooth has type/material set and the user Ctrl+clicks another tooth
- **THEN** the new tooth receives the same type and material

### Requirement: Grouped summary list
The read-only summary list MUST group teeth with the same type and material into one row. Tooth numbers in a group MUST use compact ranges for consecutive FDI numbers (e.g. `12–13`, `31–38, 41–48`).

#### Scenario: Same type and material grouped
- **WHEN** teeth 12 and 13 both have type abutment and material cocr
- **THEN** the summary shows one row `12–13` with that type and material

### Requirement: Order shade and per-tooth material
`dental_formula.shade` MUST be the common color for the work order (from config). Each tooth MAY have its own `material` code from the config (or null). Type MAY be null until assigned.

#### Scenario: Save shade and material
- **WHEN** an admin saves odontogram with shade A3 and tooth 21 type veneer material `emax`
- **THEN** the JSON stores shade A3 and that tooth with material `emax`

### Requirement: Chart shows type color on selection
Selected teeth with a type MUST use the configured type color on a DentalDB-like SVG tooth bow. Selected teeth without a type MUST use a distinct untyped highlight. Active tooth MUST be visually emphasized. Adjacent selected teeth MAY show connector toggles (off/grey by default; click to enable/green). Connectors MUST NOT be auto-enabled.

#### Scenario: Selected tooth colored
- **WHEN** a tooth is assigned type crown
- **THEN** its chart button uses the crown color from config
