import { Module } from '@nestjs/common';
import { OpsAppController } from './ops-app.controller';

@Module({
  controllers: [OpsAppController],
})
export class OpsModule {}
