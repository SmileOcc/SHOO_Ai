import { Module } from '@nestjs/common';
import { DocumentsModule } from '../documents/documents.module';
import { IamModule } from '../iam/iam.module';
import { StockReservationService } from './stock-reservation.service';
import { TradeAdminController } from './trade-admin.controller';
import { TradeAppController } from './trade-app.controller';
import { TradeService } from './trade.service';

@Module({
  imports: [IamModule, DocumentsModule],
  controllers: [TradeAppController, TradeAdminController],
  providers: [TradeService, StockReservationService],
})
export class TradeModule {}
