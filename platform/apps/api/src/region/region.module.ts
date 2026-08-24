import { Module } from '@nestjs/common';
import { RegionAppController } from './region-app.controller';
import { RegionService } from './region.service';

@Module({
  controllers: [RegionAppController],
  providers: [RegionService],
  exports: [RegionService],
})
export class RegionModule {}
