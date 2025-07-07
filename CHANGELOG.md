# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2025-01-07

### Added
- Complete dark mode support for all screens
- Improved theme consistency across the application
- Better color scheme adaptation for both light and dark themes

### Changed
- Refactored camera page into smaller, maintainable components
- Updated login screen to remove unused social login buttons
- Improved text visibility in dark mode for all input fields
- Enhanced UI components with proper theme color usage

### Fixed
- Fixed text visibility issues in dark mode for login screen
- Resolved input field color problems in dark theme
- Fixed camera page component organization and maintainability
- Corrected deprecated ColorScheme usage (background → surface)
- Fixed BuildContext usage across async gaps

### Technical Improvements
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

## [1.0.0] - 2025-01-01

### Added
- Initial release of Ayni Plant Health Assistant
- Plant disease detection using AI
- User authentication system
- Camera integration for plant photos
- Detection history tracking
- Multi-language support
- Responsive design for multiple screen sizes

### Features
- AI-powered plant disease detection
- Local and online detection modes
- User profile management
- Plant health recommendations
- Offline capability with local models
- Modern Material Design 3 UI 