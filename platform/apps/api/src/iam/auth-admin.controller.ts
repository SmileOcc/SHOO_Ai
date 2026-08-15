import { Body, Controller, Post } from '@nestjs/common';
import { IamService } from './iam.service';

@Controller('admin/v1/auth')
export class AuthAdminController {
  constructor(private readonly iam: IamService) {}

  @Post('login')
  login(@Body() body: { email: string; password: string }) {
    return this.iam.adminLogin(body);
  }
}
