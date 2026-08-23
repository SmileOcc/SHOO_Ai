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

  @Get('cart-marquee')
  getCartMarquee() {
    return this.marketing.adminCartMarquee();
  }

  @Put('cart-marquee')
  saveCartMarquee(@Body() body: { payload?: unknown } | unknown) {
    const payload =
      body && typeof body === 'object' && 'payload' in body
        ? body.payload
        : body;
    return this.marketing.saveCartMarquee(payload);
  }

  @Get('flash-sale-catalog')
  getFlashSaleCatalog() {
    return this.marketing.adminFlashSaleCatalog();
  }

  @Put('flash-sale-catalog')
  saveFlashSaleCatalog(@Body() body: { payload?: unknown } | unknown) {
    const payload =
      body && typeof body === 'object' && 'payload' in body
        ? body.payload
        : body;
    return this.marketing.saveFlashSaleCatalog(payload);
  }

  @Get('activity-data')
  getActivityData() {
    return this.marketing.adminActivityData();
  }

  @Put('activity-data')
  saveActivityData(@Body() body: { payload?: unknown } | unknown) {
    const payload =
      body && typeof body === 'object' && 'payload' in body
        ? body.payload
        : body;
    return this.marketing.saveActivityData(payload);
  }

  @Get('activity-detail')
  getActivityDetail() {
    return this.marketing.adminActivityDetail();
  }

  @Put('activity-detail')
  saveActivityDetail(@Body() body: { payload?: unknown } | unknown) {
    const payload =
      body && typeof body === 'object' && 'payload' in body
        ? body.payload
        : body;
    return this.marketing.saveActivityDetail(payload);
  }

  @Get('activity-level3-detail')
  getActivityLevel3Detail() {
    return this.marketing.adminActivityDetailLevel3();
  }

  @Put('activity-level3-detail')
  saveActivityLevel3Detail(@Body() body: { payload?: unknown } | unknown) {
    const payload =
      body && typeof body === 'object' && 'payload' in body
        ? body.payload
        : body;
    return this.marketing.saveActivityDetailLevel3(payload);
  }

  @Get('activity-user-check')
  getActivityUserCheck() {
    return this.marketing.adminActivityUserCheck();
  }

  @Put('activity-user-check')
  saveActivityUserCheck(@Body() body: { payload?: unknown } | unknown) {
    const payload =
      body && typeof body === 'object' && 'payload' in body
        ? body.payload
        : body;
    return this.marketing.saveActivityUserCheck(payload);
  }

  @Get('activity-url-rules')
  getActivityUrlRules() {
    return this.marketing.adminActivityUrlRules();
  }

  @Put('activity-url-rules')
  saveActivityUrlRules(@Body() body: { payload?: unknown } | unknown) {
    const payload =
      body && typeof body === 'object' && 'payload' in body
        ? body.payload
        : body;
    return this.marketing.saveActivityUrlRules(payload);
  }
}
