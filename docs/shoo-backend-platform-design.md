# SHOO Backend Platform Design

> **Version**: v0.2 (P0 implementation in progress)  
> **Date**: 2026-07-29  
> **Status**: P0 scaffold implemented under `platform/` (NestJS + Prisma + React Admin)  
> **Scope**: Local ops platform for managing SHOO App data & serving App APIs; cloud-ready  
> **Related**: `platform/README.md`, `server/README.md`, `lib/core/network/hos_mock_route_registry.dart`, `docs/Flutter主题活动ThemeActivity技术方案.md`

---

## 1. Goals

Build a **local Backend Platform** that:

1. **Serves the App** — replace in-app Mock / file Mock Server with real HTTP APIs (same contract).
2. **Manages the App** — Admin Console CRUD for catalog, marketing, orders, users, configs.
3. **Stays compatible** — keep App envelope `{ code, message, data }` and paths under `/api/v1/...` so App only switches `API_BASE_URL` / `ENV=local`.
4. **Scales to cloud** — same codebase deploys to staging/prod with env configs (Docker / K8s ready).

**Out of scope (for now):**

- App-internal debug / toolbox demos (media player, contacts demo, study toys, native component labs).
- Real third-party payment / SMS / logistics carriers (interfaces reserved; local uses simulated adapters).

---

## 2. App Capability Inventory (Production)

Derived from `lib/features/` (toolbox entertainment skipped).

### 2.1 User-facing domains

| Domain | App feature | Primary APIs today | Admin need |
|--------|-------------|--------------------|------------|
| **Catalog** | `home`, `category`, `product`, `search` | `/banners`, `/products`, `/products/{id}`, `/categories`, `/search`, `/search/hot` | Product / SKU / Category / Banner / Hot keywords |
| **Trade** | `cart`, `checkout`, `order`, `after_sale` | `/orders`, `/orders/{id}/pay`, logistics, `/after-sales` | Order ops, pay simulate, logistics, after-sale |
| **User** | `auth`, `profile`, `address`, `coupon`, `message` | `/auth/*`, `/addresses`, `/coupons`, `/messages` | Users, addresses, coupons, inbox |
| **Marketing** | `flash_sale`, `activity_webview`, home popup, cart marquee | `/flash-sale/*`, `/activity/*`, `/marketing/*` | Flash sale, H5 activity, popup, marquee, **ThemeActivity** (planned) |
| **Content** | `community`, `review` | `/community/feed`, `/products/{id}/reviews` | Posts, reviews moderation |
| **Ops** | `splash` version check | `/app/version`, `/push/*` | App version, soft-update, push stubs |

### 2.2 Shell tabs (commerce)

`Home` → `Category` → `Community` → `Cart` → `Profile`

### 2.3 Core user journeys (must be server-backed)

```text
Splash / version check
  → Home (banners + products + activity popup)
  → Search / Category → PDP (reviews, flash price) → Cart
  → Coupon → Checkout (address) → Create order → Pay (simulated)
  → Orders → Detail → Logistics → After-sale
Auth: Login / Register / Profile
Promo: Banner → Flash sale / Activity WebView / ThemeActivity (future)
Community feed + Messages (login-gated)
```

### 2.4 Current gaps vs a real backend

| Gap | Today | Platform should add |
|-----|-------|---------------------|
| Persistence | JSON files / in-memory follow store | PostgreSQL (or equiv.) |
| Admin CRUD | `POST /api/v1/__admin/reload` only | Full Admin API + Console |
| Cart / favorites / footprints | Mostly local on device | Optional sync APIs (phase later) |
| Address write | Mostly GET mock | Full CRUD |
| Auth refresh | Not implemented | Refresh token (phase 2) |
| Media | Static URLs in JSON | Upload + object storage |
| ThemeActivity | Design doc only | Config CMS + App APIs |

### 2.5 Keep App contract stable

| Item | Value |
|------|-------|
| Base path | `/api/v1` |
| Envelope | `{ "code": 0, "message": "ok", "data": ... }` |
| Auth header | `Authorization: Bearer <token>` |
| Local default | `http://127.0.0.1:<port>/api/v1` |
| App switch | `--dart-define=ENV=local --dart-define=USE_MOCK_API=false` (+ `API_BASE_URL` if needed) |

