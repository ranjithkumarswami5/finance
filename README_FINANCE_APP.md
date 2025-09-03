# Finance Management App

A comprehensive Flutter-based mobile application for managing financial transactions, tracking collections, and calculating interest automatically.

## 🚀 Features

### ✅ **Implemented Features**

#### **Authentication & Authorization**
- **JWT-based authentication** with secure token management
- **Role-based access control** (Super Admin, Admin, Staff)
- **Secure storage** using Flutter Secure Storage
- **Auto token refresh** mechanism
- **Mock API fallback** for development/testing

#### **User Management**
- **Multi-role system** with different permission levels
- **Profile management** with secure data handling
- **User session management** with automatic logout

#### **Core Functionality**
- **Transaction recording** with detailed information
- **Customer management** with credit limits
- **Dashboard** with key financial metrics
- **Responsive UI** with Material Design 3
- **Offline capability** with local storage

#### **Technical Features**
- **State management** using Provider pattern
- **Clean architecture** with organized folder structure
- **Error handling** with user-friendly messages
- **Loading states** and progress indicators
- **Form validation** with real-time feedback
- **Light/Dark theme support** with persistent storage
- **Theme toggle** available on all screens

### 🔧 **Technology Stack**

#### **Frontend (Flutter)**
- **Flutter SDK**: ^3.9.0
- **State Management**: Provider
- **HTTP Client**: Dio
- **Local Storage**: Shared Preferences + Secure Storage
- **Navigation**: Go Router
- **UI Components**: Material Design 3

#### **Backend (Spring Boot + PostgreSQL)**
- **Spring Boot** with PostgreSQL database
- **JWT Authentication** with role-based authorization
- **RESTful APIs** with comprehensive endpoints
- **Database**: PostgreSQL connection to `157.254.189.56:5050/finance`
- **Redis Caching** for performance optimization
- **Audit Logging** for security and compliance

## 🔧 **Backend Setup (Spring Boot + PostgreSQL)**

### **Prerequisites**
- **Java 17+** installed
- **PostgreSQL 13+** running
- **Maven 3.6+** or **Gradle**
- **Git** for cloning repositories

### **Database Setup**
```sql
-- Create database
CREATE DATABASE finance;

-- Create user (optional, can use postgres user)
CREATE USER finance_user WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE finance TO finance_user;
```

### **Spring Boot Configuration**
1. **Create Spring Boot project** with these dependencies:
   ```xml
   <!-- pom.xml dependencies -->
   <dependencies>
       <dependency>
           <groupId>org.springframework.boot</groupId>
           <artifactId>spring-boot-starter-web</artifactId>
       </dependency>
       <dependency>
           <groupId>org.springframework.boot</groupId>
           <artifactId>spring-boot-starter-data-jpa</artifactId>
       </dependency>
       <dependency>
           <groupId>org.springframework.boot</groupId>
           <artifactId>spring-boot-starter-security</artifactId>
       </dependency>
       <dependency>
           <groupId>org.postgresql</groupId>
           <artifactId>postgresql</artifactId>
           <scope>runtime</scope>
       </dependency>
       <dependency>
           <groupId>io.jsonwebtoken</groupId>
           <artifactId>jjwt</artifactId>
           <version>0.9.1</version>
       </dependency>
       <dependency>
           <groupId>org.springframework.boot</groupId>
           <artifactId>spring-boot-starter-data-redis</artifactId>
       </dependency>
   </dependencies>
   ```

2. **Configure `application.properties`** (see `application.properties` file):
   ```properties
   # Database Connection
   spring.datasource.url=jdbc:postgresql://157.254.189.56:5050/finance
   spring.datasource.username=postgres
   spring.datasource.password=Ranjith@123

   # Server Configuration
   server.port=8080

   # JWT Configuration
   app.jwt.secret=mySecretKey12345678901234567890123456789012345678901234567890
   app.jwt.expiration=86400000
   ```

3. **Create Entity Classes** based on `database_schema.sql`

4. **Implement Controllers** (see sample `AuthController.java`, `TransactionController.java`, `DashboardController.java`)

5. **Configure Security** with JWT authentication

### **Database Connection Details**
- **Host**: 157.254.189.56
- **Port**: 5050
- **Database**: finance
- **Username**: postgres
- **Password**: Ranjith@123

