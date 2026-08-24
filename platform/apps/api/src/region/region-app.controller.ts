import { Controller, Get, Query } from '@nestjs/common';
import { RegionService } from './region.service';

@Controller('v1/regions')
export class RegionAppController {
  constructor(private readonly regions: RegionService) {}

  @Get('meta')
  meta() {
    return this.regions.getMeta();
  }

  @Get('countries')
  countries() {
    return this.regions.listCountries();
  }

  @Get('children')
  children(
    @Query('country') country: string,
    @Query('parentCode') parentCode?: string,
  ) {
    return this.regions.listChildren(country, parentCode);
  }
}
