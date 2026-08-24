import { ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ApiExceptionFilter } from './common/api-exception.filter';
import { EnvelopeInterceptor } from './common/envelope';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const origins = (process.env.CORS_ORIGINS || '*')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);

  app.enableCors({
    origin: origins.includes('*') ? true : origins,
    credentials: true,
  });

  app.setGlobalPrefix('api', {
    exclude: ['health', 'ready'],
  });
  app.useGlobalInterceptors(new EnvelopeInterceptor());
  app.useGlobalFilters(new ApiExceptionFilter());
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  const port = Number(process.env.PORT || 8080);
  await app.listen(port);
  // eslint-disable-next-line no-console
  console.log(`shoo-api listening on http://127.0.0.1:${port}`);
  // eslint-disable-next-line no-console
  console.log(`App API:  http://127.0.0.1:${port}/api/v1`);
  // eslint-disable-next-line no-console
  console.log(`Admin API: http://127.0.0.1:${port}/api/admin/v1`);
}

bootstrap();
