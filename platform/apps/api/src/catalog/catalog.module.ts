import { Module } from '@nestjs/common';
import { IamModule } from '../iam/iam.module';
import { CatalogAdminController } from './catalog-admin.controller';
import { CatalogAppController } from './catalog-app.controller';
import { CatalogService } from './catalog.service';

@Module({
  imports: [IamModule],
  controllers: [CatalogAppController, CatalogAdminController],
  providers: [CatalogService],
  exports: [CatalogService],
})
export class CatalogModule {}
