import {
  CallHandler,
  ExecutionContext,
  Injectable,
  NestInterceptor,
} from '@nestjs/common';
import { Observable, map } from 'rxjs';

export type ApiEnvelope<T> = {
  code: number;
  message: string;
  data: T;
};

@Injectable()
export class EnvelopeInterceptor implements NestInterceptor {
  intercept(_context: ExecutionContext, next: CallHandler): Observable<unknown> {
    return next.handle().pipe(
      map((data) => {
        if (
          data &&
          typeof data === 'object' &&
          'code' in data &&
          'message' in data &&
          'data' in data
        ) {
          return data;
        }
        return { code: 0, message: 'ok', data } satisfies ApiEnvelope<unknown>;
      }),
    );
  }
}

export function ok<T>(data: T, message = 'ok'): ApiEnvelope<T> {
  return { code: 0, message, data };
}
