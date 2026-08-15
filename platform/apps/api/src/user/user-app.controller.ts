import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { DocumentsService } from '../documents/documents.service';
import { UserService } from './user.service';

@Controller('v1')
export class UserAppController {
  constructor(
    private readonly docs: DocumentsService,
    private readonly users: UserService,
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
  coupons() {
    return this.docs.getPayload('coupons');
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
