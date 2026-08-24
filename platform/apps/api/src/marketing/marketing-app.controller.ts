import { Body, Controller, Get, Param, Post, Query, Req, UseGuards } from '@nestjs/common';
import { Request } from 'express';
import { CouponService } from '../coupon/coupon.service';
import { OptionalUserAuthGuard } from '../iam/optional-user-auth.guard';
import { UserAuthGuard } from '../iam/user-auth.guard';
import { MarketingService } from './marketing.service';

type AuthedRequest = Request & { user?: { sub: string } };

@Controller('v1')
export class MarketingAppController {
  constructor(
    private readonly marketing: MarketingService,
    private readonly coupons: CouponService,
  ) {}

  private userId(req: AuthedRequest): string | undefined {
    return req.user?.sub;
  }

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
  @UseGuards(OptionalUserAuthGuard)
  flashSalePage(
    @Req() req: AuthedRequest,
    @Query() query: Record<string, string>,
  ) {
    return this.marketing.flashSalePage(query, this.userId(req));
  }

  @Get('flash-sale/product-activity')
  @UseGuards(OptionalUserAuthGuard)
  flashSaleProductActivity(
    @Req() req: AuthedRequest,
    @Query() query: Record<string, string>,
  ) {
    return this.marketing.flashSaleProductActivity(query, this.userId(req));
  }

  @Get('flash-sale/follows')
  @UseGuards(UserAuthGuard)
  flashSaleFollows(@Req() req: AuthedRequest) {
    return this.marketing.listFollows(req.user!.sub);
  }

  @Post('flash-sale/follow')
  @UseGuards(UserAuthGuard)
  flashSaleFollow(
    @Req() req: AuthedRequest,
    @Body()
    body: {
      sessionId?: string;
      productId?: string;
      title?: string;
      imageUrl?: string;
    },
  ) {
    return this.marketing.follow(req.user!.sub, body);
  }

  @Post('flash-sale/unfollow')
  @UseGuards(UserAuthGuard)
  flashSaleUnfollow(
    @Req() req: AuthedRequest,
    @Body() body: { sessionId?: string; productId?: string },
  ) {
    return this.marketing.unfollow(req.user!.sub, body);
  }

  @Post('flash-sale/coupons/:id/claim')
  @UseGuards(UserAuthGuard)
  claimCoupon(
    @Param('id') id: string,
    @Req() req: AuthedRequest,
  ) {
    return this.coupons.claimCoupon(req.user!.sub, id);
  }
}
