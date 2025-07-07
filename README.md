# Ayni - Plant Health Assistant

Ayni is a Flutter application for plant disease detection using AI, built with MVVM architecture and BLoC pattern for state management.

## 🌱 Features

- **AI-Powered Plant Disease Detection**: Analyze plant photos to detect diseases
- **Dual Detection Modes**: Local and online detection capabilities
- **User Authentication**: Secure login and registration system
- **Detection History**: Track and review past plant analyses
- **Dark Mode Support**: Complete theme adaptation for better user experience
- **Offline Capability**: Works without internet using local AI models
- **Multi-language Support**: Internationalization ready
- **Responsive Design**: Optimized for various screen sizes

## 🏗️ Architecture Overview

This project follows the Model-View-ViewModel (MVVM) pattern combined with BLoC for state management:

### Layers
- **Presentation Layer**: UI components, BLoCs and ViewModels
- **Domain Layer**: Business logic and use cases
- **Data Layer**: Data sources, repositories and models

### Key Components
- **ViewModels**: Intermediaries between BLoCs and Use Cases, handling business logic
- **BLoC (Business Logic Component)**: Manages state and events for the UI
- **Use Cases**: Encapsulate specific business operations
- **Repositories**: Abstract data sources
- **Services**: Handle device-specific operations (storage, network, etc.)

## 🚀 Recent Updates (v1.0.1)

### ✨ New Features
- Complete dark mode support for all screens
- Improved theme consistency across the application
- Better color scheme adaptation for both light and dark themes

### 🔧 Improvements
- Refactored camera page into smaller, maintainable components
- Updated login screen to remove unused social login buttons
- Improved text visibility in dark mode for all input fields
- Enhanced UI components with proper theme color usage

### 🐛 Bug Fixes
- Fixed text visibility issues in dark mode for login screen
- Resolved input field color problems in dark theme
- Fixed camera page component organization and maintainability
- Corrected deprecated ColorScheme usage
- Fixed BuildContext usage across async gaps

### 🏗️ Technical Improvements
- Separated camera page into modular components:
  - `InitializingWidget`
  - `CameraErrorWidget`
  - `ProcessingWidget`
  - `ImageResultWidget`
  - `WelcomeWidget`
  - `CameraDialogs`
  - `utils.dart`
- Improved code organization and maintainability
- Enhanced error handling and user feedback
- Better separation of concerns in UI components

## 🛠️ Implementation Details

### Dependency Injection
- Using `get_it` for dependency injection to provide a clean way to access services throughout the app
- All dependencies are registered in `service_locator.dart`

### Authentication Flow
1. User enters credentials in the Login screen
2. ViewModel processes login through use cases
3. Repository communicates with the API endpoint
4. On success, token is stored in the device
5. User is redirected to the home screen

### Form Validation
- Using `formz` for form input validation
- Email and password validators ensure data integrity before submission

### AI Detection
- TFLite integration for local model inference
- Hybrid detection service supporting both local and online modes
- Image preprocessing and disease classification
- Confidence scoring and recommendations

## 🔗 Backend Integration
The application connects to the Ayni backend API at:
`https://ayni-backend-mono-d5akeuepdsgrauaa.canadacentral-01.azurewebsites.net/`

### Current implemented endpoints:
- Authentication: `api/v1/auth/sign-in`

## 📱 Screenshots

### Light Mode
- Login screen with improved visibility
- Camera interface with modular components
- Detection results with proper theming

### Dark Mode
- Complete dark theme support
- Enhanced contrast and readability
- Consistent color scheme across all screens

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (^3.8.1)
- Dart SDK
- Android Studio / VS Code
- Android SDK / Xcode (for mobile development)

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Ensure you have the required assets in the `assets/` folder
4. Run `flutter run` to start the application

### Building for Release
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📞 Support

For support and questions, please contact the development team or create an issue in the repository.

---

**Version**: 1.0.1  
**Last Updated**: January 7, 2025
