import cors from 'cors';
import express from 'express';
import { config } from './config.js';
import { loadMockJson, clearMockCache } from './loadMock.js';
import {
  getLogFiles,
  persistAnalytics,
  persistApiRequest,
  persistNetworkLog,
} from './logPersistence.js';
import { resolveMockResponse } from './mockResolver.js';
import { matchRoute, routes } from './routeRegistry.js';

const app = express();

app.use(cors());
app.use(express.json());

app.use((req, res, next) => {
  req._apiStartedAt = Date.now();
  res.on('finish', () => {
    const ms = Date.now() - req._apiStartedAt;
    console.log(`[${new Date().toISOString()}] ${req.method} ${req.originalUrl} → ${ms}ms`);
  });
  next();
});

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', service: 'shoo-mock-api', version: '1.0.0' });
});

app.get('/', (_req, res) => {
  res.json({
    service: 'SHOO Mock API',
    docs: 'All endpoints return JSON envelope { code, message, data }',
    apiPrefix: config.apiPrefix,
    mockDataDir: config.mockDataDir,
    routes: routes.map((r) => ({ method: r.method, path: `${config.apiPrefix}${r.path}`, file: r.file })),
    flutter: {
      run:
        'flutter run --dart-define=ENV=local --dart-define=USE_MOCK_API=false',
      androidEmulator:
        'flutter run --dart-define=ENV=local --dart-define=USE_MOCK_API=false --dart-define=API_BASE_URL=http://10.0.2.2:3847/api/v1',
    },
  });
});

const apiRouter = express.Router();

apiRouter.post('/__admin/reload', async (_req, res) => {
  clearMockCache();
  res.json({ code: 0, message: 'ok', data: { reloaded: true } });
});

async function handleLogRoutes(req, res, relativePath) {
  if (req.method !== 'POST') return false;

  if (relativePath === '/analytics/events') {
    console.log('[SHOO][ANALYTICS]', JSON.stringify(req.body, null, 2));
    try {
      await persistAnalytics(req.body ?? {});
    } catch (error) {
      console.error('[SHOO][LOG-PERSIST] analytics failed:', error);
    }
    res.json({ code: 0, message: 'ok', data: { accepted: true } });
    return true;
  }

  if (relativePath === '/debug/network-logs') {
    const kind = req.body?.kind ?? 'log';
    const message = req.body?.message ?? JSON.stringify(req.body);
    console.log(`[SHOO][NETWORK-LOG][${kind}]`, message);
    try {
      await persistNetworkLog(req.body ?? {});
    } catch (error) {
      console.error('[SHOO][LOG-PERSIST] network log failed:', error);
    }
    res.json({ code: 0, message: 'ok', data: { accepted: true } });
    return true;
  }

  return false;
}

async function recordApiExchange(req, res, relativePath, payload) {
  try {
    await persistApiRequest({
      method: req.method,
      path: relativePath,
      query: req.query,
      requestBody: req.body ?? null,
      status: res.statusCode,
      durationMs: Date.now() - (req._apiStartedAt ?? Date.now()),
      responseBody: payload,
      mockFile: res.locals.mockFile ?? null,
    });
  } catch (error) {
    console.error('[SHOO][LOG-PERSIST] api request failed:', error);
  }
}

async function handleApiRequest(req, res) {
  const relativePath = req.path === '' ? '/' : req.path;

  if (await handleLogRoutes(req, res, relativePath)) return;

  const route = matchRoute(req.method, relativePath);

  if (!route) {
    const payload = {
      code: 404,
      message: `Route not found: ${req.method} ${config.apiPrefix}${relativePath}`,
      data: null,
    };
    res.status(404);
    await recordApiExchange(req, res, relativePath, payload);
    res.json(payload);
    return;
  }

  if (config.mockDelayMs > 0) {
    await new Promise((resolve) => setTimeout(resolve, config.mockDelayMs));
  }

  try {
    const envelope = await loadMockJson(route.file);
    const { status, body } = await resolveMockResponse({
      route,
      requestPath: relativePath,
      query: req.query,
      envelope,
      loadMockJson,
    });
    res.locals.mockFile = route.file;
    res.status(status);
    await recordApiExchange(req, res, relativePath, body);
    res.json(body);
  } catch (error) {
    console.error(`Failed to load mock file ${route.file}:`, error);
    const payload = {
      code: 500,
      message: `Mock file error: ${route.file}`,
      data: null,
    };
    res.status(500);
    await recordApiExchange(req, res, relativePath, payload);
    res.json(payload);
  }
}

apiRouter.all('*', handleApiRequest);
app.use(config.apiPrefix, apiRouter);

app.use((_req, res) => {
  res.status(404).json({ code: 404, message: 'Not found', data: null });
});

app.listen(config.port, config.host, () => {
  console.log('');
  console.log('  SHOO Mock API Server');
  console.log('  ─────────────────────────────────────────');
  console.log(`  Local:    http://127.0.0.1:${config.port}${config.apiPrefix}`);
  console.log(`  Health:   http://127.0.0.1:${config.port}/health`);
  console.log(`  Data dir: ${config.mockDataDir}`);
  console.log(`  Delay:    ${config.mockDelayMs}ms`);
  console.log(`  Routes:   ${routes.length}`);
  const logFiles = getLogFiles();
  console.log(`  Logs:     ${logFiles.dir}/`);
  console.log(`            - ${logFiles.analytics}`);
  console.log(`            - ${logFiles.network}`);
  console.log(`            - ${logFiles.api} (incl. responseBody)`);
  console.log('');
  console.log('  Flutter (iOS Simulator / macOS):');
  console.log('    flutter run --dart-define=ENV=local --dart-define=USE_MOCK_API=false');
  console.log('');
  console.log('  Flutter (Android Emulator):');
  console.log('    flutter run --dart-define=ENV=local --dart-define=USE_MOCK_API=false \\');
  console.log('      --dart-define=API_BASE_URL=http://10.0.2.2:3847/api/v1');
  console.log('');
});
