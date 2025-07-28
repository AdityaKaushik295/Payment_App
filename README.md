# 💳 Full-Stack Payment Dashboard System

A comprehensive real-time payment management dashboard built with **Flutter** (frontend) and **NestJS** (backend). This system provides admins with tools to view transactions, manage users, simulate payments, and analyze revenue trends.

![Dashboard Preview](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![NestJS](https://img.shields.io/badge/nestjs-%23E0234E.svg?style=for-the-badge&logo=nestjs&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/postgresql-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)
![JWT](https://img.shields.io/badge/JWT-black?style=for-the-badge&logo=JSON%20web%20tokens)

## 🎯 Project Overview

### Features
- **🔐 Secure Authentication**: JWT-based login with role-based access control
- **📊 Real-time Dashboard**: Live transaction metrics and revenue charts
- **💰 Transaction Management**: Filter, search, and view detailed payment information
- **👥 User Management**: Add and manage admin users and viewers
- **⚡ Payment Simulation**: Create and test payment flows
- **📈 Analytics**: Revenue trends and failed transaction reports
- **🔄 Real-time Updates**: WebSocket integration for live data
- **📤 Data Export**: CSV export functionality for transactions

### Tech Stack
| Layer | Technology |
|-------|------------|
| **Frontend** | Flutter (Mobile/Web) |
| **Backend** | NestJS (Node.js) |
| **Database** | PostgreSQL |
| **Authentication** | JWT with Passport |
| **Real-time** | WebSockets (Socket.io) |
| **State Management** | Provider (Flutter) |
| **Charts** | fl_chart |
| **Deployment** | Render.com |

## 🏗️ Project Structure

```
📦 FULLSTACK_PAYMENT_DASHBOARD/
├── 📱 frontend/                 # Flutter application
│   ├── lib/
│   │   ├── models/             # Data models
│   │   ├── screens/            # UI screens
│   │   ├── services/          # API & business logic
│   │   ├── widgets/           # Reusable components
│   │   └── main.dart          # App entry point
│   ├── pubspec.yaml           # Flutter dependencies
│   └── README.md              # Frontend documentation
├── 🖥️ payment-dashboard-backend/ # NestJS API
│   ├── src/
│   │   ├── auth/              # Authentication module
│   │   ├── payments/          # Payment management
│   │   ├── users/             # User management
│   │   ├── socket/            # WebSocket gateway
│   │   └── main.ts            # Server entry point
│   ├── package.json           # Backend dependencies
│   └── README.md              # Backend documentation
└── README.md                  # This file
```

## 🚀 Quick Start

### Prerequisites
- **Node.js** (v18+ recommended)
- **Flutter SDK** (v3.8.0+)
- **PostgreSQL** (v12+)
- **Git**

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/fullstack-payment-dashboard.git
cd fullstack-payment-dashboard
```

### 2. Backend Setup
```bash
cd payment-dashboard-backend
npm install
```

Create a `.env` file:
```env
DATABASE_URL=postgresql://username:password@localhost:5432/payment_dashboard
JWT_SECRET=your-super-secret-jwt-key-here
PORT=3000
```

Start the backend:
```bash
npm run start:dev
```

The API will be available at `http://localhost:3000`

### 3. Frontend Setup
```bash
cd frontend
flutter pub get
```

Update API endpoint in `lib/services/auth_service.dart`:
```dart
static const String baseUrl = 'http://localhost:3000/api';
```

Run the Flutter app:
```bash
flutter run -d web  # For web
# OR
flutter run         # For mobile
```

## 🔑 Default Credentials

Use these credentials to log into the dashboard:

| Role | Username | Password |
|------|----------|----------|
| Admin | `admin` | `admin123` |
| Viewer | `viewer` | `viewer123` |

## 📱 Application Screenshots

### Dashboard Overview
- Real-time transaction metrics
- Revenue chart visualization
- Quick stats cards

### Transaction Management
- Paginated transaction list
- Advanced filtering options
- Detailed payment views

### User Management
- Add new users
- Role-based permissions
- User activity tracking

## 🔗 API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `GET /api/auth/profile` - Get user profile

### Payments
- `GET /api/payments` - List payments with filters
- `POST /api/payments` - Create new payment
- `GET /api/payments/:id` - Get payment details
- `GET /api/payments/stats` - Dashboard statistics
- `GET /api/payments/export` - Export as CSV

### Users
- `GET /api/users` - List users
- `POST /api/users` - Create new user

## 🌐 Deployment

### Backend (Render.com)
1. Create a new Web Service on Render
2. Connect your GitHub repository
3. Set build command: `npm install && npm run build`
4. Set start command: `npm run start:prod`
5. Add environment variables

### Frontend (Render.com)
1. Create a new Static Site on Render
2. Set build command: `flutter build web`
3. Set publish directory: `build/web`

## 🧪 Testing

### Backend Tests
```bash
cd payment-dashboard-backend
npm run test        # Unit tests
npm run test:e2e    # End-to-end tests
npm run test:cov    # Coverage report
```

### Frontend Tests
```bash
cd frontend
flutter test
```

## 🔧 Development

### Adding New Features
1. **Backend**: Create modules in `src/` following NestJS patterns
2. **Frontend**: Add screens in `lib/screens/` and services in `lib/services/`
3. **Models**: Update both Flutter models and NestJS DTOs

### Database Schema
The application uses TypeORM with PostgreSQL. Key entities:
- **User**: Authentication and roles
- **Payment**: Transaction records
- **Event**: WebSocket events (optional)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

If you encounter any issues:

1. Check the individual README files in `frontend/` and `payment-dashboard-backend/`
2. Ensure all environment variables are properly set
3. Verify database connection
4. Check that both frontend and backend are running on correct ports

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [NestJS Documentation](https://docs.nestjs.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Socket.io Documentation](https://socket.io/docs/)

---

**Built with ❤️ using Flutter & NestJS**