Canonical App route list: `lib/core/network/hos_mock_route_registry.dart`  
Existing Mock Server: `server/` (Express, port `3847`).

---

## 3. System Architecture

### 3.1 Logical view

```text
┌──────────────────┐     ┌──────────────────┐
│  SHOO App        │     │  Admin Console   │
│  (Flutter)       │     │  (Web SPA)       │
└────────┬─────────┘     └────────┬─────────┘
         │ /api/v1/*              │ /api/admin/v1/*
         │ Bearer user token      │ Bearer admin token / session
         ▼                        ▼
┌─────────────────────────────────────────────┐
│              API Gateway / BFF                │
│  - CORS, rate limit, request id, logging      │
└──────────────────────┬──────────────────────┘
                       ▼
┌─────────────────────────────────────────────┐
│                 API Service                   │
│  modules: catalog | trade | user | marketing  │
│           content | ops | media | iam         │
└───────┬─────────────┬─────────────┬─────────┘
        ▼             ▼             ▼
   PostgreSQL     Object Store    Cache (opt)
   (primary)      (S3/MinIO)      (Redis)
```

### 3.2 Two API surfaces

| Surface | Prefix | Audience | Auth |
|---------|--------|----------|------|
| **App API** | `/api/v1/*` | Mobile App | User JWT |
| **Admin API** | `/api/admin/v1/*` | Admin Console | Admin JWT + RBAC |

Do **not** expose Admin mutations on App paths. App paths stay read/write only as product needs (create order, claim coupon, etc.).

### 3.3 Recommended repo layout (English paths only)

Option A — monorepo sibling to Flutter (recommended long-term):

```text
SHOO/                          # existing Flutter app (unchanged root name)
shoo-platform/                 # new backend platform repo OR folder
├── apps/
│   ├── admin-web/             # Admin Console (React/Vue)
│   └── api/                   # HTTP API service
├── packages/
│   ├── shared-types/          # OpenAPI / TS types / zod schemas
│   └── config/                # shared eslint, tsconfig
├── deploy/
│   ├── docker/
│   │   ├── Dockerfile.api
│   │   ├── Dockerfile.admin
│   │   └── docker-compose.yml # local: api + db + minio + admin
│   └── k8s/                   # optional later
├── docs/
│   └── architecture.md
└── README.md
```

Option B — evolve in place (faster start, tighter coupling):

```text
SHOO/
├── lib/                       # Flutter
├── server/                    # legacy mock (deprecate gradually)
└── platform/                  # new platform under English path
    ├── apps/api/
    ├── apps/admin-web/
    └── deploy/docker/
```

**Recommendation:** start with `SHOO/platform/` for convenience, extract to `shoo-platform/` when team/size grows. **Never use Chinese folder names.**

### 3.4 Environment mapping

| Env | App `ENV` | API base example | DB |
|-----|-----------|------------------|-----|
| Local | `local` | `http://127.0.0.1:8080/api/v1` | Docker Postgres |
| Staging | `staging` | `https://api.staging.example.com/v1` | Managed Postgres |
| Production | `prod` | `https://api.example.com/v1` | Managed Postgres + replicas |

Keep port configurable; existing Mock uses `3847` — new platform may use `8080` and update App `defaultLocalApiBaseUrl` when cutting over.

---

## 4. Domain Modules (Admin + API)

All module / table / route names in **English**.

### 4.1 Module map

| Module | Code name | Responsibilities |
|--------|-----------|------------------|
| Identity & Access | `iam` | Admin users, roles, permissions; App users, sessions |
| Catalog | `catalog` | `products`, `skus`, `inventory`, `categories`, `banners` |
| Search | `search` | Hot keywords, search query (DB / later ES) |
| Trade | `trade` | `orders`, `payments`, `logistics`, `after_sales` |
| Cart (optional sync) | `cart` | Server cart (phase 2); keep App local until then |
| Marketing | `marketing` | `coupons`, `flash_sales`, `activities`, `theme_activities`, `popups`, `marquees` |
| Content | `content` | `community_posts`, `reviews` |
| Message | `message` | In-app messages / notifications |
| Media | `media` | Upload, image/video URLs (MinIO/S3) |
| Ops | `ops` | `app_versions`, feature flags, audit logs |
| Push | `push` | Device register + flash-sale reminder stubs |

### 4.2 Admin Console pages (suggested)

