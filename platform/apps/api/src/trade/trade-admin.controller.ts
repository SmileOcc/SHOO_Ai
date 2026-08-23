import {
  Body,
  Controller,
  Get,
  Param,
  Patch,
  Put,
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

  @Get('orders/:id')
  getOrder(@Param('id') id: string) {
    return this.trade.adminGetOrder(id);
  }

  @Patch('orders/:id')
  updateOrder(
    @Param('id') id: string,
    @Body()
    body: Partial<{
      status: string;
      shippingAddress: string;
      hasLogistics: boolean;
    }>,
  ) {
    return this.trade.adminUpdateOrder(id, body);
  }

  @Patch('orders/:id/status')
  updateStatus(@Param('id') id: string, @Body() body: { status: string }) {
    return this.trade.adminUpdateStatus(id, body.status);
  }

  @Get('orders/:id/logistics')
  getLogistics(@Param('id') id: string) {
    return this.trade.adminGetLogistics(id);
  }

  @Put('orders/:id/logistics')
  saveLogistics(
    @Param('id') id: string,
    @Body()
    body: {
      carrier?: string;
      trackingNumber?: string;
      events?: Array<{
        time: string;
        status: string;
        description: string;
        isActive?: boolean;
      }>;
    },
  ) {
    return this.trade.adminSaveLogistics(id, body);
  }
}
