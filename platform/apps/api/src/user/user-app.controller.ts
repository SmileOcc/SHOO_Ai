import { Body, Controller, Get, Post, Query, Req, UseGuards } from '@nestjs/common';
import { Request } from 'express';
import { CouponService } from '../coupon/coupon.service';
import { DocumentsService } from '../documents/documents.service';
import { UserAuthGuard } from '../iam/user-auth.guard';
import { UserService } from './user.service';

@Controller('v1')
export class UserAppController {
  constructor(
    private readonly docs: DocumentsService,
    private readonly users: UserService,
    private readonly couponService: CouponService,
  ) {}

  @Get('messages')
  messages() {
    return this.docs.getPayload('messages');
  }

  @Get('addresses')
  addresses() {
    return this.docs.getPayload('addresses');
  }

  @Get('coupons')
  @UseGuards(UserAuthGuard)
  coupons(@Req() req: Request & { user?: { sub: string } }) {
    return this.couponService.listUserCoupons(req.user!.sub);
  }

  @Get('after-sales')
  afterSales() {
    return this.users.listAfterSales();
  }

  @Post('after-sales')
  createAfterSale(
    @Body()
    body: {
      orderId?: string;
      orderNo?: string;
      type?: string;
      reason?: string;
      productTitle?: string;
    },
  ) {
    return this.users.createAfterSale(body);
  }

  @Get('contacts')
  contacts(@Query('q') q?: string) {
    return this.users.listContacts(q);
  }
}
