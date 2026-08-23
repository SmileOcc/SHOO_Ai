import { Module } from '@nestjs/common';
import { CouponModule } from '../coupon/coupon.module';
import { IamModule } from '../iam/iam.module';
import { UserAppController } from './user-app.controller';
import { UserService } from './user.service';

@Module({
  imports: [CouponModule, IamModule],
  controllers: [UserAppController],
  providers: [UserService],
})
export class UserModule {}
