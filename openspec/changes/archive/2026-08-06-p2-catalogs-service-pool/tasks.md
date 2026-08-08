## 1. Models

- [ ] 1.1 Migrations: customers, doctors, patients, services, services_users
- [ ] 1.2 Models + validations; User `has_and_belongs_to_many :services`

## 2. Authorization and UI

- [ ] 2.1 Pundit policies for catalogs and employee skills (admin+superadmin)
- [ ] 2.2 Controllers/views CRUD for four catalogs (Russian, utilitarian)
- [ ] 2.3 Employee skills index/edit for service pool
- [ ] 2.4 Nav links; optional services on superadmin user form

## 3. Tests

- [ ] 3.1 Fixtures for catalog records
- [ ] 3.2 Integration: admin CRUD service/customer; employee denied; assign pool
- [ ] 3.3 System: admin creates service (rack_test)

## 4. Verify

- [ ] 4.1 `bin/rails test` green; archive change
