import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Query,
  UseGuards,
} from '@nestjs/common';
import { AdminAuthGuard } from '../iam/admin-auth.guard';
import { TradeService } from './trade.service';

@Controller('admin/v1/trade')
@UseGuards(AdminAuthGuard)
export class TradeAdminController {
  constructor(private readonly trade: TradeService) {}

  @Get('orders')
  list(
    @Query('page') page?: string,
    @Query('pageSize') pageSize?: string,
    @Query('status') status?: string,
  ) {
    return this.trade.adminListOrders({
      page: page ? Number(page) : undefined,
      pageSize: pageSize ? Number(pageSize) : undefined,
      status,
    });
  }

  @Patch('orders/:id/status')
  updateStatus(@Param('id') id: string, @Body() body: { status: string }) {
    return this.trade.adminUpdateStatus(id, body.status);
  }
}
