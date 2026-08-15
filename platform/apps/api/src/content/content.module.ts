import { Module } from '@nestjs/common';
import { ContentAppController } from './content-app.controller';
import { ContentService } from './content.service';

@Module({
  controllers: [ContentAppController],
  providers: [ContentService],
})
export class ContentModule {}
