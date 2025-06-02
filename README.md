# Ayni

Ayni is a Flutter application using MVVM architecture and BLoC pattern for state management.

## Architecture Overview

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

## Implementation Details

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

## Backend Integration
The application connects to the Ayni backend API at:
`https://ayni-backend-mono-d5akeuepdsgrauaa.canadacentral-01.azurewebsites.net/`

### Current implemented endpoints:
- Authentication: `api/v1/auth/sign-in`

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
