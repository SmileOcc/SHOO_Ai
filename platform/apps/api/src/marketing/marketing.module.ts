import { Module } from '@nestjs/common';
import { CouponModule } from '../coupon/coupon.module';
import { IamModule } from '../iam/iam.module';
import { MarketingAdminController } from './marketing-admin.controller';
import { MarketingAppController } from './marketing-app.controller';
import { MarketingService } from './marketing.service';
import { ThemeActivityAdminController } from './theme-activity-admin.controller';
import { ThemeActivityAppController } from './theme-activity-app.controller';
import { ThemeActivityService } from './theme-activity.service';

@Module({
  imports: [IamModule, CouponModule],
  controllers: [
    MarketingAppController,
    MarketingAdminController,
    ThemeActivityAppController,
    ThemeActivityAdminController,
  ],
  providers: [MarketingService, ThemeActivityService],
  exports: [MarketingService, ThemeActivityService],
})
export class MarketingModule {}
