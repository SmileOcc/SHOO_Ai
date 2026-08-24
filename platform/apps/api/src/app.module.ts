import { Module } from '@nestjs/common';
import { CouponModule } from './coupon/coupon.module';
import { CatalogModule } from './catalog/catalog.module';
import { ContentModule } from './content/content.module';
import { DocumentsModule } from './documents/documents.module';
import { HealthModule } from './health/health.module';
import { IamModule } from './iam/iam.module';
import { MarketingModule } from './marketing/marketing.module';
import { OpsModule } from './ops/ops.module';
import { PrismaModule } from './prisma/prisma.module';
import { RegionModule } from './region/region.module';
import { TradeModule } from './trade/trade.module';
import { UserModule } from './user/user.module';

@Module({
  imports: [
    PrismaModule,
    DocumentsModule,
    HealthModule,
    IamModule,
    CouponModule,
    CatalogModule,
    TradeModule,
    UserModule,
    ContentModule,
    MarketingModule,
    OpsModule,
    RegionModule,
  ],
})
export class AppModule {}
