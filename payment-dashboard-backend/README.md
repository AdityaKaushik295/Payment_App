# 🖥️ Payment Dashboard Backend (NestJS)

A robust, scalable REST API built with NestJS for managing payments, users, and real-time dashboard analytics. Features JWT authentication, WebSocket support, PostgreSQL integration, and comprehensive payment processing capabilities.

![NestJS](https://img.shields.io/badge/nestjs-%23E0234E.svg?style=for-the-badge&logo=nestjs&logoColor=white)
![TypeScript](https://img.shields.io/badge/typescript-%23007ACC.svg?style=for-the-badge&logo=typescript&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/postgresql-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)
![Socket.io](https://img.shields.io/badge/Socket.io-black?style=for-the-badge&logo=socket.io&logoColor=white)

## 🎯 Features

### 🔐 Authentication & Authorization
- **JWT Authentication**: Secure token-based authentication
- **Role-based Access Control**: Admin and viewer roles
- **Passport Integration**: Local and JWT strategies
- **Token Validation**: Automatic token verification and refresh

### 💰 Payment Management
- **CRUD Operations**: Create, read, update payment records
- **Advanced Filtering**: Date range, status, payment method filters
- **Pagination**: Efficient data loading for large datasets
- **Payment Statistics**: Real-time dashboard metrics
- **CSV Export**: Download transaction reports

### 👥 User Management
- **User CRUD**: Manage admin and viewer accounts
- **Password Hashing**: Secure bcrypt password storage
- **Role Assignment**: Flexible permission system

### 🔄 Real-time Features
- **WebSocket Gateway**: Live updates for dashboard
- **Event Broadcasting**: Real-time notifications
- **Connection Management**: Auto-connect/disconnect handling

### 📊 Analytics & Reporting
- **Dashboard Stats**: Revenue, transaction counts, trends
- **Failed Transaction Analysis**: Error tracking and reporting
- **Revenue Calculations**: Daily, weekly, monthly aggregations

## 🏗️ Architecture

### Project Structure
```
src/
├── 🔐 auth/                     # Authentication module
│   ├── dto/
│   │   └── login.dto.ts         # Login validation DTO
│   ├── guards/
│   │   └── jwt-auth.guard.ts    # JWT route protection
│   ├── strategies/
│   │   ├── jwt.strategy.ts      # JWT token validation
│   │   └── local.strategy.ts    # Username/password validation
│   ├── auth.controller.ts       # Auth endpoints
│   ├── auth.module.ts           # Auth module definition
│   └── auth.service.ts          # Auth business logic
├── 💰 payments/                 # Payment management
│   ├── dto/
│   │   ├── create-payment.dto.ts # Payment creation validation
│   │   └── payment-filter.dto.ts # Filtering parameters
│   ├── entities/
│   │   └── payment.entity.ts    # Payment database model
│   ├── payments.controller.ts   # Payment API endpoints
│   ├── payments.gateway.ts      # WebSocket gateway
│   ├── payments.module.ts       # Payment module
│   └── payments.service.ts      # Payment business logic
├── 👥 users/                    # User management
│   ├── dto/
│   │   └── create-user.dto.ts   # User creation validation
│   ├── entities/
│   │   └── user.entity.ts       # User database model
│   ├── users.controller.ts      # User API endpoints
│   ├── users.module.ts          # User module
│   └── users.service.ts         # User business logic
├── 🔧 common/                   # Shared utilities
│   ├── decorators/              # Custom decorators
│   ├── filters/                 # Exception filters
│   └── interceptors/            # Request/response interceptors
├── 📄 app.module.ts             # Root application module
└── 🚀 main.ts                   # Application bootstrap
```

### Database Schema

#### User Entity
```typescript
@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  username: string;

  @Column()
  password: string;

  @Column({ default: 'viewer' })
  role: 'admin' | 'viewer';

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

#### GET `/api/payments/export`
Export payments as CSV file.

**Query Parameters:**
- Same filtering options as GET `/api/payments`

**Response:**
```
Content-Type: text/csv
Content-Disposition: attachment; filename=payments.csv

ID,Amount,Method,Status,Receiver,Description,Created At
uuid1,1250.00,credit_card,success,John Doe,Online purchase,2024-01-15T10:30:00.000Z
uuid2,750.50,bank_transfer,pending,Jane Smith,Invoice payment,2024-01-15T11:15:00.000Z
```

### 👥 Users

#### GET `/api/users`
Get list of all users (Admin only).

**Response:**
```json
[
  {
    "id": "uuid",
    "username": "admin",
    "role": "admin",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  },
  {
    "id": "uuid2",
    "username": "viewer",
    "role": "viewer",
    "createdAt": "2024-01-02T00:00:00.000Z",
    "updatedAt": "2024-01-02T00:00:00.000Z"
  }
]
```

#### POST `/api/users`
Create a new user (Admin only).

**Request Body:**
```json
{
  "username": "newuser",
  "password": "securepassword123",
  "role": "viewer"
}
```

**Response:**
```json
{
  "id": "uuid",
  "username": "newuser",
  "role": "viewer",
  "createdAt": "2024-01-15T12:00:00.000Z",
  "updatedAt": "2024-01-15T12:00:00.000Z"
}
```

## 🔌 WebSocket Events

### Connection
```javascript
// Client connection
const socket = io('ws://localhost:3000', {
  transports: ['websocket'],
  extraHeaders: {
    'Authorization': 'Bearer <jwt_token>'
  }
});
```

### Events

#### Server → Client Events

**`payment_created`**: Broadcasted when new payment is created
```json
{
  "event": "payment_created",
  "data": {
    "id": "uuid",
    "amount": 1250.00,
    "method": "credit_card",
    "status": "success",
    "receiver": "John Doe",
    "createdAt": "2024-01-15T10:30:00.000Z"
  }
}
```

**`payment_updated`**: Broadcasted when payment status changes
```json
{
  "event": "payment_updated",
  "data": {
    "id": "uuid",
    "status": "success",
    "updatedAt": "2024-01-15T10:35:00.000Z"
  }
}
```

**`stats_updated`**: Broadcasted when dashboard stats change
```json
{
  "event": "stats_updated",
  "data": {
    "totalTransactionsToday": 46,
    "totalRevenue": 126680.50,
    "failedTransactions": 8
  }
}
```

**`user_activity`**: Broadcasted on user login/logout
```json
{
  "event": "user_activity",
  "data": {
    "username": "admin",
    "action": "login",
    "timestamp": "2024-01-15T10:30:00.000Z"
  }
}
```

## 🛡️ Security Features

### JWT Authentication
```typescript
// JWT Strategy Configuration
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: process.env.JWT_SECRET,
    });
  }

  async validate(payload: any) {
    return {
      id: payload.sub,
      username: payload.username,
      role: payload.role,
    };
  }
}
```

### Password Hashing
```typescript
// Secure password hashing with bcrypt
import * as bcrypt from 'bcryptjs';

