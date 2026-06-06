import cors from 'cors';
import express from 'express';
import { config } from './config.js';
import { loadMockJson, clearMockCache } from './loadMock.js';
import { matchRoute, routes } from './routeRegistry.js';

const app = express();

app.use(cors());
app.use(express.json());

app.use((req, res, next) => {
  const started = Date.now();
  res.on('finish', () => {
    const ms = Date.now() - started;
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

async function handleApiRequest(req, res) {
  // Mounted at apiPrefix — req.path is relative (e.g. /banners)
  const relativePath = req.path === '' ? '/' : req.path;
  const route = matchRoute(req.method, relativePath);

  if (!route) {
    res.status(404).json({
      code: 404,
      message: `Route not found: ${req.method} ${config.apiPrefix}${relativePath}`,
      data: null,
    });
    return;
  }

  if (config.mockDelayMs > 0) {
    await new Promise((resolve) => setTimeout(resolve, config.mockDelayMs));
  }

  try {
    const body = await loadMockJson(route.file);
    res.status(200).json(body);
  } catch (error) {
    console.error(`Failed to load mock file ${route.file}:`, error);
    res.status(500).json({
      code: 500,
      message: `Mock file error: ${route.file}`,
      data: null,
    });
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
  console.log('');
  console.log('  Flutter (iOS Simulator / macOS):');
  console.log('    flutter run --dart-define=ENV=local --dart-define=USE_MOCK_API=false');
  console.log('');
  console.log('  Flutter (Android Emulator):');
  console.log('    flutter run --dart-define=ENV=local --dart-define=USE_MOCK_API=false \\');
  console.log('      --dart-define=API_BASE_URL=http://10.0.2.2:3847/api/v1');
  console.log('');
});
