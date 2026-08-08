# План разработки DLM для агента

Источник требований: [`spec.md`](../spec.md).  
Процесс изменений: OpenSpec (`/opsx:propose` → review → `/opsx:apply` → `/opsx:archive`).  
Не реализовывать пункты из §2 и §11 спеки.

Каждая фаза — отдельный OpenSpec change. Не сливать P0–P6 в один промпт.

```text
P0 → P1 → P2 → P3 → P4 → P5 → P6 → P7 → P8
```

## Политика тестов (обязательно с P1)

Основные пользовательские сценарии фазы **должны** быть зафиксированы автоматизированными тестами:

- предпочтительно **system** (Capybara + headless Chrome) — e2e через UI;
- либо **integration** (`ActionDispatch::IntegrationTest`) — HTTP-потоки, если UI ещё тонкий;
- unit/model — для доменной логики, не вместо сценариев.

Фаза не завершена, пока ключевые сценарии приёмки не зелёные в `bin/rails test`.

---

## P0 — Bootstrap (Docker + Rails + seed)

**Статус:** сделано.

**Цель:** поднимаемый каркас приложения без доменной логики нарядов.

**Сделать:**
- Rails 8 app (Ruby 3.4+), PostgreSQL, locale/`I18n` `ru`, timezone как в спеке
- Docker Compose: `app`, `postgres`, volume для Active Storage Disk
- Active Storage (Disk), путь через ENV/volume
- Готовность к HTTPS: `force_ssl` / trust proxy по ENV (по умолчанию выкл.)
- `db:seed`: пользователь `superadmin` (email/пароль из ENV или безопасные dev-дефолты в README)
- `bin/dev` допустим для локальной разработки без Docker

**Приёмка:** `docker compose up` стартует на Unix и Windows (Docker Desktop); seed создаёт superadmin; пустой корень приложения открывается.

**Спека:** §8, §9 п.1–2, 8–9; §10 п.1 (seed), п.11 (часть — storage/docker).  
**OpenSpec living:** `platform-bootstrap`.

---

## P1 — Auth + роли + Pundit

**Статус:** сделано.

**Цель:** вход и матрица прав §3.

**Сделать:**
- Devise (email + пароль), блокировка `active=false`
- Роли `superadmin` | `admin` | `employee`
- Pundit policies по таблице §3 (заглушки экранов ок, если ещё нет сущностей)
- Экран управления пользователями для superadmin (§6.8) — минимум: список/создание/роль/active/сброс пароля
- **Тесты:** system/integration — логин, отказ inactive, employee без доступа к пользователям, superadmin CRUD пользователей

**Приёмка:** §10 п.1 + зелёные тесты сценариев выше.

**Спека:** §3, §6.1, §6.8.  
**OpenSpec living:** `auth-roles`.

---

## P2 — Справочники + пул услуг

**Статус:** сделано.

**Цель:** CRUD доменных справочников и skills pool.

**Сделать:**
- Customer, Doctor, Patient, Service (§4.2–4.5)
- UI CRUD (§6.5)
- Привязка пула услуг к User
- Врачи: без фильтрации по customer на наряде (поле `customer_id` опционально)

**Приёмка:** §10 п.2–3.

**Спека:** §4.2–4.5, §6.5.  
**OpenSpec living:** `catalogs-and-skills`.

---

## P3 — Наряды, статусы, odontogram, оплата

**Статус:** сделано (включая доработки UX: конфиг типов/материалов/shades в `config/odontogram.yml`, клик/Ctrl+копирование, connectors вручную, SVG tooth bow, поиск по пациенту, «Описание», локальные шрифты).

**Цель:** основной admin-поток наряда.

**Сделать:**
- WorkOrder + WorkOrderService (§4.6–4.7)
- `patient_id` **опционален** (P8); `number` — последовательный integer
- Статусы вперёд и откаты (§5.1, §5.1.1, §5.2, §5.2.1)
- Правила: ≥1 услуга для `ready`/`sent`/`closed`; все строки `completed`
- Odontogram JSONB + UI (§4.9, §6.4) — типы/материалы из YAML, не CRUD в БД
- Оплата заказчиком: сумма к оплате на форме наряда; факт — через подтверждение (P7)
- Список нарядов + фильтры/поиск по пациенту + ссылки на карточку (§6.3), доставка `ready` → `sent` (§6.6)
- Назначение исполнителя только из пула; смена assignee только в `assigned`
- Inline-создание пациента в форме наряда

**Приёмка:** §10 п.4, 6, 8, 9.

**Спека:** §4.6–4.7, §4.9, §5, §6.3–6.4, §6.6.  
**OpenSpec living:** `work-orders`, `tooth-work-types` (odontogram config).

---

## P4 — Личный кабинет техника + фото

**Статус:** сделано.

**Цель:** employee flow и вложения.

**Сделать:**
- ЛК `/my_tasks` (§6.2): свои строки, фильтры статус/период, «Взять в работу» / «Выполнено»
- Своя сумма за период по фильтру; чужие назначения — нельзя
- Active Storage Disk фото на WorkOrder (≤20) и WorkOrderService (≤10), JPEG/PNG/WebP ≤10 MB (§4.8)

**Приёмка:** §10 п.5, 11 (storage/disk часть).

**Спека:** §4.8, §6.2.  
**OpenSpec living:** `technician-cabinet`, `attachments`.

