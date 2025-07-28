# 📱 Payment Dashboard Frontend (Flutter)

A modern, responsive Flutter application for managing payments and transactions. Built with clean architecture principles and featuring real-time updates, interactive charts, and seamless API integration.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

## 🎯 Features

### 🔐 Authentication
- JWT-based secure login
- Auto-logout on token expiration
- Role-based UI rendering
- Persistent login sessions

### 📊 Dashboard
- **Real-time metrics**: Today's transactions, revenue, failed payments
- **Interactive charts**: Revenue trends using `fl_chart`
- **Quick stats cards**: Visual indicators with colors
- **Live updates**: WebSocket integration for real-time data

### 💰 Transaction Management
- **Paginated list**: Efficient data loading
- **Advanced filtering**: Date range, status, payment method
- **Detailed views**: Click to view transaction details
- **Search functionality**: Find specific transactions

### 👥 User Management
- **User listing**: View all system users
- **Add new users**: Create admin/viewer accounts
- **Role management**: Assign appropriate permissions

### ⚡ Payment Simulation
- **Create payments**: Simulate new transactions
- **Multiple methods**: Credit card, bank transfer, digital wallet
- **Status selection**: Success, failed, pending
- **Real-time updates**: Instant reflection in dashboard

## 🏗️ Architecture

### Project Structure
```
lib/
├── 📄 main.dart                 # App entry point & navigation
├── 📁 models/                   # Data models
│   ├── dashboard_stats.dart     # Dashboard metrics model
│   ├── login_response.dart      # Auth response model
│   ├── payment.dart             # Payment transaction model
│   ├── payment_list_response.dart # API response wrapper
│   └── user.dart                # User model
├── 📁 screens/                  # UI screens
│   ├── add_payment_screen.dart  # Payment creation form
│   ├── dashboard_screen.dart    # Main dashboard
│   ├── login_screen.dart        # Authentication
│   ├── transactions_screen.dart # Transaction list
│   └── users_screen.dart        # User management
├── 📁 services/                 # Business logic
│   ├── auth_service.dart        # Authentication service
│   ├── payment_service.dart     # Payment API service
│   ├── user_service.dart        # User management service
│   └── websocket_service.dart   # Real-time updates
└── 📁 widgets/                  # Reusable components
    ├── payment_card.dart        # Transaction card UI
    ├── revenue_chart.dart       # Chart component
    └── stats_card.dart          # Metric display card
```

### State Management
- **Provider**: Primary state management solution
- **ChangeNotifier**: For reactive service classes
- **ProxyProvider**: For service dependencies
- **Consumer**: For UI updates

## 🔧 Installation & Setup

### Prerequisites
```bash
flutter --version  # Ensure Flutter 3.8.0+
dart --version     # Ensure Dart 3.0.0+
```

### 1. Install Dependencies
```bash
cd frontend
flutter pub get
```

### 2. Configuration
Update the API base URL in `lib/services/auth_service.dart`:

```dart
class AuthService extends ChangeNotifier {
  static const String baseUrl = 'http://localhost:3000/api';  // Development
  // static const String baseUrl = 'https://your-api-domain.com/api';  // Production
}
```

### 3. Run the Application

#### Web Development
```bash
flutter run -d web --web-port 8080
```

#### Mobile Development
```bash
# Android
flutter run -d android

# iOS (macOS only)
flutter run -d ios
```

#### Build for Production
```bash
# Web
flutter build web --release

# Android APK
flutter build apk --release

# iOS (macOS only)
flutter build ios --release
```

## 📦 Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter: sdk: flutter
  
  # HTTP & API
  http: ^1.1.0                    # REST API calls
  
  # State Management
  provider: ^6.0.5               # State management
  
  # Local Storage
  shared_preferences: ^2.2.2     # JWT token storage
  
  # Charts & Visualization
  fl_chart: ^0.65.0              # Interactive charts
  
  # Utilities
  json_annotation: ^4.9.0        # JSON serialization
  intl: ^0.18.1                  # Date formatting
  
  # Real-time
  socket_io_client: ^2.0.3+1     # WebSocket client
  
  # File Operations
  path_provider: ^2.1.1          # File system access
  csv: ^5.0.2                    # CSV export
```

### Development Dependencies
```yaml
dev_dependencies:
  flutter_test: sdk: flutter
  json_serializable: ^6.7.1      # Code generation
  build_runner: ^2.4.7           # Build tools
  flutter_lints: ^3.0.0          # Linting rules
```

## 🎨 UI Components

### Custom Widgets

#### StatsCard
```dart
StatsCard(
  title: 'Total Revenue',
  value: '\$45,230',
  icon: Icons.attach_money,
  color: Colors.green,
  trend: '+12.5%',
)
```

#### PaymentCard
```dart
PaymentCard(
  payment: paymentObject,
  onTap: () => showPaymentDetails(),
)
```

#### RevenueChart
```dart
RevenueChart(
  data: chartData,
  height: 300,
)
```

### Theme Configuration
```dart
ThemeData(
  primarySwatch: Colors.blue,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.blue[800],
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  cardTheme: CardThemeData(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  ),
)
```

## 🔌 API Integration

### Service Architecture
All API calls are handled through dedicated service classes:

#### AuthService
```dart
class AuthService extends ChangeNotifier {
  String? _token;
  User? _user;
  bool _isLoading = false;
  
