import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { AdminAuthGuard } from '../iam/admin-auth.guard';
import { CouponService } from './coupon.service';

@Controller('admin/v1/coupons')
@UseGuards(AdminAuthGuard)
export class CouponAdminController {
  constructor(private readonly coupons: CouponService) {}

  @Get('templates')
  listTemplates() {
    return this.coupons.listTemplates();
  }

  @Post('templates')
  createTemplate(
    @Body()
    body: {
      id: string;
      title: string;
      description?: string;
      type?: string;
      discountCents?: number;
      discountPercent?: number;
      minOrderCents?: number;
      validDays?: number;
      stock?: number | null;
      enabled?: boolean;
      source?: string;
    },
  ) {
    return this.coupons.createTemplate(body);
  }

  @Patch('templates/:id')
  updateTemplate(
    @Param('id') id: string,
    @Body()
    body: Partial<{
      title: string;
      description: string;
      type: string;
      discountCents: number;
      discountPercent: number;
      minOrderCents: number;
      validDays: number;
      stock: number | null;
      enabled: boolean;
      source: string;
    }>,
  ) {
    return this.coupons.updateTemplate(id, body);
  }

  @Delete('templates/:id')
  deleteTemplate(@Param('id') id: string) {
    return this.coupons.deleteTemplate(id);
  }

  @Post('templates/seed')
  seedTemplates() {
    return this.coupons.seedTemplatesFromMocks();
  }
}
