import { Controller, Get, Query } from '@nestjs/common';
import { ContentService } from './content.service';

@Controller('v1')
export class ContentAppController {
  constructor(private readonly content: ContentService) {}

  @Get('community/feed')
  communityFeed(@Query('sort') sort?: string) {
    return this.content.communityFeed(sort);
  }

  @Get('documents')
  documents() {
    return this.content.documents();
  }
}
