#  Service Marketplace App

A comprehensive Flutter mobile application that connects customers with service providers across various categories including household services, professional services, personal care, and logistics.

## 📱 Features

### Customer Features
- **Service Discovery**: Browse and search through multiple service categories
- **Order Management**: Create, track, and manage service orders
- **Provider Selection**: Choose from vetted service providers
- **Real-time Communication**: Chat with service providers
- **Photo Upload**: Add photos to service requests for better clarity
- **Multi-language Support**: Available in English and Arabic
- **Price Range Filtering**: Filter services by budget

### Provider Features
- **Provider Dashboard**: Dedicated interface for service providers
- **Order Management**: Accept, decline, and manage service orders
- **Offer System**: Submit competitive offers for services
- **Profile Management**: Maintain detailed provider profiles
- **Real-time Notifications**: Get instant updates on new orders

### Service Categories
- **Household Services**: Cleaning, washing, plant care, pet care
- **Professional Services**: Electrical work, plumbing, painting
- **Personal Services**: Personal training, tutoring
- **Logistical Services**: Package delivery, moving, transportation

## 🛠️ Tech Stack

- **Framework**: Flutter
- **State Management**: GetX
- **HTTP Client**: Dio
- **Localization**: Easy Localization
- **Local Storage**: GetStorage
- **Image Handling**: Image Picker
- **UI Components**: Custom widgets with modern design

## 📋 Prerequisites

Before running this project, make sure you have:

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code
- Android SDK for Android development


## 📁 Project Structure

```
lib/
├── core/
│   ├── config/           # App configuration
│   ├── localization/     # Internationalization files
│   ├── routes/          # App routing
│   ├── services/        # API services and utilities
│   └── style/           # App themes and styling
├── features/
│   ├── auth/            # Authentication flow
│   ├── home/            # Home and main screens
│   ├── add_orders/      # Order creation flow
│   ├── provider/        # Provider-specific features
│   └── profile/         # User profile management
└── main.dart           # App entry point
```

## 🌐 API Integration

The app integrates with a RESTful API for:
- User authentication
- Service category management
- Order processing
- Provider management
- Real-time updates


## 🌍 Localization

Currently supports:
- English (en)
- Arabic (ar)

## 📱 Screenshots

....


- Easy Localization for internationalization support

---

**Made with ❤️ using Flutter**
