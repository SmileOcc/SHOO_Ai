import {
  Body,
  Controller,
  Get,
  Param,
  Post,
  Query,
  Req,
  UseGuards,
} from '@nestjs/common';
import { Request } from 'express';
import { UserAuthGuard } from '../iam/user-auth.guard';
import { CreateOrderDto } from './dto/create-order.dto';
import { TradeService } from './trade.service';

@Controller('v1/orders')
@UseGuards(UserAuthGuard)
export class TradeAppController {
  constructor(private readonly trade: TradeService) {}

  @Get()
  list(
    @Req() req: Request & { user?: { sub: string } },
    @Query('page') page?: string,
    @Query('pageSize') pageSize?: string,
    @Query('status') status?: string,
  ) {
    return this.trade.listOrders({
      userId: req.user!.sub,
      page: page ? Number(page) : undefined,
      pageSize: pageSize ? Number(pageSize) : undefined,
      status,
    });
  }

  @Get(':id/logistics')
  logistics(
    @Param('id') id: string,
    @Req() req: Request & { user?: { sub: string } },
  ) {
    return this.trade.getLogistics(id, req.user!.sub);
  }

  @Get(':id')
  detail(
    @Param('id') id: string,
    @Req() req: Request & { user?: { sub: string } },
  ) {
    return this.trade.getOrder(id, req.user!.sub);
  }

  @Post()
  create(
    @Req() req: Request & { user?: { sub: string } },
    @Body() body: CreateOrderDto,
  ) {
    return this.trade.createOrder({ ...body, userId: req.user!.sub });
  }

  @Post(':id/pay')
  pay(
    @Param('id') id: string,
    @Req() req: Request & { user?: { sub: string } },
  ) {
    return this.trade.payOrder(id, req.user!.sub);
  }
}
