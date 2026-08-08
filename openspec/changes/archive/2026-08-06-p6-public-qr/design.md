## Decisions

1. **URL:** `/o/:public_token` → `PublicOrdersController#show`, named route `public_order_path`.
2. **Auth:** `skip_before_action :authenticate_user!`; no Pundit (public by token possession).
3. **QR:** `rqrcode` SVG embedded on work-order show; absolute URL via `default_url_options` / `request.base_url`.
4. **Copy:** Stimulus `clipboard` controller with `navigator.clipboard.writeText`.
5. **Photos:** lightbox preview + download links; no delete on public page.
6. **404:** unknown/missing token → not found.