async hashPassword(password: string): Promise<string> {
  const saltRounds = 12;
  return bcrypt.hash(password, saltRounds);
}

async validatePassword(password: string, hash: string): Promise<boolean> {
  return bcrypt.compare(password, hash);
}
```

### CORS Configuration
```typescript
// main.ts - CORS setup
app.enableCors({
  origin: ['http://localhost:8080', 'https://your-frontend-domain.com'],
  methods: ['GET', 'HEAD', 'PUT', 'PATCH', 'POST', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  credentials: true,
});
```

### Input Validation
```typescript
// DTO Validation with class-validator
export class CreatePaymentDto {
  @IsNumber()
  @IsPositive()
  @Max(1000000)
  amount: number;

  @IsIn(['credit_card', 'bank_transfer', 'digital_wallet'])
  method: string;

  @IsIn(['success', 'failed', 'pending'])
  status: string;

  @IsString()
  @MinLength(2)
  @MaxLength(100)
  receiver: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;
}
```

## 🧪 Testing

### Running Tests

```bash
# Unit tests
npm run test

# End-to-end tests
npm run test:e2e

# Test coverage
npm run test:cov

# Watch mode
npm run test:watch
```

### Test Structure
```
test/
├── unit/
│   ├── auth/
│   │   ├── auth.service.spec.ts
│   │   └── auth.controller.spec.ts
│   ├── payments/
│   │   ├── payments.service.spec.ts
│   │   └── payments.controller.spec.ts
│   └── users/
│       ├── users.service.spec.ts
│       └── users.controller.spec.ts
└── e2e/
    ├── auth.e2e-spec.ts
    ├── payments.e2e-spec.ts
    └── users.e2e-spec.ts
```

### Example Test
```typescript
describe('PaymentsService', () => {
  let service: PaymentsService;
  let repository: Repository<Payment>;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        PaymentsService,
        {
          provide: getRepositoryToken(Payment),
          useClass: Repository,
        },
      ],
    }).compile();

    service = module.get<PaymentsService>(PaymentsService);
    repository = module.get<Repository<Payment>>(getRepositoryToken(Payment));
  });

  it('should create a payment', async () => {
    const createPaymentDto = {
      amount: 100,
      method: 'credit_card',
      status: 'success',
      receiver: 'John Doe',
    };

    jest.spyOn(repository, 'save').mockResolvedValue(createPaymentDto as Payment);

    const result = await service.create(createPaymentDto);
    expect(result).toEqual(createPaymentDto);
  });
});
```

## 🚀 Deployment

### Environment Variables for Production
```env
# Production Database
DATABASE_URL=postgresql://user:password@prod-db-host:5432/payment_dashboard

