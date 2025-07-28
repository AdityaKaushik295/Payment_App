import { IsNumber, IsEnum, IsString, IsNotEmpty, IsOptional, Min } from 'class-validator';
import { PaymentStatus, PaymentMethod } from '../entities/payment.entity';

export class CreatePaymentDto {
  @IsNumber()
  @Min(0.01)
  amount: number;

  @IsEnum(PaymentMethod)
  method: PaymentMethod;

  @IsEnum(PaymentStatus)
  status: PaymentStatus;

  @IsString()
  @IsNotEmpty()
  receiver: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  failureReason?: string;
}