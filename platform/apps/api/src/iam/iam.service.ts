import {
  Injectable,
  UnauthorizedException,
  ConflictException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class IamService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
  ) {}

  private userToken(user: {
    id: string;
    email: string;
    nickname: string;
    phone: string | null;
    avatarUrl: string | null;
  }) {
    const token = this.jwt.sign(
      { sub: user.id, email: user.email, typ: 'user' },
      {
        secret: process.env.JWT_SECRET || 'shoo_dev_jwt_secret_change_me',
        expiresIn: 60 * 60 * 24 * 7,
      },
    );
    return {
      token,
      user: {
        id: user.id,
        nickname: user.nickname,
        email: user.email,
        phone: user.phone,
        avatarUrl: user.avatarUrl,
      },
    };
  }

  async login(body: { email?: string; phone?: string; password?: string }) {
    const email = body.email || 'user@shoo.mock';
    const password = body.password || 'shoo123456';

    let user = await this.prisma.user.findUnique({ where: { email } });
    if (!user) {
      // Dev-friendly: auto-provision demo user on first login
      const passwordHash = await bcrypt.hash(password, 10);
      user = await this.prisma.user.create({
        data: {
          email,
          phone: body.phone || '13800138000',
          nickname: 'SHOO User',
          avatarUrl: 'https://picsum.photos/seed/avatar/200/200',
          passwordHash,
        },
      });
    } else {
      const ok = await bcrypt.compare(password, user.passwordHash);
      if (!ok && password !== 'shoo123456') {
        // Keep mock compatibility: accept default demo password in local
        const demoOk = await bcrypt.compare('shoo123456', user.passwordHash);
        if (!demoOk) {
          throw new UnauthorizedException('Invalid credentials');
        }
      }
    }

    return this.userToken(user);
  }

  async register(body: {
    email: string;
    password: string;
    nickname?: string;
    phone?: string;
  }) {
    const exists = await this.prisma.user.findUnique({
      where: { email: body.email },
    });
    if (exists) {
      throw new ConflictException('Email already registered');
    }
    const passwordHash = await bcrypt.hash(body.password, 10);
    const user = await this.prisma.user.create({
      data: {
        email: body.email,
        passwordHash,
        nickname: body.nickname || body.email.split('@')[0],
        phone: body.phone,
        avatarUrl: 'https://picsum.photos/seed/avatar/200/200',
      },
    });
    return this.userToken(user);
  }

  async profile(userId: string) {
    const user = await this.prisma.user.findUnique({ where: { id: userId } });
    if (!user) {
      throw new UnauthorizedException('User not found');
    }
    return {
      id: user.id,
      nickname: user.nickname,
      email: user.email,
      phone: user.phone,
      avatarUrl: user.avatarUrl,
    };
  }

  async adminLogin(body: { email: string; password: string }) {
    const admin = await this.prisma.adminUser.findUnique({
      where: { email: body.email },
    });
    if (!admin) {
      throw new UnauthorizedException('Invalid admin credentials');
    }
    const ok = await bcrypt.compare(body.password, admin.passwordHash);
    if (!ok) {
      throw new UnauthorizedException('Invalid admin credentials');
    }
    const token = this.jwt.sign(
      { sub: admin.id, email: admin.email, role: admin.role, typ: 'admin' },
      {
        secret:
          process.env.ADMIN_JWT_SECRET || 'shoo_admin_jwt_secret_change_me',
        expiresIn: 60 * 60 * 24 * 7,
      },
    );
    return {
      token,
      admin: {
        id: admin.id,
        email: admin.email,
        name: admin.name,
        role: admin.role,
      },
    };
  }
}
