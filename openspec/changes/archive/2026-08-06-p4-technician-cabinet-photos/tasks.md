## 1. Active Storage
- [x] 1.1 Migrate Active Storage tables; confirm Disk root via `ACTIVE_STORAGE_ROOT`
- [x] 1.2 `has_many_attached :photos` on WorkOrder and WorkOrderService + validations (§4.8)
- [x] 1.3 Upload/purge UI on work-order show (admin) and my_task show

## 2. Technician cabinet
- [x] 2.1 Routes `/my_tasks`, controller, policy scope to assignee
- [x] 2.2 Index: filters status + period; list lines; optional completed sum
- [x] 2.3 Show: order summary, formula read-only summary, start/complete, photos
- [x] 2.4 Nav link for employees; home hint

## 3. Docs & tests
- [x] 3.1 Living OpenSpec specs `technician-cabinet`, `attachments`; update AGENT_PLAN
- [x] 3.2 Integration tests: employee sees only own lines; start/complete; photo reject wrong type; admin can attach on work order
- [x] 3.3 System suite remains green (rack_test)