### **API Endpoints**
```
POST   /api/auth/login          - User login
POST   /api/auth/register       - User registration
POST   /api/auth/refresh        - Refresh JWT token
GET    /api/transactions        - Get transactions (paginated)
POST   /api/transactions        - Create transaction
GET    /api/transactions/{id}   - Get transaction by ID
PUT    /api/transactions/{id}   - Update transaction
DELETE /api/transactions/{id}   - Delete transaction
GET    /api/customers           - Get customers (paginated)
GET    /api/dashboard           - Get dashboard data
```

### **Testing Backend Connection**
```bash
# Test health endpoint
curl http://157.254.189.56:8080/actuator/health

# Test login endpoint
curl -X POST http://157.254.189.56:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

## 📱 **Screenshots & UI**

### **Login Screen**
- Clean, professional login interface
- Form validation with error messages
- Remember me functionality
- Demo credentials displayed for testing

### **Dashboard**
- Financial overview with key metrics
- Quick action buttons
- Recent activity feed
- Navigation drawer with role-based menu
- **Theme toggle** in app bar for light/dark mode switching

### **Theme Support**
- **Light and Dark Mode** with automatic system detection
- **Persistent theme storage** - remembers user preference
- **Theme toggle buttons** on all screens (Login, Dashboards)
- **Smooth theme transitions** with Material Design 3
- **Toast notifications** when switching themes

### **Demo Credentials - Test Different Dashboards**

```
Super Admin: admin / admin123     → Full organization access
Admin: manager / manager123       → Department management
Staff: staff / staff123          → Individual collections
```

### **Dashboard Features by Role**

| Feature | Staff | Admin | Super Admin |
|---------|-------|-------|-------------|
| View Daily Collections | ✅ | ✅ | ✅ |
| Submit Transactions | ✅ | ❌ | ❌ |
| Approve Transactions | ❌ | ✅ | ✅ |
| Manage Staff | ❌ | ✅ | ✅ |
| View Department Reports | ❌ | ✅ | ✅ |
| Organization Overview | ❌ | ❌ | ✅ |
| System Health Monitoring | ❌ | ❌ | ✅ |
| User Management | ❌ | ❌ | ✅ |
| Audit Logs | ❌ | ❌ | ✅ |

## 🏗️ **Project Structure**

```
lib/
├── config/
│   └── constants.dart          # App constants and configuration
├── models/
│   ├── user.dart              # User data model
│   ├── transaction.dart       # Transaction data model
│   └── customer.dart          # Customer data model
├── providers/
│   ├── auth_provider.dart     # Authentication state management
│   └── theme_provider.dart    # Theme management
├── services/
│   ├── api_service.dart       # HTTP client with interceptors
│   ├── auth_service.dart      # Authentication business logic
│   ├── storage_service.dart   # Local storage management
│   └── mock_api_service.dart  # Mock API for development
├── screens/
│   ├── auth/
│   │   └── login_screen.dart  # Login screen
│   ├── dashboard/
│   │   └── dashboard_screen.dart # Generic dashboard
│   ├── dashboards/
│   │   ├── staff_dashboard.dart    # Staff-specific dashboard
│   │   ├── admin_dashboard.dart    # Admin-specific dashboard
│   │   └── super_admin_dashboard.dart # Super Admin dashboard
│   ├── transactions/
│   │   └── transactions_screen.dart # Transaction management
│   └── splash_screen.dart     # Splash screen
├── utils/
│   └── routes.dart            # App routing configuration
├── widgets/
│   └── loading_button.dart    # Reusable loading button
└── main.dart                  # App entry point
```

## 🚀 **Getting Started**

### **Prerequisites**
- Flutter SDK (^3.9.0)
- Android Studio / VS Code
- Android/iOS device or emulator

### **Installation**

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd flutter_application_1
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### **Development Setup**

The app is configured to work with **Mock API** by default for development purposes. When the backend server is not available, it automatically falls back to mock responses.

#### **To use with real backend:**
1. Update `MockApiService.shouldUseMock()` to return `false`
2. Ensure Spring Boot backend is running on `157.254.189.56:8080`
3. Configure PostgreSQL database connection

## 📊 **Database Schema**

The application uses a comprehensive PostgreSQL database with the following main tables:

- **users**: User accounts with role-based permissions
- **transactions**: Financial transactions with status tracking
- **customers**: Customer information and credit limits
- **daily_collections**: Collection records with payment methods
- **interest_rates**: Configurable interest rate settings
- **audit_logs**: Complete audit trail for all operations

See `database_schema.sql` for complete database structure.

## 🔐 **Security Features**

- **JWT token authentication** with secure storage
- **Role-based access control** with granular permissions
- **Secure API communication** with request/response interceptors
- **Automatic token refresh** mechanism
- **Secure local storage** for sensitive data

## 🎯 **Key Components**

### **Authentication Flow**
1. **Splash Screen** → Check authentication status
2. **Login Screen** → JWT token generation
3. **Role-Based Dashboard** → Automatic routing based on user role
4. **Auto Logout** → Token expiration handling

### **Role-Based Dashboards**

#### **👤 Staff Dashboard**
- **Daily Collections Overview** - View assigned collections and pending amounts
- **Performance Tracking** - Personal performance metrics and targets
- **Transaction Submission** - Submit new transactions for approval
- **Collection Recording** - Record payments from customers
- **Limited Access** - Only see relevant data for their role

#### **👨‍💼 Admin Dashboard**
- **Department Overview** - Total collections from all staff under supervision
- **Staff Performance** - Monitor individual staff performance and targets
- **Approval Management** - Approve/reject transactions submitted by staff
- **Departmental Reports** - Generate reports for their department
- **Staff Management** - Add and manage staff members

#### **👑 Super Admin Dashboard**
- **Organization Overview** - Complete organization-wide financial data
- **Admin Performance** - Monitor all admins and their departments
- **System Health** - Server status, database health, API response times
- **User Management** - Full control over all users, roles, and permissions
- **Audit Logs** - Complete audit trail of all system activities
- **System Settings** - Configure organization-wide settings

### **State Management**
- **AuthProvider**: Manages authentication state and user permissions
- **ThemeProvider**: Handles light/dark theme switching with persistence
- **Local Storage**: Secure storage for tokens, user data, and preferences
- **Provider Pattern**: Reactive UI updates across the entire app

### **Backend Integration**
- **Spring Boot**: REST API backend with PostgreSQL database
- **JWT Authentication**: Secure token-based authentication
- **Role-based Authorization**: Super Admin, Admin, Staff permissions
- **Real-time Sync**: Automatic data synchronization with backend
- **Offline Support**: Local storage with sync capabilities

### **API Integration**
- **Dio HTTP Client** with interceptors
- **Automatic retry** on token expiration
- **Mock API fallback** for development
- **Error handling** with user feedback

## 📈 **Performance Optimizations**

- **Efficient state management** with Provider
- **Lazy loading** for large datasets
- **Local caching** for offline capability
- **Optimized UI rendering** with proper keys
- **Memory management** with proper disposal

## 🔄 **Development Workflow**

### **Adding New Features**
1. Create models in `lib/models/`
2. Add API calls in `lib/services/`
3. Create UI screens in `lib/screens/`
4. Add state management in `lib/providers/`
5. Update routing in `lib/utils/routes.dart`

### **Testing**
```bash
# Run tests
flutter test

# Run integration tests
flutter test integration_test/
```

## 🚀 **Deployment**

### **Android**
```bash
flutter build apk --release
```

### **iOS**
```bash
flutter build ios --release
```

## 📝 **API Documentation**

### **Authentication Endpoints**
- `POST /api/auth/login` - User login
- `POST /api/auth/refresh` - Token refresh
- `POST /api/auth/logout` - User logout

### **Main Endpoints**
- `GET /api/transactions` - Get transactions
- `GET /api/customers` - Get customers
- `GET /api/dashboard` - Dashboard data
- `POST /api/transactions` - Create transaction

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 **License**

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 **Troubleshooting**

### **Connection Issues**
- The app automatically falls back to mock API when backend is unavailable
- Check network connectivity for real API calls
- Verify Spring Boot server is running on correct port

### **Build Issues**
- Ensure Flutter SDK version matches requirements
- Run `flutter clean` and `flutter pub get`
- Check Android/iOS development setup

### **Authentication Issues**
- Clear app data to reset authentication state
- Check token expiration and refresh mechanism
- Verify user credentials and roles

---

**Note**: This application is designed to work seamlessly with both mock data (for development) and real Spring Boot backend (for production). The mock API provides a complete development experience without requiring backend setup.