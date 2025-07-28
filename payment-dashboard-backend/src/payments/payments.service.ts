// src/payments/payments.service.ts
import {
  Injectable,
  NotFoundException,
  Inject,
  forwardRef,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository, Between } from 'typeorm';
import { Payment, PaymentStatus, PaymentMethod } from './entities/payment.entity';
import { CreatePaymentDto } from './dto/create-payment.dto';
import { PaymentFilterDto } from './dto/payment-filter.dto';
import { Server } from 'socket.io';
import { SocketGateway } from '../socket/socket.gateway'; // ✅ Import custom gateway

interface RevenueTrendItem {
  date: string;
  revenue: number;
}

@Injectable()
export class PaymentsService {
  constructor(
    @InjectRepository(Payment)
    private paymentRepository: Repository<Payment>,

    @Inject(forwardRef(() => SocketGateway))
    private socketGateway: SocketGateway, // ✅ Inject gateway
  ) {
    this.seedMockData();
  }

  async create(createPaymentDto: CreatePaymentDto): Promise<Payment> {
    const transactionid = `TXN${Date.now()}${Math.floor(Math.random() * 1000)}`;
    const payment = this.paymentRepository.create({
      ...createPaymentDto,
      transactionid,
    });

    const savedPayment = await this.paymentRepository.save(payment);
    console.log('✅ Payment created:', savedPayment.id);

    // ✅ Emit payment update
    this.socketGateway.server.emit('paymentUpdate', savedPayment);

    // ✅ Emit updated stats
    const stats = await this.getStats();
    this.socketGateway.server.emit('paymentStats', stats);

    return savedPayment;
  }

  async findAll(filterDto: PaymentFilterDto): Promise<{ payments: Payment[], total: number }> {
    const { page = 1, limit = 10, status, method, startDate, endDate } = filterDto;

    const queryBuilder = this.paymentRepository.createQueryBuilder('payment');

    if (status) queryBuilder.andWhere('payment.status = :status', { status });
    if (method) queryBuilder.andWhere('payment.method = :method', { method });
    if (startDate && endDate) {
      queryBuilder.andWhere('payment.createdat BETWEEN :startDate AND :endDate', {
        startDate,
        endDate,
      });
    }

    const skip = (page - 1) * limit;
    queryBuilder.skip(skip).take(limit);
    queryBuilder.orderBy('payment.createdat', 'DESC');

    const [payments, total] = await queryBuilder.getManyAndCount();
    return { payments, total };
  }

  async findOne(id: string): Promise<Payment> {
    const payment = await this.paymentRepository.findOne({ where: { id } });
    if (!payment) {
      throw new NotFoundException(`Payment with ID ${id} not found`);
    }
    return payment;
  }

  async getStats(): Promise<any> {
    const today = new Date();
    const startOfToday = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const startOfWeek = new Date(today.getTime() - 7 * 24 * 60 * 60 * 1000);

    const transactionsToday = await this.paymentRepository.count({
      where: { createdat: Between(startOfToday, today) },
    });

    const transactionsThisWeek = await this.paymentRepository.count({
      where: { createdat: Between(startOfWeek, today) },
    });

    const revenueToday = await this.paymentRepository
      .createQueryBuilder('payment')
      .select('SUM(payment.amount)', 'total')
      .where('payment.status = :status', { status: PaymentStatus.SUCCESS })
      .andWhere('payment.createdat >= :startOfToday', { startOfToday })
      .getRawOne();

    const revenueThisWeek = await this.paymentRepository
      .createQueryBuilder('payment')
      .select('SUM(payment.amount)', 'total')
      .where('payment.status = :status', { status: PaymentStatus.SUCCESS })
      .andWhere('payment.createdat >= :startOfWeek', { startOfWeek })
      .getRawOne();

    const failedTransactions = await this.paymentRepository.count({
      where: {
        status: PaymentStatus.FAILED,
        createdat: Between(startOfWeek, today),
      },
    });

    const revenueTrend: RevenueTrendItem[] = [];
    for (let i = 6; i >= 0; i--) {
      const date = new Date(today.getTime() - i * 24 * 60 * 60 * 1000);
      const startOfDay = new Date(date.getFullYear(), date.getMonth(), date.getDate());
      const endOfDay = new Date(date.getFullYear(), date.getMonth(), date.getDate() + 1);

      const dailyRevenue = await this.paymentRepository
        .createQueryBuilder('payment')
        .select('SUM(payment.amount)', 'total')
        .where('payment.status = :status', { status: PaymentStatus.SUCCESS })
        .andWhere('payment.createdat >= :startOfDay', { startOfDay })
        .andWhere('payment.createdat < :endOfDay', { endOfDay })
        .getRawOne();

      revenueTrend.push({
        date: startOfDay.toISOString().split('T')[0],
        revenue: parseFloat(dailyRevenue?.total) || 0,
      });
    }

    return {
      transactionsToday,
      transactionsThisWeek,
      revenueToday: parseFloat(revenueToday?.total) || 0,
      revenueThisWeek: parseFloat(revenueThisWeek?.total) || 0,
      failedTransactions,
      revenueTrend,
    };
  }

  async exportToCsv(): Promise<string> {
    const payments = await this.paymentRepository.find({
      order: { createdat: 'DESC' },
    });

    const csvHeader = 'ID,Amount,Method,Status,Receiver,Description,Transaction ID,Created At\n';
    const csvData = payments
      .map(payment =>
        `${payment.id},${payment.amount},${payment.method},${payment.status},${payment.receiver},"${payment.description || ''}",${payment.transactionid},${payment.createdat.toISOString()}`
      )
      .join('\n');

    return csvHeader + csvData;
  }

  private async seedMockData() {
    const count = await this.paymentRepository.count();
    if (count > 0) return;

    const mockPayments = [/* same as before */];
    for (const paymentData of mockPayments) {
      const payment = this.paymentRepository.create(paymentData);
      await this.paymentRepository.save(payment);
    }
  }
}