```text
/login
/dashboard
/catalog/products
/catalog/products/:id
/catalog/categories
/catalog/banners
/marketing/coupons
/marketing/flash-sales
/marketing/activities
/marketing/theme-activities
/marketing/popups
/marketing/marquees
/trade/orders
/trade/after-sales
/users
/content/community
/content/reviews
/ops/app-versions
/ops/audit-logs
/media/library
/settings/admins
```

### 4.3 Core entities (persistence sketch)

```text
users, user_addresses, user_coupons
products, product_skus, product_media, inventory
categories
banners
coupons, coupon_templates
orders, order_items, payments, logistics_tracks
after_sale_tickets
flash_sale_activities, flash_sale_sessions, flash_sale_products, flash_sale_follows
activities, activity_url_rules
theme_activities                    # JSON config CMS (see ThemeActivity design)
marketing_popups, cart_marquees
community_posts
reviews
messages
app_versions
media_assets
admin_users, admin_roles, admin_permissions, audit_logs
```

### 4.4 App API module ownership (compat layer)

Implement handlers that match existing paths first (compatibility), then enrich:

| Path group | Owner module |
|------------|--------------|
| `/banners`, `/products*`, `/categories` | `catalog` |
| `/search*` | `search` |
| `/auth*` | `iam` |
| `/orders*`, `/after-sales*` | `trade` |
| `/coupons`, `/addresses` | `user` + `marketing` |
| `/flash-sale*` | `marketing` |
| `/activity*`, `/marketing/*` | `marketing` |
| `/community/feed` | `content` |
| `/messages` | `message` |
| `/app/version`, `/push*` | `ops` / `push` |

New ThemeActivity (when App lands):

| Path | Notes |
|------|-------|
| `GET /theme-activities/{activityId}` | Page config JSON |
| `GET /theme-activities/{activityId}/products` | Footer pagination |

---

## 5. Cross-cutting Design

### 5.1 Response envelope (unchanged)

```json
{ "code": 0, "message": "ok", "data": {} }
```

Admin API may use the same envelope for consistency, or `{ data, meta }` — pick one and stick to it (recommend **same envelope**).

### 5.2 Auth model

| Actor | Mechanism | Notes |
|-------|-----------|-------|
| App user | JWT access (+ refresh in phase 2) | Align with current `Bearer` |
| Admin | JWT + RBAC roles | `super_admin`, `operator`, `cs`, `marketer` |

### 5.3 Media

Local: **MinIO** (S3-compatible) in docker-compose.  
Cloud: S3 / OSS / R2 — same SDK interface `media` module.

### 5.4 Simulated adapters (swap later)

```text
PaymentProvider (MockPay | Stripe | WeChat)
SmsProvider     (LogSms | Aliyun)
LogisticsProvider (MockTrack | CarrierAPI)
```

### 5.5 Observability

- Structured logs (JSON)
- Request id middleware
- `/health` + `/ready`
- Optional OpenTelemetry later

### 5.6 Security (cloud-ready from day one)

- Separate App / Admin secrets
- HTTPS in staging/prod
- CORS allowlist for Admin origin
- Rate limit on auth endpoints
- Soft-delete + audit for destructive admin actions

---

## 6. Stack Options (Mature) — Comparison

### Option A — NestJS + Prisma + PostgreSQL + React Admin

| Layer | Choice |
|-------|--------|
| API | NestJS (TypeScript) |
| ORM | Prisma |
| DB | PostgreSQL |
| Admin UI | React + Ant Design Pro / Refine |
| Local run | Docker Compose |
| Deploy | Docker → any VPS / Railway / Fly / K8s |

**Pros**

- Strong modular architecture (`catalog`, `trade`, … map 1:1 to Nest modules).
- Excellent TS ecosystem; OpenAPI generation easy.
- Prisma migrations fit iterative catalog/marketing schema.
- Large hiring / doc pool; production-proven.

**Cons**

- Heavier than current Express mock; more boilerplate.
- Learning curve if team is JS-only scripts today.

**Fit:** Best long-term default for SHOO Platform.

---

### Option B — Express (evolve current `server/`) + Prisma + PostgreSQL + Admin SPA

| Layer | Choice |
|-------|--------|
| API | Express (or Fastify) continuing from `server/` |
| ORM | Prisma / Drizzle |
| Admin UI | Vue3 + Element Plus, or React |

