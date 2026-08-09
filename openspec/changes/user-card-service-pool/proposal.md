## Why

Отдельная вкладка «Пул услуг» (`/employee_skills`) дублирует карточку пользователя и расходится с продуктовым контрактом: пул должен задаваться на `/users/:id` (admin/superadmin). Сейчас в `spec.md` есть противоречие между §6.8 (карточка) и навигацией (только `/employee_skills`).

## What Changes

- Убрать навигацию и экраны `/employee_skills` (**BREAKING** для закладок на этот URL).
- Редактировать пул услуг сотрудника на карточке `/users/:id` (admin и superadmin).
- Согласовать `/spec.md` и OpenSpec `catalogs-and-skills` с этим UX.
- Обновить интеграционные тесты назначения пула.

## Capabilities

### New Capabilities

- (нет)

### Modified Capabilities

- `catalogs-and-skills`: назначение пула только через карточку пользователя; отдельный UI пула удаляется

## Impact

- Routes/controller/views/policy `employee_skills` удаляются
- `UsersController` + `users/show` принимают обновление `service_ids`
- Навигация layout, тесты `catalogs_test`, тексты в `spec.md` / `AGENT_PLAN` при необходимости
