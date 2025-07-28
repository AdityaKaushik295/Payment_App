import {
  WebSocketGateway,
  WebSocketServer,
  OnGatewayConnection,
  OnGatewayDisconnect,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Payment } from './entities/payment.entity';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
})
export class PaymentsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  handleConnection(client: Socket) {
    console.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    console.log(`Client disconnected: ${client.id}`);
  }

  emitPaymentUpdate(payment: Payment) {
    this.server.emit('paymentUpdate', payment);
  }

  emitPaymentStats(stats: any) {
    this.server.emit('paymentStats', stats);
  }
}