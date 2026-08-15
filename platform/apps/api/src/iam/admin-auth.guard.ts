import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { Request } from 'express';

@Injectable()
export class AdminAuthGuard implements CanActivate {
  constructor(private readonly jwt: JwtService) {}

  canActivate(context: ExecutionContext): boolean {
    const req = context.switchToHttp().getRequest<Request>();
    const header = req.headers.authorization;
    if (!header?.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing admin token');
    }
    const token = header.slice(7);
    try {
      const payload = this.jwt.verify(token, {
        secret: process.env.ADMIN_JWT_SECRET || 'shoo_admin_jwt_secret_change_me',
      });
      (req as Request & { admin?: unknown }).admin = payload;
      return true;
    } catch {
      throw new UnauthorizedException('Invalid admin token');
    }
  }
}
