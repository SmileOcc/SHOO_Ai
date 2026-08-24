import { IsIn, IsString } from 'class-validator';

export class UpdateOrderStatusDto {
  @IsString()
  @IsIn(['pending_payment', 'paid', 'shipped', 'delivered', 'cancelled'])
  status!: string;
}
