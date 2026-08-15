import { Module } from '@nestjs/common';
import { IamModule } from '../iam/iam.module';
import { MarketingAdminController } from './marketing-admin.controller';
import { MarketingAppController } from './marketing-app.controller';
import { MarketingService } from './marketing.service';

@Module({
  imports: [IamModule],
  controllers: [MarketingAppController, MarketingAdminController],
  providers: [MarketingService],
  exports: [MarketingService],
})
export class MarketingModule {}
