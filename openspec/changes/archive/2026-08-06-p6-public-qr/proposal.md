## Why

Phase **P6**: public read-only work order page via `public_token`, QR code and copy-link on the admin card ([`spec.md`](../../../spec.md) §6.4, §6.7, §9 п.4; §10 п.10).

## What Changes

- Public GET `/o/:public_token` without login; full card content including money, formula, services, photos
- QR SVG + copy public URL on work-order show
- `public_token` already created on WorkOrder; no revoke/reissue
- Integration tests: anonymous access; unknown token 404; QR/link present for admin

## Non-goals

- Token rotation/revocation
- Auth-walled public variants
- PWA / SMS delivery of link

## Capabilities

### New Capabilities

- `public-work-order`: anonymous full read by token + QR/copy on admin card

### Modified Capabilities

- `work-orders`: show page gains QR block

## Impact

- Gem `rqrcode`; public controller/layout; Stimulus copy helper
