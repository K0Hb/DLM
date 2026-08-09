## 1. Spec

- [x] 1.1 Document delete rules in `/spec.md` (§4.7 / show card services)

## 2. Domain + UI

- [x] 2.1 Tighten `WorkOrderService#deletable?` and destroy guard; update controller alert
- [x] 2.2 Simplify delete confirm copy for remaining deletable cases

## 3. Tests

- [x] 3.1 Integration: allow assigned unpaid delete; reject in_progress, paid, completed
- [x] 3.2 Run affected `bin/rails test`