---

## P5 — Отчёты

**Статус:** сделано.

**Цель:** отчёты admin/superadmin.

**Сделать:**
- `/reports` — хаб; наряды за период (§7.1) + CSV (UTF-8 BOM, `;`, CRLF для Excel)
- Оплата труда техников (§7.2) — только `completed` по `completed_at`; откат убирает из начислений
- Неоплаченные заказчиком (§7.3)

**Приёмка:** §10 п.7, 12.

**Спека:** §5.3, §7.  
**OpenSpec living:** `reports`.

---

## P6 — QR + публичная страница

**Статус:** сделано.

**Цель:** публичный read-only просмотр.

**Сделать:**
- `public_token` при создании наряда
- QR на карточке (`rqrcode` SVG) + копирование ссылки (Stimulus clipboard)
- `/o/:public_token` — полный read включая деньги, формулу, услуги, фото (§6.7)
- Без отзыва/перевыпуска токена

**Приёмка:** §10 п.10.

**Спека:** §6.4 (QR), §6.7, §9 п.4.  
**OpenSpec living:** `public-work-order`.

---

## Статус MVP (P0–P6) + P7–P8

Фазы P0–P6 (MVP), **P7** (оплаты) и **P8** (связи пациент/врач/заказчик + карточки) реализованы и заархивированы в OpenSpec. Приёмка MVP — [`spec.md`](../spec.md) §10; P7 — §10.1.

### UI polish (post-P8, в коде)

- Списки: `record_link` + кнопка «Открыть»; «Изменить» только на show / edit.
- Услуги: show-карточка; удаление с show, не из index.
- Оплаты admin: `/technician_payouts`, `/customer_payment_orders`, навигация в шапке; журналы — `_payment_event_tabs`.
- `customer_payment_amount` — сумма к оплате заказчиком (≠ сумма услуг технику); ручной ввод на подтверждении.
- Карточки заказчик/врач/пациент: таблицы нарядов с «Сумма оплаты» и «Открыть».
- ЛК employee: `/my_tasks` с вкладками «Задачи» / «Начисления»; `/my_earnings` → redirect; admin не заходит в ЛК.
- Наряд show: двухколоночный layout, read-only odontogram справа; employee — read-only show при своих услугах.
- Odontogram: 9 типов / 7 материалов; группировка «Выбранные зубы»; legacy type aliases.
- Layout: `.app-shell` до ~1600px для header и main.

---

## P7 — Факты оплаты (исполнитель + заказчик) + журнал

**Статус:** done (2026-08-07). OpenSpec: `openspec/changes/archive/2026-08-07-p7-payment-events/` → `openspec/specs/payments/`.

**Цель:** фиксировать в системе **факты** выплат исполнителям и оплат заказчиком (деньги люди переводят вне DLM), с подтверждением, журналом и отчётами исполнителя.

**Сделано:**
- Поля выплаты на `WorkOrderService` (`technician_paid`, `technician_paid_at`, `technician_paid_by_id`) + правила §5.4
- Оплата заказчиком: наряд целиком; подтверждение §6.9; экран «Оплаты заказчиков»; `customer_payment_amount`; суммы вручную (не из услуг)
- `PaymentEvent` append-only (§4.10); журнал §6.10
- ЛК: фильтры/бейджи/«Я получил оплату»; лимит 30 дней (override superadmin)
- Отчёт исполнителя §7.4; зелёный/красный бейджи §6.11
- Integration-тесты по §10.1 (`test/integration/payments_test.rb`)

**Приёмка:** [`spec.md`](../spec.md) §10.1.

**Спека:** §3 (матрица), §4.6–4.7, §4.10, §5.4, §6.2, §6.4, §6.9–6.11, §7.2–7.4.  
**OpenSpec:** archived `p7-payment-events`.

**Не делали в P7:** касса, банк, возвраты, частичные оплаты, несколько платежей на объект, PDF-ведомления, автосумма из услуг технику.

**Post-P7 UI:** экраны `/technician_payouts`, `/customer_payment_orders`; поле `customer_payment_amount`; employee начисления — вкладка в `/my_tasks` (`/my_earnings` → redirect).

---

## P8 — Связи пациент/врач/заказчик + карточки справочников

**Статус:** done (2026-08-07). OpenSpec: `openspec/changes/archive/2026-08-07-p8-catalog-parties/` → `openspec/specs/catalogs-parties/`.

**Сделано:**
- У пациента обязательный `doctor_id`; у врача `customer_id` опционален
- На наряде пациент и врач опциональны (заказчик обязателен)
- Show-карточки пациентов/врачей/заказчиков со связанными нарядами
- Inline-пациент на форме наряда только с врачом

**Спека:** §4.3–4.6, §6.5.  
**Не делали:** кабинет клиники/врача, жёсткая фильтрация врачей по заказчику наряда.

---

## Как вести фазу в OpenSpec

1. Прочитать соответствующие §§ `spec.md` и этот файл.
2. В чате: `/opsx:propose <slug-фазы>` (например `p0-docker-rails-seed`).
3. Проверить proposal / delta specs / tasks.
4. `/opsx:apply` — реализовать чеклист.
5. `/opsx:archive` — влить delta в `openspec/specs/`.

`spec.md` не заменяется OpenSpec: продукт-контракт остаётся в корне; OpenSpec накапливает поведенческие specs по доменам по мере archive.
