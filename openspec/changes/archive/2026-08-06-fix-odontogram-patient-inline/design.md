## Context

See proposal. Click bug: unescaped JSON in `data-odontogram-labels-value` breaks HTML attributes so Stimulus never binds.

## Decisions

1. Escape Stimulus data JSON via Rails `tag`/`json_escape` helpers.
2. `ToothWorkType`: `code` (unique slug), `name`, `active`, `position`; seed defaults; soft-deactivate preferred, hard delete if unused.
3. `Odontogram.normalize` validates type against `ToothWorkType` codes (allow inactive codes already stored).
4. Inline patient: virtual attrs `new_patient_full_name` on WorkOrder form; controller creates Patient before save when name present.

## Risks

- [Delete type used in old formulas] → Mitigation: prevent destroy if referenced in any dental_formula, or only allow deactivate.
