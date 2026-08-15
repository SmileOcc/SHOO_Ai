import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { AdminAuthGuard } from './admin-auth.guard';
import { AuthAdminController } from './auth-admin.controller';
import { AuthAppController } from './auth-app.controller';
import { IamService } from './iam.service';
import { UserAuthGuard } from './user-auth.guard';

@Module({
  imports: [JwtModule.register({})],
  controllers: [AuthAppController, AuthAdminController],
  providers: [IamService, AdminAuthGuard, UserAuthGuard],
  exports: [IamService, AdminAuthGuard, UserAuthGuard, JwtModule],
})
export class IamModule {}
