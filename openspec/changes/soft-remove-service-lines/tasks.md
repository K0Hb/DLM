## 1. Spec and contract

- [x] 1.1 Write OpenSpec artifacts; update `/spec.md` §4.7 hard vs soft-remove

## 2. Data and domain

- [x] 2.1 Migration `removed_at`, `removed_by_id`; model scopes, `removable?`, `soft_remove!`
- [x] 2.2 `WorkOrder#assigned_service_lines` and ready checks use active lines only

## 3. Controller and UI

- [x] 3.1 Branch destroy hard/soft; policy destroy?; confirm copy
- [x] 3.2 Filter active lines on public/show; my_tasks tasks vs earnings

## 4. Tests

- [x] 4.1 Integration coverage for hard, soft completed+paid, history, ready
