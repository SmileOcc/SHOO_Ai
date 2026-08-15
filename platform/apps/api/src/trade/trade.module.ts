import { Module } from '@nestjs/common';
import { IamModule } from '../iam/iam.module';
import { TradeAdminController } from './trade-admin.controller';
import { TradeAppController } from './trade-app.controller';
import { TradeService } from './trade.service';

@Module({
  imports: [IamModule],
  controllers: [TradeAppController, TradeAdminController],
  providers: [TradeService],
})
export class TradeModule {}
