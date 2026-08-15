import { Body, Controller, Get, Param, Post, Query } from '@nestjs/common';
import { TradeService } from './trade.service';

@Controller('v1/orders')
export class TradeAppController {
  constructor(private readonly trade: TradeService) {}

  @Get()
  list(
    @Query('page') page?: string,
    @Query('pageSize') pageSize?: string,
  ) {
    return this.trade.listOrders({
      page: page ? Number(page) : undefined,
      pageSize: pageSize ? Number(pageSize) : undefined,
    });
  }

  @Get(':id/logistics')
  logistics(@Param('id') id: string) {
    return this.trade.getLogistics(id);
  }

  @Get(':id')
  detail(@Param('id') id: string) {
    return this.trade.getOrder(id);
  }

  @Post()
  create(
    @Body()
    body: {
      items: Array<{
        productId: string;
        title: string;
        imageUrl: string;
        price: number;
        quantity: number;
        variantLabel?: string;
      }>;
      totalCents?: number;
      addressId?: string;
      couponId?: string;
    },
  ) {
    return this.trade.createOrder(body);
  }

  @Post(':id/pay')
  pay(@Param('id') id: string) {
    return this.trade.payOrder(id);
  }
}