**Pros**

- Lowest migration cost from existing Mock Server.
- Team already knows Node + route registry pattern.
- Fast to keep `/api/v1` parity while swapping JSON → DB.

**Cons**

- Structure discipline is on you (easy to become spaghetti).
- Less built-in for DI, guards, OpenAPI than Nest.
- Harder to grow large team without conventions.

**Fit:** Best if you want **fastest local usable CMS** in 1–2 weeks, then harden.

---

### Option C — Supabase (Postgres + Auth + Storage + optional Edge)

| Layer | Choice |
|-------|--------|
| BaaS | Supabase local (`supabase start`) |
| Admin | Supabase Studio + thin custom Admin Web for commerce UX |
| App API | PostgREST / Edge Functions wrapped to keep `{code,message,data}` |

**Pros**

- Extremely fast local bootstrap (DB + Auth + Storage + Studio).
- Cloud upgrade path is productized.
- Great for content tables and file uploads.

**Cons**

- Commerce workflows (flash sale claim, order state machine) need Edge Functions / custom service anyway.
- Envelope/path compatibility needs a **BFF wrapper** — not drop-in for current Dio clients.
- Vendor model; complex RBAC/admin UX still custom.

**Fit:** Good for prototypes / content-heavy; weaker as primary commerce engine unless you invest in BFF.

---

### Option D — Django + DRF + Django Admin / Wagtail

| Layer | Choice |
|-------|--------|
| API | Django REST Framework |
| Admin | Django Admin (fast) or custom React |
| DB | PostgreSQL |

**Pros**

- Django Admin = instant ops UI for CRUD entities.
- Mature auth, permissions, ORM.
- Excellent for internal tools.

**Cons**

- Python stack beside Flutter/Node — second language in repo.
- Realtime / Node-ish tooling (existing mock scripts) diverge.
- Front-end Admin polish often still needs a SPA later.

**Fit:** Strong if team prefers Python; otherwise dual-stack cost.

---

### Option E — Headless CMS (Directus / Strapi) + Commerce API

| Layer | Choice |
|-------|--------|
| CMS | Directus or Strapi (banners, community, ThemeActivity JSON, H5 copy) |
| Commerce | Separate Nest/Express service for orders / inventory / flash sale |

**Pros**

- Best-in-class content modeling UI out of the box.
- ThemeActivity / banners / community very natural.

**Cons**

- Split brain: two systems to deploy and secure.
- Orders/inventory in CMS is a bad fit — you will build commerce API anyway.
- Sync and auth bridging overhead.

**Fit:** Add later for content if Nest Admin UX is weak; not ideal as sole system.

---

### Comparison matrix

| Criteria | A NestJS | B Express evolve | C Supabase | D Django | E CMS + API |
|----------|----------|------------------|------------|----------|-------------|
| Speed to local MVP | Medium | **High** | **High** | Medium | Medium |
| App API contract fit | **High** | **High** | Medium | High | Medium |
| Commerce complexity | **High** | Medium | Medium | High | Split |
| Admin UX quality | High (custom) | Medium→High | Studio + custom | **High** (built-in) | **High** (CMS) |
| Cloud production readiness | **High** | Medium→High | **High** | **High** | Medium |
| Team skill match (current Node mock) | Medium | **High** | Medium | Low | Medium |
| Long-term maintainability | **High** | Medium | Medium | High | Medium |
| Ops cost | Medium | Low→Medium | Low→Med | Medium | Higher |

---

## 7. Recommendation

### Phased recommendation

1. **Near term (local ops ASAP):**  
   **Option B** — evolve `server/` → `platform/apps/api` with PostgreSQL + Prisma, keep `/api/v1` parity, add `/api/admin/v1` + simple `admin-web`.

2. **Stabilize / grow:**  
   Refactor API into **Option A NestJS** modular layout (or adopt Nest from day one if you accept slower first MVP).

3. **Content acceleration (optional):**  
   Introduce Directus/Strapi **only** for ThemeActivity / community / banners if Admin SPA lags — still keep trade in commerce API.

**Default choice for design freeze:** **Option A (NestJS + Prisma + PostgreSQL + React Admin)** if the goal is a system you will take to production; use **Option B** only as an explicit acceleration spike that must not skip migrations, RBAC, and Docker Compose.

