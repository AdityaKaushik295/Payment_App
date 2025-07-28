import { WebSocketGateway, WebSocketServer, SubscribeMessage } from '@nestjs/websockets';
import { Server } from 'socket.io';

@WebSocketGateway({
  cors: {
    origin: '*', // adjust based on frontend domain
  },
})
export class SocketGateway {
  @WebSocketServer()
  server: Server;

  emitStatsUpdate(stats: any) {
    this.server.emit('paymentStats', stats);
  }

  emitPaymentUpdate(payment: any) {
    this.server.emit('paymentUpdate', payment);
  }
}