# Security
JWT_SECRET=production-super-secret-key-minimum-32-characters
NODE_ENV=production

# Server
PORT=3000

# CORS
FRONTEND_URL=https://your-production-frontend.com
CORS_ORIGIN=https://your-production-frontend.com
```

### Docker Deployment

#### Dockerfile
```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE 3000

CMD ["npm", "run", "start:prod"]
```

#### docker-compose.yml
```yaml
version: '3.8'
services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/payment_dashboard
      - JWT_SECRET=your-jwt-secret
    depends_on:
      - db

  db:
    image: postgres:14
    environment:
      - POSTGRES_DB=payment_dashboard
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  postgres_data:
```

### Render.com Deployment

1. **Create Web Service**
   - Connect GitHub repository
   - Select Node.js environment

2. **Build Settings**
   ```bash
   Build Command: npm install && npm run build
   Start Command: npm run start:prod
   ```

3. **Environment Variables**
   - Add all production environment variables
   - Set `NODE_ENV=production`

4. **Database Setup**
   - Create PostgreSQL database service
   - Copy connection URL to `DATABASE_URL`

### Health Checks
```typescript
// Add health check endpoint
@Controller('health')
export class HealthController {
  @Get()
  healthCheck() {
    return {
      status: 'ok',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: process.env.NODE_ENV,
    };
  }
}
```

## 📊 Monitoring & Logging

### Request Logging
```typescript
// Custom logger interceptor
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const method = request.method;
    const url = request.url;
    const now = Date.now();

    return next.handle().pipe(
      tap(() => {
        const response = context.switchToHttp().getResponse();
        const delay = Date.now() - now;
        console.log(`${method} ${url} ${response.statusCode} - ${delay}ms`);
      }),
    );
  }
}
```

### Error Handling
```typescript
// Global exception filter
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    const status = exception instanceof HttpException 
      ? exception.getStatus() 
      : 500;

    const message = exception instanceof HttpException
      ? exception.getResponse()
      : 'Internal server error';

    response.status(status).json({
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      message,
    });
  }
}
```

## 🔧 Development Tips

### Database Migrations
```bash
# Generate migration
npm run typeorm:generate -- -n MigrationName

# Run migrations
npm run typeorm:run

# Revert migration
npm run typeorm:revert
```

### Debugging
```typescript
// Add debug logging
import { Logger } from '@nestjs/common';

@Injectable()
export class PaymentsService {
  private readonly logger = new Logger(PaymentsService.name);

  async create(createPaymentDto: CreatePaymentDto) {
    this.logger.debug(`Creating payment: ${JSON.stringify(createPaymentDto)}`);
    // ... service logic
  }
}
```

### Performance Optimization
```typescript
// Database indexing
@Entity('payments')
@Index(['status', 'createdAt'])
@Index(['method'])
export class Payment {
  // ... entity definition
}

