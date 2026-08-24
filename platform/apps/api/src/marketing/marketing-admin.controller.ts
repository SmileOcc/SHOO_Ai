import { Body, Controller, Get, Put, UseGuards } from '@nestjs/common';
import { JsonObjectPipe } from '../common/json-object.pipe';
import { unwrapPayload } from '../common/unwrap-payload';
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
  saveActivityPopup(@Body(JsonObjectPipe) body: Record<string, unknown>) {
    return this.marketing.saveActivityPopup(unwrapPayload(body));
  }

  @Get('home-quick-entries')
  getHomeQuickEntries() {
    return this.marketing.adminHomeQuickEntries();
  }

  @Put('home-quick-entries')
  saveHomeQuickEntries(@Body(JsonObjectPipe) body: Record<string, unknown>) {
    const payload = unwrapPayload<{
      items: Array<{
        id: string;
        title: string;
        icon?: string;
        link: string;
        sort?: number;
        enabled?: boolean;
      }>;
    }>(body);
    return this.marketing.saveHomeQuickEntries(payload);
  }

  @Get('home-feed-config')
  getHomeFeedConfig() {
    return this.marketing.homeFeedConfig();
  }

  @Put('home-feed-config')
  saveHomeFeedConfig(@Body(JsonObjectPipe) body: Record<string, unknown>) {
    return this.marketing.saveHomeFeedConfig(
      unwrapPayload<Record<string, unknown>>(body) ?? {},
    );
  }

  @Get('cart-marquee')
  getCartMarquee() {
    return this.marketing.adminCartMarquee();
  }

  @Put('cart-marquee')
  saveCartMarquee(@Body(JsonObjectPipe) body: Record<string, unknown>) {
    return this.marketing.saveCartMarquee(unwrapPayload(body));
  }

  @Get('flash-sale-catalog')
  getFlashSaleCatalog() {
    return this.marketing.adminFlashSaleCatalog();
  }

  @Put('flash-sale-catalog')
  saveFlashSaleCatalog(@Body(JsonObjectPipe) body: Record<string, unknown>) {
    return this.marketing.saveFlashSaleCatalog(unwrapPayload(body));
  }

  @Get('activity-data')
  getActivityData() {
    return this.marketing.adminActivityData();
  }

  @Put('activity-data')
  saveActivityData(@Body(JsonObjectPipe) body: Record<string, unknown>) {
    return this.marketing.saveActivityData(unwrapPayload(body));
  }

  @Get('activity-detail')
  getActivityDetail() {
    return this.marketing.adminActivityDetail();
  }

  @Put('activity-detail')
  saveActivityDetail(@Body(JsonObjectPipe) body: Record<string, unknown>) {
    return this.marketing.saveActivityDetail(unwrapPayload(body));
  }

  @Get('activity-level3-detail')
  getActivityLevel3Detail() {
    return this.marketing.adminActivityDetailLevel3();
  }

  @Put('activity-level3-detail')
  saveActivityLevel3Detail(@Body(JsonObjectPipe) body: Record<string, unknown>) {
    return this.marketing.saveActivityDetailLevel3(unwrapPayload(body));
  }

  @Get('activity-user-check')
  getActivityUserCheck() {
    return this.marketing.adminActivityUserCheck();
  }

  @Put('activity-user-check')
  saveActivityUserCheck(@Body(JsonObjectPipe) body: Record<string, unknown>) {
    return this.marketing.saveActivityUserCheck(unwrapPayload(body));
  }

  @Get('activity-url-rules')
  getActivityUrlRules() {
    return this.marketing.adminActivityUrlRules();
  }

  @Put('activity-url-rules')
  saveActivityUrlRules(@Body(JsonObjectPipe) body: Record<string, unknown>) {
    return this.marketing.saveActivityUrlRules(unwrapPayload(body));
  }
}
