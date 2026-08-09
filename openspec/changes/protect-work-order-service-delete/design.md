## Context

See proposal. Today `deletable?` is `!completed?`; confirm warns about in-progress/paid but does not block. `PaymentEvent` uses `dependent: :nullify`.

## Goals / Non-Goals

**Goals:**
- Hard-block delete unless `assigned` and unpaid
- Clear Russian alert when blocked

**Non-Goals:**
- Soft-delete / archive of lines
- Changing payment event retention
- Blocking whole work-order destroy separately (out of scope unless already constrained)

## Decisions

1. **`deletable?` → `assigned? && !technician_paid?`** — single gate for policy UI and model callback.
2. **One alert message** covering all blocked cases (in progress / completed / paid) so controller stays simple.
3. **Confirm helper** only for deletable lines (button already gated by `policy(line).destroy?`).

## Risks / Trade-offs

- [Admin must roll back in_progress → assigned before delete] → Intentional; preserves work history path
- [Paid assigned line stuck until unpaid] → Correct; force unpay via payment flow first
