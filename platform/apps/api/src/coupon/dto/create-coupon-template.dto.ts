import {
  IsBoolean,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class CreateCouponTemplateDto {
  @IsString()
  id!: string;

  @IsString()
  title!: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsIn(['fixed', 'percent'])
  type?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  discountCents?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  discountPercent?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  minOrderCents?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  validDays?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  stock?: number | null;

  @IsOptional()
  @IsBoolean()
  enabled?: boolean;

  @IsOptional()
  @IsIn(['wallet', 'theme', 'flash'])
  source?: string;
}
