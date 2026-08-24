import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from '../src/app.module';
import { ApiExceptionFilter } from '../src/common/api-exception.filter';
import { EnvelopeInterceptor } from '../src/common/envelope';

type EnvelopeBody = {
  code: number;
  message: string;
  data: unknown;
};

async function createTestApp(): Promise<INestApplication<App>> {
  const moduleFixture: TestingModule = await Test.createTestingModule({
    imports: [AppModule],
  }).compile();

  const app = moduleFixture.createNestApplication();
  app.setGlobalPrefix('api', { exclude: ['health', 'ready'] });
  app.useGlobalInterceptors(new EnvelopeInterceptor());
  app.useGlobalFilters(new ApiExceptionFilter());
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
  await app.init();
  return app;
}

function expectEnvelope(body: EnvelopeBody) {
  expect(body).toMatchObject({
    code: expect.any(Number) as number,
    message: expect.any(String) as string,
  });
  expect(body).toHaveProperty('data');
}

describe('API contract (e2e)', () => {
  let app: INestApplication<App>;
  let userToken = '';

  beforeAll(async () => {
    app = await createTestApp();

    const login = await request(app.getHttpServer())
      .post('/api/v1/auth/login')
      .send({ email: 'user@shoo.mock', password: 'shoo123456' });

    expect(login.status).toBe(201);
    expectEnvelope(login.body);
    userToken = (login.body.data as { token: string }).token;
    expect(userToken).toBeTruthy();
  });

  afterAll(async () => {
    await app.close();
  });

  describe('health & public catalog', () => {
    it('GET /health returns service status', async () => {
      const res = await request(app.getHttpServer()).get('/health');
      expect(res.status).toBe(200);
      expectEnvelope(res.body);
      expect(res.body.data).toEqual(
        expect.objectContaining({ status: 'ok', service: 'shoo-api' }),
      );
    });

    it('GET /api/v1/banners returns envelope', async () => {
      const res = await request(app.getHttpServer()).get('/api/v1/banners');
      expect(res.status).toBe(200);
      expectEnvelope(res.body);
      expect(res.body.code).toBe(0);
    });

    it('GET /api/v1/categories returns envelope', async () => {
      const res = await request(app.getHttpServer()).get('/api/v1/categories');
      expect(res.status).toBe(200);
      expectEnvelope(res.body);
    });

    it('GET /api/v1/products returns paged envelope', async () => {
      const res = await request(app.getHttpServer()).get(
        '/api/v1/products?page=1&pageSize=5',
      );
      expect(res.status).toBe(200);
      expectEnvelope(res.body);
      expect(res.body.data).toEqual(
        expect.objectContaining({
          items: expect.any(Array),
        }),
      );
    });

    it('GET /api/v1/messages returns envelope', async () => {
      const res = await request(app.getHttpServer()).get('/api/v1/messages');
      expect(res.status).toBe(200);
      expectEnvelope(res.body);
    });
  });

  describe('auth', () => {
    it('POST /api/v1/auth/login rejects missing password', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/v1/auth/login')
        .send({ email: 'user@shoo.mock' });
      expect(res.status).toBe(400);
      expectEnvelope(res.body);
      expect(res.body.code).toBe(400);
    });

    it('POST /api/v1/auth/register rejects invalid email', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/v1/auth/register')
        .send({ email: 'not-an-email', password: 'secret123' });
      expect(res.status).toBe(400);
      expectEnvelope(res.body);
    });

    it('GET /api/v1/auth/profile returns 401 without token', async () => {
      const res = await request(app.getHttpServer()).get('/api/v1/auth/profile');
      expect(res.status).toBe(401);
      expectEnvelope(res.body);
    });

    it('GET /api/v1/auth/profile returns user with token', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/v1/auth/profile')
        .set('Authorization', `Bearer ${userToken}`);
      expect(res.status).toBe(200);
      expectEnvelope(res.body);
      expect(res.body.data).toEqual(
        expect.objectContaining({ email: 'user@shoo.mock' }),
      );
    });
  });

  describe('admin auth', () => {
    it('POST /api/admin/v1/auth/login rejects invalid email', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/admin/v1/auth/login')
        .send({ email: 'not-an-email', password: 'admin123456' });
      expect(res.status).toBe(400);
      expectEnvelope(res.body);
    });
  });

  describe('protected user resources', () => {
    it('GET /api/v1/coupons returns 401 without token', async () => {
      const res = await request(app.getHttpServer()).get('/api/v1/coupons');
      expect(res.status).toBe(401);
      expectEnvelope(res.body);
    });

    it('GET /api/v1/coupons returns wallet with token', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/v1/coupons')
        .set('Authorization', `Bearer ${userToken}`);
      expect(res.status).toBe(200);
      expectEnvelope(res.body);
      expect(Array.isArray(res.body.data)).toBe(true);
    });

    it('GET /api/v1/orders returns 401 without token', async () => {
      const res = await request(app.getHttpServer()).get('/api/v1/orders');
      expect(res.status).toBe(401);
      expectEnvelope(res.body);
    });

    it('GET /api/v1/orders returns paged list with token', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/v1/orders?page=1&pageSize=10')
        .set('Authorization', `Bearer ${userToken}`);
      expect(res.status).toBe(200);
      expectEnvelope(res.body);
      expect(res.body.data).toEqual(
        expect.objectContaining({
          items: expect.any(Array),
        }),
      );
    });

    it('POST /api/v1/orders rejects empty items', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/v1/orders')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ items: [] });
      expect(res.status).toBe(400);
      expectEnvelope(res.body);
    });

    it('POST /api/v1/orders creates order with valid items', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/v1/orders')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          items: [
            {
              productId: 'c1-g1-l1-p1',
              title: 'Demo Product',
              imageUrl: 'https://example.com/p.jpg',
              price: 1299,
              quantity: 1,
              variantLabel: 'M',
            },
          ],
          totalCents: 1299,
        });
      expect([200, 201]).toContain(res.status);
      expectEnvelope(res.body);
      expect(res.body.data).toEqual(
        expect.objectContaining({
          id: expect.any(String),
          status: 'pending_payment',
          paymentDeadlineAt: expect.any(String),
        }),
      );

      const orderId = (res.body.data as { id: string }).id;
      const payRes = await request(app.getHttpServer())
        .post(`/api/v1/orders/${orderId}/pay`)
        .set('Authorization', `Bearer ${userToken}`);
      expect([200, 201]).toContain(payRes.status);
      expectEnvelope(payRes.body);
      expect(payRes.body.data).toEqual(
        expect.objectContaining({
          orderId,
          status: 'paid',
          paidAt: expect.any(String),
        }),
      );
    });

    it('POST /api/v1/coupons/:id/claim returns 401 without token', async () => {
      const res = await request(app.getHttpServer()).post(
        '/api/v1/coupons/c_spring_10/claim',
      );
      expect(res.status).toBe(401);
      expectEnvelope(res.body);
    });

    it('GET /api/v1/orders supports status filter with token', async () => {
      const res = await request(app.getHttpServer())
        .get('/api/v1/orders?status=shipped')
        .set('Authorization', `Bearer ${userToken}`);
      expect(res.status).toBe(200);
      expectEnvelope(res.body);
      const items = (res.body.data as { items: Array<{ status: string }> })
        .items;
      expect(items.every((order) => order.status === 'shipped')).toBe(true);
    });

    it('POST /api/v1/coupons/:id/claim succeeds with token', async () => {
      const res = await request(app.getHttpServer())
        .post('/api/v1/coupons/c_spring_10/claim')
        .set('Authorization', `Bearer ${userToken}`);
      expect([200, 201]).toContain(res.status);
      expectEnvelope(res.body);
      expect(res.body.data).toEqual(
        expect.objectContaining({
          success: true,
          couponId: 'c_spring_10',
        }),
      );
    });
  });

  describe('marketing & catalog reads', () => {
    it('GET /api/v1/flash-sale/page returns envelope', async () => {
      const res = await request(app.getHttpServer()).get(
        '/api/v1/flash-sale/page',
      );
      expect(res.status).toBe(200);
      expectEnvelope(res.body);
    });

    it('GET /api/v1/theme-activities/:id returns envelope', async () => {
      const res = await request(app.getHttpServer()).get(
        '/api/v1/theme-activities/demo_coupon_rush',
      );
      expect(res.status).toBe(200);
      expectEnvelope(res.body);
    });

    it('GET /api/v1/products/:id/reviews returns envelope', async () => {
      const res = await request(app.getHttpServer()).get(
        '/api/v1/products/c1-g1-l1-p1/reviews',
      );
      expect(res.status).toBe(200);
      expectEnvelope(res.body);
    });
    it('GET /api/v1/products/batch returns stock and skus', async () => {
      const res = await request(app.getHttpServer()).get(
        '/api/v1/products/batch?ids=c1-g1-l1-p1&skuIds=c1-g1-l1-p1::尺码 M',
      );
      expect(res.status).toBe(200);
      expectEnvelope(res.body);
      const data = res.body.data as {
        items: Array<{ productId: string; stock: number; skus: unknown[] }>;
      };
      expect(data.items.length).toBeGreaterThan(0);
      expect(data.items[0].stock).toBeGreaterThan(0);
      expect(Array.isArray(data.items[0].skus)).toBe(true);
    });
  });
});