// Query optimization
async findWithPagination(options: PaginationOptions) {
  return this.paymentRepository
    .createQueryBuilder('payment')
    .select(['payment.id', 'payment.amount', 'payment.status'])
    .where('payment.status = :status', { status: options.status })
    .orderBy('payment.createdAt', 'DESC')
    .skip((options.page - 1) * options.limit)
    .take(options.limit)
    .getMany();
}
```

## 🐛 Troubleshooting

### Common Issues

#### Database Connection
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Test connection
psql -h localhost -p 5432 -U username -d payment_dashboard
```

#### JWT Token Issues
```typescript
// Verify JWT secret
console.log('JWT Secret length:', process.env.JWT_SECRET?.length);
// Should be at least 32 characters
```

#### CORS Problems
```typescript
// Detailed CORS logging
app.use((req, res, next) => {
  console.log(`${req.method} ${req.path} - Origin: ${req.get('Origin')}`);
  next();
});
```

#### WebSocket Connection
```typescript
// WebSocket debugging
@WebSocketGateway({
  cors: {
    origin: process.env.FRONTEND_URL,
    credentials: true,
  },
})
export class PaymentsGateway {
  @WebSocketServer()
  server: Server;

  handleConnection(client: Socket) {
    console.log(`Client connected: ${client.id}`);
    console.log(`Total clients: ${this.server.engine.clientsCount}`);
  }

  handleDisconnect(client: Socket) {
    console.log(`Client disconnected: ${client.id}`);
  }
}
```

### Debug Commands
```bash
# Check environment variables
npm run start:dev | grep -E "(DATABASE|JWT|PORT)"

# Database query logging
NODE_ENV=development npm run start:dev

# Memory usage monitoring
node --inspect=0.0.0.0:9229 dist/main.js
```

## 📚 API Documentation

### Postman Collection
Import the following collection for API testing:

```json
{
  "info": {
    "name": "Payment Dashboard API",
    "description": "Complete API collection for testing"
  },
  "auth": {
    "type": "bearer",
    "bearer": [
      {
        "key": "token",
        "value": "{{jwt_token}}",
        "type": "string"
      }
    ]
  },
  "variable": [
    {
      "key": "base_url",
      "value": "http://localhost:3000/api"
    },
    {
      "key": "jwt_token",
      "value": ""
    }
  ]
}
```

### Swagger Documentation
```bash
# Access API documentation at:
http://localhost:3000/api/docs
```

## 🔗 Related Resources

