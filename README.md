# DLM — Dental Lab Manager

[![CI](https://github.com/K0Hb/DLM/actions/workflows/ci.yml/badge.svg?branch=develop)](https://github.com/K0Hb/DLM/actions/workflows/ci.yml)
[![Ruby](https://img.shields.io/badge/Ruby-3.4-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.0-red.svg)](https://rubyonrails.org/)

Веб-сервис для зуботехнической лаборатории: наряды, работа техников и оплаты — в одном месте, с телефона и с компьютера.

## Что умеет

- Ведёт **заказ-наряды** от приёма до отправки и закрытия: клиника, пациент, врач, срок, статус
- Назначает **услуги исполнителям**, считает начисления по ставкам и не даёт закрыть наряд с незавершённой работой
- Хранит **зубную формулу** прямо в наряде — удобно смотреть техникам и на публичной карточке
- Даёт сотруднику **личный кабинет**: свои задачи, суммы и отметку «я получил оплату»
- Фиксирует **оплаты** лаборатории (техникам и от заказчиков) с понятными журналами — без кассы и банка
- Строит **отчёты** по нарядам, зарплате и долгам заказчиков
- Делится нарядом по **ссылке или QR** — клиника видит статус и состав без входа в систему
- Разделяет доступ: администратор ведёт лабораторию, сотрудник — только свою работу

## Стек

- Ruby 3.4.4 (`.ruby-version`)
- Rails 8.0
- PostgreSQL 16
- Hotwire (Turbo, Stimulus), importmap
- Tailwind CSS (`tailwindcss-rails`)
- Devise, Pundit, Active Storage (Disk), rqrcode
- Docker Compose

## Быстрый старт

### Docker

```bash
cp .env.example .env
docker compose up --build
```

Приложение: http://localhost:3000
Учётная запись после seed: `admin@example.com` / `changeme123`.

### Локально

```bash
cp .env.example .env
bundle install
docker compose up -d db
bin/rails db:prepare db:seed
bin/rails s -b 0.0.0.0 -p 3000   # или bin/dev
```

## Хранение файлов

Загрузки идут в Active Storage (Disk).

| Режим | Каталог | Переменная |
|---|---|---|
| Docker Compose | путь на хосте → `/rails/storage` | `HOST_STORAGE_PATH` (по умолчанию `./storage`) |
| Локальный сервер | каталог приложения | `ACTIVE_STORAGE_ROOT` (по умолчанию `storage/`) |

После смены пути перезапустите процесс приложения.

## Резервное копирование

```bash
bin/backup
KEEP_BACKUPS=8 bin/backup
```

Дамп PostgreSQL сохраняется в `backups/<метка>/`. Примеры cron и восстановления — в шапке `bin/backup`.

## Тесты

```bash
export POSTGRES_HOST=localhost POSTGRES_USER=dlm POSTGRES_PASSWORD=dlm
bin/rails test
```

## Доступ из локальной сети (Windows 11 + WSL2)

Разово:

1. `C:\Users\<Вы>\.wslconfig` → `networkingMode=mirrored`, `firewall=false`, затем `wsl --shutdown`
2. PowerShell **от администратора:**
   ```powershell
   New-NetFirewallRule -DisplayName "DLM Rails 3000" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow -Profile Any
   ```

Запуск: `bin/rails s -b 0.0.0.0 -p 3000`

- на этом ПК — http://localhost:3000
- с телефона / других устройств в той же Wi‑Fi — http://\<IP-ПК\>:3000

**Как узнать IP ПК (Windows).** В обычном PowerShell:

```powershell
(Get-NetIPAddress -InterfaceAlias "Беспроводная сеть" -AddressFamily IPv4).IPAddress
```

Если адаптер называется иначе (часто `Wi-Fi`):

```powershell
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "192.168.*" } | Format-Table InterfaceAlias, IPAddress
```

Нужен адрес вида `192.168.x.x` у Wi‑Fi.

На карточке наряда есть **QR и ссылка** для просмотра без входа. Чтобы они открывались с телефона, в `.env` укажите `PUBLIC_BASE_URL=http://<IP-ПК>:3000` и перезапустите сервер.

