## Context

P0–P3 deliver auth, catalogs, and admin work-order flow. Employees currently have no cabinet; Active Storage is configured but tables were not migrated until P4.

## Decisions

1. **Cabinet route:** `/my_tasks` (index + show) scoped to `assignee_id = current_user`. Admins keep managing lines on the work-order card; they MAY also open cabinet only if they are assignee (rare) — MVP: cabinet is for `employee` role primarily, admins use work-order UI.
2. **Transitions:** reuse `WorkOrderService#start!` / `#complete!` with actor checks; cabinet calls them after Pundit `start?` / `complete?`.
3. **Photos:** `has_many_attached :photos` on both models; shared validation concern for content type, size, count. Upload from work-order show (admin) and my_task show (assignee/admin).
4. **Period filter:** `completed_at` / `started_at` / `created_at` window via `from`/`to` date params (date inclusive).
5. **Own sum:** show sum of `amount` for completed lines in filtered period on cabinet index — not lab reports.

## Risks

- Attachment validation after direct upload races — MVP uses standard form multipart only.
- Large files — enforce 10 MB server-side.