- [NestJS Documentation](https://docs.nestjs.com/)
- [TypeORM Documentation](https://typeorm.io/)
- [Passport.js Documentation](http://www.passportjs.org/docs/)
- [Socket.IO Documentation](https://socket.io/docs/v4/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [JWT.io](https://jwt.io/) - JWT debugger

## 🤝 Contributing

### Development Workflow
1. Create feature branch from `main`
2. Write tests for new features
3. Ensure all tests pass
4. Update API documentation
5. Submit pull request

### Code Standards
- Follow NestJS conventions
- Use TypeScript strict mode
- Write comprehensive tests
- Document all public APIs
- Use meaningful commit messages

---

**🔧 Need support?** Check the main project README or create an issue in the repository.

#### Payment Entity
```typescript
@Entity('payments')
export class Payment {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column('decimal', { precision: 10, scale: 2 })
  amount: number;

  @Column()
  method: 'credit_card' | 'bank_transfer' | 'digital_wallet';

  @Column()
  status: 'success' | 'failed' | 'pending';

  @Column()
  receiver: string;

  @Column({ nullable: true })
  description: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
```

## 🚀 Installation & Setup

### Prerequisites
- **Node.js**: v18.0.0 or higher
- **npm**: v8.0.0 or higher
- **PostgreSQL**: v12.0 or higher

### 1. Install Dependencies
```bash
cd payment-dashboard-backend
npm install
```

### 2. Database Setup

#### Create Database
```sql
-- Connect to PostgreSQL as superuser
createdb payment_dashboard

-- Or using SQL
CREATE DATABASE payment_dashboard;
```

#### Environment Configuration
Create a `.env` file in the root directory:

```env
# Database Configuration
DATABASE_URL=postgresql://username:password@localhost:5432/payment_dashboard
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=your_username
DB_PASSWORD=your_password
DB_DATABASE=payment_dashboard

# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key-minimum-32-characters
JWT_EXPIRES_IN=24h

# Server Configuration
PORT=3000
NODE_ENV=development

# CORS Configuration
FRONTEND_URL=http://localhost:8080
CORS_ORIGIN=http://localhost:8080,https://your-frontend-domain.com
```

### 3. Database Migration & Seeding
```bash
# Run database migrations
npm run typeorm:run

# Seed initial data (creates default admin user)
npm run seed
```

### 4. Start the Server

#### Development Mode
```bash
npm run start:dev
```

#### Production Mode
```bash
npm run build
npm run start:prod
```

#### Debug Mode
```bash
npm run start:debug
```

The API will be available at `http://localhost:3000`

## 📡 API Endpoints

### 🔐 Authentication

#### POST `/api/auth/login`
Login with username and password.

**Request Body:**
```json
{
  "username": "admin",
  "password": "admin123"
}
```

**Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "uuid",
    "username": "admin",
    "role": "admin"
  }
}
```

#### GET `/api/auth/profile`
Get current user profile (Protected).

**Headers:**
```
Authorization: Bearer <jwt_token>
```

**Response:**
```json
{
  "id": "uuid",
  "username": "admin",
  "role": "admin",
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

### 💰 Payments

#### GET `/api/payments`
Get paginated list of payments with filtering.

**Query Parameters:**
- `page` (number): Page number (default: 1)
- `limit` (number): Items per page (default: 10)
- `status` (string): Filter by status (success, failed, pending)
- `method` (string): Filter by payment method
- `startDate` (string): Start date filter (ISO format)
- `endDate` (string): End date filter (ISO format)
- `search` (string): Search in receiver or description

**Example:**
```
GET /api/payments?page=1&limit=10&status=success&startDate=2024-01-01
```

**Response:**
```json
{
  "data": [
    {
      "id": "uuid",
      "amount": 1250.00,
      "method": "credit_card",
      "status": "success",
      "receiver": "John Doe",
      "description": "Online purchase",
      "createdAt": "2024-01-15T10:30:00.000Z"
    }
  ],
  "total": 150,
  "page": 1,
  "totalPages": 15
}
```

#### POST `/api/payments`
Create a new payment (simulate payment processing).

**Request Body:**
```json
{
  "amount": 1250.00,
  "method": "credit_card",
  "status": "success",
  "receiver": "John Doe",
  "description": "Online purchase"
}
```

**Response:**
```json
{
  "id": "uuid",
  "amount": 1250.00,
  "method": "credit_card",
  "status": "success",
  "receiver": "John Doe",
  "description": "Online purchase",
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-15T10:30:00.000Z"
}
```

#### GET `/api/payments/:id`
Get payment details by ID.

**Response:**
```json
{
  "id": "uuid",
  "amount": 1250.00,
  "method": "credit_card",
  "status": "success",
  "receiver": "John Doe",
  "description": "Online purchase",
  "createdAt": "2024-01-15T10:30:00.000Z",
  "updatedAt": "2024-01-15T10:30:00.000Z"
}
```

#### GET `/api/payments/stats`
Get dashboard statistics.

**Response:**
```json
{
  "totalTransactionsToday": 45,
  "totalTransactionsWeek": 312,
  "totalRevenue": 125430.50,
  "failedTransactions": 8,
  "successRate": 94.2,
  "revenueChart": [
    { "date": "2024-01-01", "amount": 5420.00 },
    { "date": "2024-01-02", "amount": 6230.50 }
  ],
  "methodDistribution": [
    { "method": "credit_card", "count": 156, "percentage": 65.2 },
    { "method": "bank_transfer", "count": 68, "percentage": 28.5 },
    { "method": "digital_wallet", "count": 15, "percentage": 6.3 }
  ]
}
```