import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { AdminAuthGuard } from './admin-auth.guard';
import { AuthAdminController } from './auth-admin.controller';
import { AuthAppController } from './auth-app.controller';
import { IamService } from './iam.service';
import { OptionalUserAuthGuard } from './optional-user-auth.guard';
import { UserAuthGuard } from './user-auth.guard';

@Module({
  imports: [JwtModule.register({})],
  controllers: [AuthAppController, AuthAdminController],
  providers: [IamService, AdminAuthGuard, UserAuthGuard, OptionalUserAuthGuard],
  exports: [
    IamService,
    AdminAuthGuard,
    UserAuthGuard,
    OptionalUserAuthGuard,
    JwtModule,
  ],
})
export class IamModule {}
