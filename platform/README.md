# SHOO Platform

Local Backend Platform for the SHOO Flutter App (**Option A**: NestJS + Prisma + PostgreSQL + React Admin).

## Structure

```text
platform/
├── apps/
│   ├── api/                 # NestJS App API + Admin API
│   └── admin-web/           # React + Ant Design console
├── deploy/docker/           # docker-compose (postgres, minio, api, admin-web)
└── docs/
```

## Ports

| Service | URL |
|---------|-----|
| App API | `http://127.0.0.1:8080/api/v1` |
| Admin API | `http://127.0.0.1:8080/api/admin/v1` |
| Health | `http://127.0.0.1:8080/health` |
| Admin Web | `http://127.0.0.1:5173` |
| Postgres | `127.0.0.1:5432` |
| MinIO | `127.0.0.1:9000` (console `:9001`) |

> 启动顺序、Flutter `ENV` 规则、检查清单与「勿随意改端口」：见 [`docs/服务启动事项.md`](../docs/服务启动事项.md)。

## Prerequisites

- Node.js 20+ (22 recommended; Node 23 may warn on jest engines)
- Docker Desktop (recommended) **or** a local PostgreSQL 16 with DB/user `shoo`/`shoo`

> This machine may not have Docker installed. Install Docker Desktop, then use Compose below.

## Quick start (Docker Compose)

```bash
cd platform/deploy/docker
docker compose up -d postgres minio
# wait until healthy, then in another terminal:
cd ../../apps/api
cp .env.example .env
npm install
npx prisma db push
npm run seed
npm run start:dev
```

Admin web:

```bash
cd platform/apps/admin-web
npm install
npm run dev
```

Full stack containers (optional):

```bash
cd platform/deploy/docker
docker compose up --build
```

## App cutover (Flutter)

```bash
flutter run \
  --dart-define=ENV=local \
  --dart-define=USE_MOCK_API=false \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1
```

Android emulator host: `http://10.0.2.2:8080/api/v1`

## Default accounts (after seed)

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin@shoo.local` | `admin123456` |
| App user | `user@shoo.mock` | `shoo123456` |

## App API coverage (synced from `assets/mock`)

**Home / marketing config**

- `GET /banners`
- `GET /marketing/home-quick-entries`
- `GET /marketing/home-feed-config`
- `GET /marketing/activity-popup`
- `GET /marketing/cart-marquee`

**Catalog / search**

- `GET /banners` · `GET /categories`
- `GET /products` · `GET /products/:id` · `GET /products/batch`
- `GET /products/:id/reviews`
- `GET /search` · `GET /search/hot`

**Auth / user**

- `POST /auth/login` · `POST /auth/register` · `GET /auth/profile`
- `GET /messages` · `GET /addresses` · `GET /coupons`
- `GET /after-sales` · `POST /after-sales`
- `GET /contacts`

**Trade**

- `GET /orders` · `GET /orders/:id` · `GET /orders/:id/logistics`
- `POST /orders` · `POST /orders/:id/pay`

**Marketing / activity / flash sale**

- `GET /marketing/activity-popup` · `GET /marketing/cart-marquee`
- `GET /activity/data` · `GET /activity/detail` · `GET /activity/detail/level3`
- `GET /activity/user/check` · `GET /activity/config/url-rules`
- `GET /flash-sale/calendar` · `GET /flash-sale/page`
- `GET /flash-sale/product-activity` · `GET /flash-sale/follows`
- `POST /flash-sale/follow` · `POST /flash-sale/unfollow`
- `POST /flash-sale/coupons/:id/claim`

**Ops / misc**

- `GET /app/version` · `GET /cart` · `GET /documents` · `GET /community/feed`
- `POST /push/register` · `POST /push/flash-sale/reminder` · `POST /push/flash-sale/cancel`

**Admin (`/api/admin/v1`)**

- `POST /auth/login`
- Catalog CRUD: banners / products / categories
- Marketing home: activity-popup / home-quick-entries / home-feed-config
- Trade: list orders, patch status

Envelope: `{ "code": 0, "message": "ok", "data": ... }`

Admin console: `http://127.0.0.1:5173/home`（首页配置）

Re-seed after mock JSON changes:

```bash
cd platform/apps/api
npm run seed
```

## Next

Media upload (MinIO), Admin pages for coupons/flash sale, RBAC, remote deploy.

## ThemeActivity

**App**

- `GET /api/v1/theme-activities/{activityId}` — page config（仅 `online`）
- `GET /api/v1/theme-activities/{activityId}/products?page=&pageSize=` — footer 商品分页

**Admin**

- `GET/POST /api/admin/v1/marketing/theme-activities`
- `GET/PUT/DELETE /api/admin/v1/marketing/theme-activities/{activityId}`
- `POST /api/admin/v1/marketing/theme-activities/validate`

Admin console: `http://127.0.0.1:5173/theme-activities`

See `docs/Flutter主题活动ThemeActivity技术方案.md`.

See `docs/shoo-backend-platform-design.md`.
