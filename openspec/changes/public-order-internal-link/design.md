## Context

See proposal. Public show already skips auth; Devise still populates `current_user` when a session exists. Internal start/complete for admin lives on `work_orders#show`; employee reaches actions via «Моя задача» / `/my_tasks/:id` from that page.

## Goals / Non-Goals

**Goals:**
- One clear CTA on the public page for eligible signed-in users → internal `work_orders#show`
- Keep anonymous UX unchanged

**Non-Goals:**
- Changing public content or token rules
- Performing start/complete on the public page itself
- Deep-link directly to `/my_tasks/:id` (extra hop via «Моя задача» is acceptable)

## Decisions

1. **Gate with `user_signed_in? && policy(@work_order).show?`** — reuse existing Pundit rules; no new policy.
2. **Always target `work_order_path`** — matches «страница наряда»; employee then uses existing «Моя задача» for start/complete.
3. **Anonymous CTA:** «Войти» → `new_user_session_path` (same primary button style); content still fully readable.
4. **Label for signed-in:** «Открыть наряд» — short Russian CTA near the header.

## Risks / Trade-offs

- [Employee needs one more click to my_task] → Acceptable; keeps one destination for all roles
- [Pundit on public controller] → `policy` works with current_user; anonymous `show?` is false