### Suggested default stack (freeze)

| Piece | Choice |
|-------|--------|
| Runtime | Node.js 20+ |
| API framework | NestJS |
| Language | TypeScript |
| ORM | Prisma |
| DB | PostgreSQL 16 |
| Cache | Redis (optional phase 2) |
| Object storage | MinIO (local) / S3 (cloud) |
| Admin | React 18 + Ant Design Pro (or Refine) |
| API docs | OpenAPI (`/docs`) |
| Local orchestration | Docker Compose |
| CI | GitHub Actions |
| App integration | `ENV=local`, `USE_MOCK_API=false`, `API_BASE_URL` |

---

## 8. Delivery Phases

### P0 — Foundation (local usable)

- Docker Compose: `api` + `postgres` + `minio` + `admin-web`
- Envelope + health checks
- Seed data migrated from `assets/mock/*.json`
- App-compatible read APIs: banners, products, categories, auth login/profile, orders list/detail
- Admin login + CRUD: products, categories, banners
- App points to platform API successfully

### P1 — Trade & marketing

- Orders create / pay simulate / logistics
- Coupons + addresses CRUD
- Flash sale calendar/page/claim/follow
- Activity WebView config APIs
- After-sale list/create
- Admin pages for orders, coupons, flash sales

### P2 — Content, media, ThemeActivity

- Community + reviews moderation
- Media library upload
- ThemeActivity config CMS + App APIs
- Messages / app version management
- Audit logs + RBAC roles

### P3 — Cloud production

- Staging/prod deploy
- Secrets management, HTTPS, backups
- Refresh tokens, rate limits, observability
- Optional cart sync, search engine (OpenSearch/ES)
- Payment/SMS/logistics real adapters behind interfaces

---

## 9. App Cutover Plan

| Step | Action |
|------|--------|
| 1 | Run platform locally via Compose |
| 2 | Seed DB from mock JSON |
| 3 | `flutter run --dart-define=ENV=local --dart-define=USE_MOCK_API=false --dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1` |
| 4 | Route parity checklist vs `hos_mock_route_registry.dart` |
| 5 | Deprecate file-only Mock Server for day-to-day (keep as fixture generator if useful) |
| 6 | Staging URL → `ENV=staging` |

Android emulator: host `10.0.2.2` instead of `127.0.0.1`.

---

## 10. Non-goals / Explicit deferrals

- Toolbox download/music demo catalogs as first-class admin domains  
- Real payment clearing  
- Multi-tenant SaaS  
- Full CDP / analytics suite (add `tracking` export later)

---

## 11. Success criteria

1. App runs with **Mock interceptor off** against local platform.  
2. Operator can change a banner / product price in Admin and see it in App after refresh.  
3. Create order → pay simulate → see order in Admin.  
4. `docker compose up` brings full local stack.  
5. Same images/config pattern works on a cloud VM with env vars only.

---

## 12. Next documents (when implementing)

| Doc | Path (English) | Purpose |
|-----|----------------|---------|
| OpenAPI draft | `platform/docs/openapi-app-v1.yaml` | App contract |
| Admin API draft | `platform/docs/openapi-admin-v1.yaml` | Admin contract |
| ERD | `platform/docs/erd.md` | Tables |
| Runbook | `platform/docs/local-runbook.md` | Compose + seed + App flags |
| ThemeActivity CMS | link existing ThemeActivity design | Config editor fields |

---

## 13. Changelog

| Version | Date | Notes |
|---------|------|-------|
| v0.2 | 2026-07-29 | P0 code under `platform/`: NestJS API, Prisma schema, Admin Web, Compose, seed |
| v0.1 | 2026-07-29 | Initial platform design: App inventory, architecture, module map, stack comparison, phases |

---

## 14. Summary

SHOO needs a **Backend Platform** with **App API** (`/api/v1`) + **Admin API/Console** (`/api/admin/v1`), English-only paths, PostgreSQL persistence, and Docker-based local→cloud promotion. Prefer **NestJS + Prisma + PostgreSQL + React Admin** for production trajectory; **Express evolution** only as a short acceleration path. Ignore App debug/toolbox toys; cover catalog, trade, user, marketing (including future ThemeActivity), content, and ops — matching current Flutter production features while remaining extensible for online release.
