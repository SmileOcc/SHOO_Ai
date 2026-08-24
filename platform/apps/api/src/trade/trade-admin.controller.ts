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
import { SaveOrderLogisticsDto, UpdateOrderDto } from './dto/admin-order.dto';
import { UpdateOrderStatusDto } from './dto/update-order-status.dto';
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
  updateOrder(@Param('id') id: string, @Body() body: UpdateOrderDto) {
    return this.trade.adminUpdateOrder(id, body);
  }

  @Patch('orders/:id/status')
  updateStatus(@Param('id') id: string, @Body() body: UpdateOrderStatusDto) {
    return this.trade.adminUpdateStatus(id, body.status);
  }

  @Get('orders/:id/logistics')
  getLogistics(@Param('id') id: string) {
    return this.trade.adminGetLogistics(id);
  }

  @Put('orders/:id/logistics')
  saveLogistics(
    @Param('id') id: string,
    @Body() body: SaveOrderLogisticsDto,
  ) {
    return this.trade.adminSaveLogistics(id, body);
  }
}
