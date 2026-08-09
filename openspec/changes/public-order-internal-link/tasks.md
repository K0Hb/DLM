## 1. Spec

- [x] 1.1 Update `/spec.md` §6.7: signed-in users with access get a link to the internal work order from the public page; anonymous get «Войти»

## 2. UI

- [x] 2.1 Add «Открыть наряд» on `public_orders/show` when `user_signed_in?` and `policy(@work_order).show?`
- [x] 2.2 Add «Войти» → sign-in for anonymous visitors

## 3. Tests

- [x] 3.1 Integration: anonymous has sign-in link and no internal link; assigned employee and admin see link to `work_order_path`
- [x] 3.2 Run `bin/rails test` for public order scenarios