  Future<bool> login(String username, String password) async {
    // Login implementation
  }
  
  void logout() {
    // Logout implementation
  }
}
```

#### PaymentService
```dart
class PaymentService extends ChangeNotifier {
  Future<PaymentListResponse> getPayments({
    int page = 1,
    int limit = 10,
    Map<String, dynamic>? filters,
  }) async {
    // Fetch payments with pagination and filters
  }
}
```

### Error Handling
- **Network errors**: Graceful handling with user-friendly messages
- **Authentication errors**: Automatic logout and redirect to login
- **Validation errors**: Field-specific error messages
- **Loading states**: Visual feedback during API calls

## 🌐 WebSocket Integration

### Real-time Features
```dart
class WebSocketService extends ChangeNotifier {
  void connect() {
    socket = io(baseUrl, <String, dynamic>{
      'transports': ['websockets'],
      'autoConnect': false,
    });
    
    socket.on('payment_created', (data) {
      // Handle new payment notifications
    });
    
    socket.on('stats_updated', (data) {
      // Handle dashboard stats updates
    });
  }
}
```

### Event Types
- `payment_created`: New payment added
- `payment_updated`: Payment status changed
- `stats_updated`: Dashboard metrics updated
- `user_activity`: User login/logout events

## 📱 Responsive Design

### Screen Breakpoints
- **Mobile**: < 600px width
- **Tablet**: 600px - 1024px width
- **Desktop**: > 1024px width

### Adaptive Layouts
```dart
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth > 1024) {
        return DesktopLayout();
      } else if (constraints.maxWidth > 600) {
        return TabletLayout();
      } else {
        return MobileLayout();
      }
    },
  );
}
```

## 🧪 Testing

### Running Tests
```bash
# All tests
flutter test

# Specific test file
flutter test test/services/auth_service_test.dart

# Coverage report
flutter test --coverage
```

### Test Structure
```
test/
├── services/
│   ├── auth_service_test.dart
│   ├── payment_service_test.dart
│   └── user_service_test.dart
├── widgets/
│   ├── stats_card_test.dart
│   └── payment_card_test.dart
└── screens/
    ├── login_screen_test.dart
    └── dashboard_screen_test.dart
```

## 🚀 Deployment

### Web Deployment (Render.com)
1. **Create Static Site**: Connect GitHub repository
2. **Build Settings**:
   ```bash
   Build Command: flutter build web --release
   Publish Directory: build/web
   ```
3. **Environment Variables**: Add any required config

### Mobile Deployment

#### Android (Google Play)
```bash
flutter build appbundle --release
```

#### iOS (App Store)
```bash
flutter build ios --release
```

## 🔧 Development Tips

### Code Generation
```bash
# Generate JSON serialization code
flutter packages pub run build_runner build

# Watch for changes
flutter packages pub run build_runner watch
```

### Debugging
```bash
# Debug mode with detailed logging
flutter run --debug -d web --web-port 8080

# Profile mode for performance testing
flutter run --profile
```

### Performance Optimization
- **ListView.builder**: For large lists
- **Image caching**: Optimize network images
- **State management**: Minimize unnecessary rebuilds
- **Lazy loading**: Load data on demand

## 🎯 Best Practices

### Code Organization
- **Single Responsibility**: Each widget/service has one purpose
- **Dependency Injection**: Use Provider for service injection
- **Error Boundaries**: Wrap widgets with error handling
- **Loading States**: Always show loading indicators

### Security
- **Token Storage**: Secure storage with shared_preferences
- **Input Validation**: Sanitize all user inputs
- **HTTPS Only**: Force secure connections
- **Auto Logout**: Clear tokens on expiration

## 🐛 Troubleshooting

### Common Issues

#### Build Errors
```bash
# Clean build files
flutter clean
flutter pub get

# Reset Flutter
flutter doctor
```

#### CORS Issues
```dart
// Ensure backend CORS is configured for your domain
app.enableCors({
  origin: 'https://your-flutter-app.com',
  credentials: true,
});
```

#### WebSocket Connection
```dart
// Check WebSocket URL and authentication
socket = io('ws://localhost:3000', {
  'transports': ['websocket'],
  'extraHeaders': {'Authorization': 'Bearer $token'}
});
```

### Debug Commands
```bash
# Check Flutter setup
flutter doctor -v

# Analyze code
flutter analyze

# Check dependencies
flutter pub deps
```

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider State Management](https://pub.dev/packages/provider)
- [FL Chart Documentation](https://pub.dev/packages/fl_chart)
- [Socket.IO Client](https://pub.dev/packages/socket_io_client)
- [Flutter Web Deployment](https://docs.flutter.dev/deployment/web)

---

**Need help?** Check the main project README or contact the development team.