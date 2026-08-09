## 1. Product contract

- [x] 1.1 Align `/spec.md` (remove `/employee_skills`-only nav rule; keep pool on `/users/:id` for admin/superadmin)
- [x] 1.2 Note in `docs/AGENT_PLAN.md` if P2 wording still points at a separate pool UI

## 2. User card pool UI

- [x] 2.1 Permit and apply `service_ids` on `UsersController#update` for employees without clearing pool on ordinary profile edits
- [x] 2.2 Replace read-only pool + link on `users/show` with admin/superadmin edit form (checkboxes); update create hint in `users/_form`
- [x] 2.3 Remove «Пул услуг» from application header navigation

## 3. Remove dedicated pool surface

- [x] 3.1 Remove `employee_skills` routes, controller, views, and `EmployeeSkillPolicy`

## 4. Tests

- [x] 4.1 Update integration tests: admin assigns pool via `user_path`; employee denied; no reliance on `employee_skills_path`
- [x] 4.2 Run `bin/rails test` for affected scenarios and fix failures
