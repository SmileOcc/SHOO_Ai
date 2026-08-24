import { Body, Controller, Post } from '@nestjs/common';
import { AdminLoginDto } from './dto/admin-login.dto';
import { IamService } from './iam.service';

@Controller('admin/v1/auth')
export class AuthAdminController {
  constructor(private readonly iam: IamService) {}

  @Post('login')
  login(@Body() body: AdminLoginDto) {
    return this.iam.adminLogin(body);
  }
}
