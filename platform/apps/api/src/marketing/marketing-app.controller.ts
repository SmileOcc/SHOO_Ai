import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common';
import { MarketingService } from './marketing.service';

@Controller('v1')
export class MarketingAppController {
  constructor(private readonly marketing: MarketingService) {}

  @Get('marketing/activity-popup')
  activityPopup() {
    return this.marketing.activityPopup();
  }

  @Get('marketing/home-quick-entries')
  homeQuickEntries() {
    return this.marketing.homeQuickEntries();
  }

  @Get('marketing/home-feed-config')
  homeFeedConfig() {
    return this.marketing.homeFeedConfig();
  }

  @Get('marketing/cart-marquee')
  cartMarquee() {
    return this.marketing.cartMarquee();
  }

  @Get('activity/data')
  activityData() {
    return this.marketing.activityData();
  }

  @Get('activity/detail')
  activityDetail() {
    return this.marketing.activityDetail();
  }

  @Get('activity/detail/level3')
  activityDetailLevel3() {
    return this.marketing.activityDetailLevel3();
  }

  @Get('activity/user/check')
  activityUserCheck() {
    return this.marketing.activityUserCheck();
  }

  @Get('activity/config/url-rules')
  activityUrlRules() {
    return this.marketing.activityUrlRules();
  }

  @Get('flash-sale/calendar')
  flashSaleCalendar(@Query() query: Record<string, string>) {
    return this.marketing.flashSaleCalendar(query);
  }

  @Get('flash-sale/page')
  flashSalePage(@Query() query: Record<string, string>) {
    return this.marketing.flashSalePage(query);
  }

  @Get('flash-sale/product-activity')
  flashSaleProductActivity(@Query() query: Record<string, string>) {
    return this.marketing.flashSaleProductActivity(query);
  }

  @Get('flash-sale/follows')
  flashSaleFollows() {
    return this.marketing.listFollows();
  }

  @Post('flash-sale/follow')
  flashSaleFollow(
    @Body()
    body: {
      sessionId?: string;
      productId?: string;
      title?: string;
      imageUrl?: string;
    },
  ) {
    return this.marketing.follow(body);
  }

  @Post('flash-sale/unfollow')
  flashSaleUnfollow(
    @Body() body: { sessionId?: string; productId?: string },
  ) {
    return this.marketing.unfollow(body);
  }

  @Post('flash-sale/coupons/:id/claim')
  claimCoupon(@Param('id') id: string) {
    return this.marketing.claimCoupon(id);
  }
}
