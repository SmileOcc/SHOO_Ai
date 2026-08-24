import { Controller, Param, Post, Req, UseGuards } from '@nestjs/common';
import { Request } from 'express';
import { UserAuthGuard } from '../iam/user-auth.guard';
import { CouponService } from './coupon.service';

@Controller('v1/coupons')
@UseGuards(UserAuthGuard)
export class CouponAppController {
  constructor(private readonly coupons: CouponService) {}

  @Post(':id/claim')
  claim(
    @Param('id') id: string,
    @Req() req: Request & { user?: { sub: string } },
  ) {
    return this.coupons.claimCoupon(req.user!.sub, id);
  }
}
