# Renva - Service Marketplace Platform

<div align="center">
  <h3>🌟 Connect Service Seekers with Providers</h3>
  <p>A dual-sided service marketplace app built with Flutter</p>
</div>

---

## ⚠️ Development Status

**This project is currently under active development and not ready for production use.**

- 🚧 Core features are being implemented
- 🔄 API integration in progress  
- 🎨 UI/UX improvements ongoing
- 🧪 Testing and bug fixes needed

---

## 📱 Overview

**Renva** is a dual-sided service marketplace app that connects service seekers with service providers. Built with Flutter, the app offers a seamless experience for users to book services and for providers to manage their offerings.

### Key Features

- 🔄 **Dual Mode System**: Switch between User and Provider modes
- 🔐 **Complete Authentication Flow**: Registration, login, phone verification
- 👤 **Profile Management**: Comprehensive user and provider profiles with image upload
- 🛍️ **Service Categories**: Browse and select from various service categories
- 📋 **Order Management**: Create, track, and manage service orders
- 💼 **Provider Dashboard**: View orders, create offers, manage business
- 🖼️ **Image Upload**: Support for gallery and camera image capture
- 🌍 **Localization**: Multi-language support (English/Arabic)
- ⭐ **Rating System**: Rate and review service providers
- 📊 **Analytics**: Order history, earnings tracking, and performance metrics

---

## 🏗️ Architecture

The project follows a **feature-based clean architecture** structure:

```
lib/
├── core/                    # Core utilities and shared components
│   ├── config/             # App configuration and builders
│   ├── localization/       # i18n strings and translations
│   ├── routes/            # Navigation and routing
│   ├── services/          # API services and external integrations
│   ├── style/             # App themes and styling
│   └── widgets/           # Reusable UI components
├── features/              # Feature modules
│   ├── auth/              # Authentication (login, register, verify)
│   ├── home/              # Main dashboard and navigation
│   ├── add_orders/        # Order creation and management
│   ├── provider/          # Provider-specific features
│   ├── profile/           # User profile management
│   ├── main/              # App entry point and main navigation
│   └── splash/            # Splash screen
└── gen/                   # Generated assets and code
```

---

## 🛠️ Tech Stack

### Core Framework
- **Flutter SDK**: Cross-platform mobile development
- **Dart**: Programming language

### State Management & Architecture
- **GetX**: Reactive state management, dependency injection, and routing
- **Get Storage**: Local data persistence

### Networking & APIs
- **Dio**: HTTP client for REST API communication
- **Custom API Service**: Centralized API management with error handling

### UI & UX
- **Custom Widgets**: Reusable UI components
- **SVG Support**: Vector graphics rendering
- **Image Picker**: Camera and gallery integration
- **Responsive Design**: Adaptive layouts for different screen sizes

### Localization
- **Easy Localization**: Multi-language support
- **JSON Translation Files**: Organized translation resources

### Additional Features
- **Phone Number Validation**: International phone number handling
- **Image Upload**: Multi-image selection and upload
- **Form Validation**: Comprehensive input validation
- **Toast Notifications**: User feedback system

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extensions
- Xcode (for iOS development on macOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd renva0
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate assets**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

---

## 📱 App Flow

### User Journey
1. **Onboarding**: Splash screen and app introduction
2. **Authentication**: Register/Login with phone verification
3. **Profile Setup**: Complete profile information with images
4. **Browse Services**: Explore service categories and providers
5. **Place Orders**: Create service requests with details and images
6. **Track Orders**: Monitor order status and communicate with providers
7. **Rate & Review**: Provide feedback after service completion

### Provider Journey
1. **Provider Registration**: Apply to become a service provider
2. **Profile Verification**: Complete provider profile with business details
3. **Dashboard Access**: Switch to provider mode
4. **View Orders**: Browse available service requests
5. **Create Offers**: Submit proposals with pricing and timeline
6. **Manage Business**: Track earnings, ratings, and performance

---

## 🔧 Key Components

### Authentication System
- Phone number registration with OTP verification
- Secure login with token management
- Profile completion flow with image uploads

### Order Management
- Service category selection
- Detailed order creation with images
- Price range specification
- Date and time scheduling

### Provider Features
- Dual-mode user interface
- Order browsing and filtering
- Offer creation with custom pricing
- Business performance analytics

### API Integration
- RESTful API communication
- Centralized error handling
- Token-based authentication
- File upload support

---

## 🚧 Development Status & Roadmap

### ✅ Completed
- [x] Basic authentication flow
- [x] User interface structure
- [x] Provider mode implementation
- [x] Order creation system

### 🔄 In Progress
- [ ] API integration completion
- [ ] Image upload optimization
- [ ] Payment system integration
- [ ] Push notifications

### 📋 Planned Features
- [ ] Real-time chat system
- [ ] Advanced filtering
- [ ] Geolocation services
- [ ] Performance analytics

### ⚠️ Known Issues
- Some API endpoints still in development
- Image upload may have size limitations
- UI responsiveness needs improvement on tablets
- Localization incomplete for some screens
