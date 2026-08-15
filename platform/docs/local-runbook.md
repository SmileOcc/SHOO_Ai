# Local Runbook

## 1. Start database

```bash
cd platform/deploy/docker
docker compose up -d postgres minio
```

Without Docker, create a local PostgreSQL database:

```text
user: shoo
password: shoo
database: shoo
port: 5432
```

## 2. API

```bash
cd platform/apps/api
cp .env.example .env
npm install
npx prisma db push
npm run seed   # imports assets/mock/*.json into PostgreSQL
npm run start:dev
```

Verify:

```bash
curl http://127.0.0.1:8080/health
curl http://127.0.0.1:8080/api/v1/banners
curl http://127.0.0.1:8080/api/v1/messages
curl 'http://127.0.0.1:8080/api/v1/search?q=Shirt&page=1&pageSize=2'
```

After changing mock JSON under `assets/mock/`, re-run `npm run seed`.

## 3. Admin Web

```bash
cd platform/apps/admin-web
npm install
npm run dev
```

Open `http://127.0.0.1:5173`  
Login: `admin@shoo.local` / `admin123456`

## 4. Flutter App

```bash
cd ../..   # SHOO root
flutter run \
  --dart-define=ENV=local \
  --dart-define=USE_MOCK_API=false \
  --dart-define=API_BASE_URL=http://127.0.0.1:8080/api/v1
```

## Accounts

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@shoo.local | admin123456 |
| App user | user@shoo.mock | shoo123456 |
