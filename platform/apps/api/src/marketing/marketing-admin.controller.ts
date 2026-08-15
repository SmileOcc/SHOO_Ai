import { Body, Controller, Get, Put, UseGuards } from '@nestjs/common';
import { AdminAuthGuard } from '../iam/admin-auth.guard';
import { MarketingService } from './marketing.service';

@Controller('admin/v1/marketing')
@UseGuards(AdminAuthGuard)
export class MarketingAdminController {
  constructor(private readonly marketing: MarketingService) {}

  @Get('activity-popup')
  getActivityPopup() {
    return this.marketing.activityPopup();
  }

  @Put('activity-popup')
  saveActivityPopup(@Body() body: { payload?: unknown } | Record<string, unknown>) {
    const payload =
      body && typeof body === 'object' && 'payload' in body
        ? body.payload
        : body;
    return this.marketing.saveActivityPopup(payload);
  }

  @Get('home-quick-entries')
  getHomeQuickEntries() {
    return this.marketing.adminHomeQuickEntries();
  }

  @Put('home-quick-entries')
  saveHomeQuickEntries(
    @Body()
    body: {
      items?: Array<{
        id: string;
        title: string;
        icon?: string;
        link: string;
        sort?: number;
        enabled?: boolean;
      }>;
      payload?: {
        items: Array<{
          id: string;
          title: string;
          icon?: string;
          link: string;
          sort?: number;
          enabled?: boolean;
        }>;
      };
    },
  ) {
    const payload = body.payload ?? { items: body.items ?? [] };
    return this.marketing.saveHomeQuickEntries(payload);
  }

  @Get('home-feed-config')
  getHomeFeedConfig() {
    return this.marketing.homeFeedConfig();
  }

  @Put('home-feed-config')
  saveHomeFeedConfig(@Body() body: Record<string, unknown>) {
    const payload =
      body && typeof body === 'object' && 'payload' in body && body.payload
        ? (body.payload as Record<string, unknown>)
        : body;
    return this.marketing.saveHomeFeedConfig(payload ?? {});
  }
}
