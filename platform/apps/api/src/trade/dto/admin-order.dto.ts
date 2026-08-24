import {
  IsArray,
  IsBoolean,
  IsIn,
  IsOptional,
  IsString,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';

export class OrderLogisticsEventDto {
  @IsString()
  time!: string;

  @IsString()
  status!: string;

  @IsString()
  description!: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class SaveOrderLogisticsDto {
  @IsOptional()
  @IsString()
  carrier?: string;

  @IsOptional()
  @IsString()
  trackingNumber?: string;

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => OrderLogisticsEventDto)
  events?: OrderLogisticsEventDto[];
}

export class UpdateOrderDto {
  @IsOptional()
  @IsString()
  @IsIn(['pending_payment', 'paid', 'shipped', 'delivered', 'cancelled'])
  status?: string;

  @IsOptional()
  @IsString()
  shippingAddress?: string;

  @IsOptional()
  @IsBoolean()
  hasLogistics?: boolean;
}
