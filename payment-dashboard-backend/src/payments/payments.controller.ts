// src/payments/payments.controller.ts
import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  UseGuards,
  Res,
  Request,
} from '@nestjs/common';
import { Response } from 'express';
import { PaymentsService } from './payments.service';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { PaymentFilterDto } from './dto/payment-filter.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('payments')
@UseGuards(JwtAuthGuard)
export class PaymentsController {
  constructor(private readonly paymentsService: PaymentsService) {}

  @Post()
  create(@Body() createPaymentDto: CreatePaymentDto, @Request() req) {
    console.log('PaymentsController: Create payment request from user:', req.user?.username);
    return this.paymentsService.create(createPaymentDto);
  }

  @Get()
  findAll(@Query() filterDto: PaymentFilterDto, @Request() req) {
    console.log('PaymentsController: Get payments request from user:', req.user?.username);
    return this.paymentsService.findAll(filterDto);
  }

  @Get('stats')
  getStats(@Request() req) {
    console.log('PaymentsController: Get stats request from user:', req.user?.username);
    console.log('PaymentsController: Request headers:', req.headers.authorization);
    console.log('PaymentsController: User object:', req.user);
    return this.paymentsService.getStats();
  }

  @Get('export')
  async exportCsv(@Res() res: Response, @Request() req) {
    console.log('PaymentsController: Export CSV request from user:', req.user?.username);
    const csvData = await this.paymentsService.exportToCsv();
    
    res.setHeader('Content-Type', 'text/csv');
    res.setHeader('Content-Disposition', 'attachment; filename=payments.csv');
    res.send(csvData);
  }

  @Get(':id')
  findOne(@Param('id') id: string, @Request() req) {
    console.log('PaymentsController: Get payment details request from user:', req.user?.username);
    return this.paymentsService.findOne(id);
  }
}