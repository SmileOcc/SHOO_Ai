import { Module } from '@nestjs/common';
import { DocumentsModule } from '../documents/documents.module';
import { IamModule } from '../iam/iam.module';
import { CouponAdminController } from './coupon-admin.controller';
import { CouponService } from './coupon.service';

@Module({
  imports: [DocumentsModule, IamModule],
  controllers: [CouponAdminController],
  providers: [CouponService],
  exports: [CouponService],
})
export class CouponModule {}
