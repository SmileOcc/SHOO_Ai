# SHOO Mock API Server

本地 Mock API 服务，直接读取 Flutter 工程里的 `assets/mock/*.json`，与 App 内 `SHOMockRouteRegistry` 路由一一对应。

## 为什么需要

| 模式 | 说明 |
|------|------|
| **内置 Mock**（默认） | Dio 拦截器读 assets，零依赖，适合纯前端开发 |
| **本地 Server**（本服务） | 真实 HTTP 请求，可用 Postman/curl 调试，改 JSON 后调 `POST /api/v1/__admin/reload` 清缓存 |
| **云端部署** | 同一套代码可 Docker 部署到 Railway / Render / Fly.io 等 |

## 快速启动

```bash
cd server
npm install
npm run dev
```

服务地址：`http://127.0.0.1:3847/api/v1`

验证所有路由：

```bash
npm run check
```

手动探测：

```bash
curl http://127.0.0.1:3847/health
curl http://127.0.0.1:3847/api/v1/banners
curl -X POST http://127.0.0.1:3847/api/v1/auth/login -H 'Content-Type: application/json' -d '{}'
```

## Flutter 连接本地 Server

**iOS 模拟器 / macOS / 真机（同局域网需改 IP）：**

```bash
flutter run --dart-define=ENV=local --dart-define=USE_MOCK_API=false
```

**Android 模拟器**（`127.0.0.1` 指向模拟器自身，需用 `10.0.2.2`）：

```bash
flutter run \
  --dart-define=ENV=local \
  --dart-define=USE_MOCK_API=false \
  --dart-define=API_BASE_URL=http://10.0.2.2:3847/api/v1
```

## 环境变量

| 变量 | 默认 | 说明 |
|------|------|------|
| `PORT` | `3847` | 监听端口（云平台通常注入此变量） |
| `MOCK_DELAY_MS` | `300` | 模拟网络延迟 |
| `MOCK_DATA_DIR` | `../assets/mock` | JSON 数据目录 |
| `API_PREFIX` | `/api/v1` | API 路径前缀 |
| `HOST` | `0.0.0.0` | 绑定地址 |

复制 `.env.example` 为 `.env` 后按需修改（Node 20+ 可用 `node --env-file=.env src/index.js`，或 export 环境变量）。

## 修改 Mock 数据

1. 编辑 `assets/mock/*.json`（与 Flutter assets 共用，单一数据源）
2. 调用 `POST http://127.0.0.1:3847/api/v1/__admin/reload` 清除服务端缓存
3. Flutter 内置 Mock 模式需热重启；本地 Server 模式重新请求即可

## 云端部署（预留）

### Docker

在项目根目录 `SHOO/` 执行：

```bash
docker build -f server/Dockerfile -t shoo-mock-api .
docker run -p 8080:8080 -e MOCK_DELAY_MS=0 shoo-mock-api
```

### 平台示例

**Railway / Render / Fly.io：**

1. 构建命令：`cd server && npm install`
2. 启动命令：`node src/index.js`
3. 环境变量：`PORT`（平台自动）、`MOCK_DELAY_MS=0`
4. 确保 `assets/mock` 随仓库一起部署（Dockerfile 已 COPY）

Flutter 指向云端：

```bash
flutter run \
  --dart-define=ENV=staging \
  --dart-define=USE_MOCK_API=false \
  --dart-define=API_BASE_URL=https://your-api.example.com/api/v1
```

## API 列表

与 `lib/core/network/hos_mock_route_registry.dart` 同步，共 16 条业务路由 + `__admin/reload`。

完整列表访问：`GET http://127.0.0.1:3847/`
