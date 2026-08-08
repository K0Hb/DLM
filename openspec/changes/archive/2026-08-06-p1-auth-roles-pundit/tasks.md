## 1. Gems and Devise setup

- [x] 1.1 Add `devise` and `pundit` gems; bundle install
- [x] 1.2 Install Devise (initializer, locale); migrate User from `password_digest` to Devise fields
- [x] 1.3 Configure User Devise modules; `active_for_authentication?` for `active`
- [x] 1.4 Update `db/seeds.rb` for Devise; keep ENV superadmin defaults

## 2. Authorization and UI

- [x] 2.1 Wire Pundit in ApplicationController; authenticate_user!; handle NotAuthorizedError
- [x] 2.2 Implement UserPolicy (superadmin-only manage)
- [x] 2.3 UsersController + Russian views (index/new/create/edit/update) for superadmin
- [x] 2.4 Navigation/flash on layout; root requires login; health `/up` stays public

## 3. Scenario tests

- [x] 3.1 Test helpers/fixtures for users of each role
- [x] 3.2 Integration tests: redirect to login; inactive cannot sign in; employee/admin forbidden on users
- [x] 3.3 System tests: successful login; superadmin creates user
- [x] 3.4 Expose Postgres port (or document test DB) so `bin/rails test` can run against compose

## 4. Verify

- [x] 4.1 Rebuild/restart Docker stack; manual smoke login
- [x] 4.2 `bin/rails test` green for P1 scenarios
