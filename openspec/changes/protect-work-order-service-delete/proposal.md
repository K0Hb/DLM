## Why

Admin can delete `assigned` / `in_progress` service lines even when work has started or the technician was already marked paid. That erases payroll visibility while orphaning payment events. Deletion must protect in-progress work and paid facts.

## What Changes

- Allow deleting a work-order service line only when status is `assigned` **and** `technician_paid` is false.
- Forbid delete for `in_progress`, `completed`, or any paid line (`technician_paid`).
- Align `/spec.md` and OpenSpec `work-orders`; update controller messages, confirm helper, and tests.

## Capabilities

### New Capabilities

- (нет)

### Modified Capabilities

- `work-orders`: stricter rules for deleting service lines from an order

## Impact

- `WorkOrderService#deletable?` / `before_destroy`
- `WorkOrderServicesController#destroy`
- Confirm copy in helper; `work_orders_test`
- Product contract §4.7 / §6.4
