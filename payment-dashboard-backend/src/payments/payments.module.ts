import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PaymentsService } from './payments.service';
import { PaymentsController } from './payments.controller';
import { Payment } from './entities/payment.entity';
import { SocketModule } from '../socket/socket.module'; // ✅ Add this

@Module({
  imports: [
    TypeOrmModule.forFeature([Payment]),
    SocketModule, // ✅ Import it here
  ],
  controllers: [PaymentsController],
  providers: [PaymentsService],
})
export class PaymentsModule {}
