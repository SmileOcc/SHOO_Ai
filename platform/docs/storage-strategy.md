# SHOO Platform Storage Strategy

This document defines **where data lives** in the NestJS API and how to migrate domains over time.

## Migration ladder

```
Tier 1 — Mock JSON (AppDocument)     read-only parity with assets/mock
Tier 2 — Validated document CMS      admin GET/PUT + optional Zod/class-validator
Tier 3 — Prisma relational model     CRUD, user scoping, admin structured UI
```

New features should target **Tier 3** unless explicitly legacy/mock-only.

## Current map

| Domain | Tier | Storage | Admin |
|--------|------|---------|-------|
| Products, Banners | 3 | Prisma | Structured CRUD |
| Orders | 3 | Prisma + `order_logistics_catalog` doc | Orders page |
| Coupon templates / user claims | 3 | Prisma | Coupons page |
| Theme activities | 3 | Prisma `ThemeActivity` | Theme activities |
| Categories | 2 | Prisma `CategoryTree.payload` | Categories JSON |
| Reviews catalog | 1–2 | `AppDocument.reviews_catalog` | Reviews page |
| Search hot / fallback search | 1–2 | `AppDocument` | Search hot page |
| Flash sale catalog | 1–2 | `AppDocument.flash_sale_catalog` | Flash sale JSON |
| Legacy WebView activity | 1 | `activity_*` documents | Legacy activity tabs |
| Cart marquee, home feed | 2 | `AppDocument` | Home / cart marquee |

## Rules

1. **User-scoped data** (orders, coupons, follows) → Prisma with `userId`; App routes use `UserAuthGuard`.
2. **Shared CMS blobs** (marketing copy, catalogs) → `AppDocument` until a relational model is justified.
3. **Single source for defaults** — e.g. coupon IDs in `coupon-registry.ts`, imported by service + seed.
4. **Do not add new hardcoded defaults** in seed and service separately.

## API conventions

- App: `GET/POST /api/v1/{resource}`
- Admin: `GET/PUT /api/admin/v1/{domain}/{resource}`
- Admin PUT body: raw JSON or `{ "payload": ... }` — use `unwrapPayload()` in controllers.

## Next migrations (suggested order)

1. `reviews_catalog` → Prisma `Review` (optional; large catalog)
2. `order_logistics_catalog` → `OrderLogistics` table keyed by `orderId`
3. `flash_sale_catalog` → structured Prisma + admin forms (keep JSON export)
4. Deprecate legacy `activity_*` documents when all traffic uses ThemeActivity
