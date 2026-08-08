## Context

See proposal. Build domain logic in models; keep UI utilitarian with Hotwire/Stimulus odontogram.

## Goals / Non-Goals

**Goals:** full admin work-order path for P3 acceptance.  
**Non-Goals:** tech cabinet, photos, QR, reports, visual design.

## Decisions

1. Status transition methods on `WorkOrder` / `WorkOrderService` (explicit, testable).
2. `number` via DB sequence or `WorkOrder.maximum(:number).to_i + 1` in transaction.
3. Odontogram: validate against `Odontogram::TYPES` and FDI set; Stimulus toggles teeth.
4. Nested attributes or separate endpoints for lines — separate `WorkOrderServicesController` under work order for clarity.
5. Filters on index: status, customer, patient, payment flag (minimal set).
6. Delivery: `DeliveriesController#index` + `mark_sent`.

## Risks / Trade-offs

- [Complex status matrix] → Mitigation: centralized transition methods + integration tests.
