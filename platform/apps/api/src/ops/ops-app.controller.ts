import { Body, Controller, Get, Post } from '@nestjs/common';
import { DocumentsService } from '../documents/documents.service';

@Controller('v1')
export class OpsAppController {
  constructor(private readonly docs: DocumentsService) {}

  @Get('app/version')
  appVersion() {
    return this.docs.getPayload('app_version');
  }

  @Get('cart')
  cart() {
    return this.docs.getPayload('cart');
  }

  @Post('push/register')
  pushRegister(@Body() _body: unknown) {
    return this.docs.getPayload('push_register_ok');
  }

  @Post('push/flash-sale/reminder')
  pushReminder(@Body() _body: unknown) {
    return this.docs.getPayload('push_register_ok');
  }

  @Post('push/flash-sale/cancel')
  pushCancel(@Body() _body: unknown) {
    return this.docs.getPayload('push_register_ok');
  }
}
