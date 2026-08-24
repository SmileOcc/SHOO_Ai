import { Type } from 'class-transformer';
import {
  ArrayMinSize,
  IsArray,
  IsInt,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';

export class CreateOrderItemDto {
  @IsString()
  productId!: string;

  @IsString()
  title!: string;

  @IsString()
  imageUrl!: string;

  @IsInt()
  @Min(0)
  price!: number;

  @IsInt()
  @Min(1)
  quantity!: number;

  @IsOptional()
  @IsString()
  variantLabel?: string;
}

export class CreateOrderDto {
  @IsArray()
  @ArrayMinSize(1)
  @ValidateNested({ each: true })
  @Type(() => CreateOrderItemDto)
  items!: CreateOrderItemDto[];

  @IsOptional()
  @IsInt()
  @Min(0)
  totalCents?: number;

  @IsOptional()
  @IsString()
  addressId?: string;

  @IsOptional()
  @IsString()
  couponId?: string;
}
