import {
  CanActivate,
  ExecutionContext,
  Injectable,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';

@Injectable()
export class OptionalUserAuthGuard implements CanActivate {
  constructor(private readonly jwt: JwtService) {}

  canActivate(context: ExecutionContext): boolean {
    const req = context.switchToHttp().getRequest<Request>();
    const header = req.headers.authorization;
    if (!header?.startsWith('Bearer ')) {
      return true;
    }
    const token = header.slice(7);
    try {
      const payload = this.jwt.verify(token, {
        secret: process.env.JWT_SECRET || 'shoo_dev_jwt_secret_change_me',
      });
      (req as Request & { user?: unknown }).user = payload;
    } catch {
      // Ignore invalid token — treat as anonymous.
    }
    return true;
  }
}
