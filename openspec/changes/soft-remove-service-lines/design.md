## Context

See proposal. Builds on hard-delete gate (`assigned` + unpaid). PaymentEvent uses `dependent: :nullify` on hard destroy.

## Goals / Non-Goals

**Goals:**
- Soft-remove for in_progress / completed / paid lines
- Active UI ignores `removed_at`; history (journal + payroll + earnings) keeps them

**Non-Goals:**
- Restore UI
- Auto-unpay on remove
- Purge job

## Decisions

1. Columns: `removed_at`, `removed_by_id` (optional User FK).
2. Explicit `scope :active` — no default_scope.
3. `WorkOrder#assigned_service_lines` → only active persisted lines.
4. `destroy` action: hard if `deletable?`, else soft if `removable?` (admin + not already removed + editable structure).
5. my_tasks: tasks tab `.active`; earnings tab includes removed completed.

## Risks / Trade-offs

- [Public page hides removed] → Intentional; composition is current truth
- [Payroll includes removed] → Intentional history preservation
