import { Controller, Get, Param, Query } from '@nestjs/common';
import { ThemeActivityService } from './theme-activity.service';

@Controller('v1/theme-activities')
export class ThemeActivityAppController {
  constructor(private readonly theme: ThemeActivityService) {}

  @Get(':activityId')
  getConfig(@Param('activityId') activityId: string) {
    return this.theme.getAppConfig(activityId);
  }

  @Get(':activityId/products')
  getProducts(
    @Param('activityId') activityId: string,
    @Query()
    query: {
      page?: string;
      pageSize?: string;
      moduleId?: string;
    },
  ) {
    return this.theme.getAppProducts(activityId, query);
  }
}
