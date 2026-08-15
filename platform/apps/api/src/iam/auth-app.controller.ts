import { Body, Controller, Get, Post, Req, UseGuards } from '@nestjs/common';
import { Request } from 'express';
import { IamService } from './iam.service';
import { UserAuthGuard } from './user-auth.guard';

@Controller('v1/auth')
export class AuthAppController {
  constructor(private readonly iam: IamService) {}

  @Post('login')
  login(
    @Body() body: { email?: string; phone?: string; password?: string },
  ) {
    return this.iam.login(body ?? {});
  }

  @Post('register')
  register(
    @Body()
    body: {
      email: string;
      password: string;
      nickname?: string;
      phone?: string;
    },
  ) {
    return this.iam.register(body);
  }

  @Get('profile')
  @UseGuards(UserAuthGuard)
  profile(@Req() req: Request & { user?: { sub: string } }) {
    return this.iam.profile(req.user!.sub);
  }
}
