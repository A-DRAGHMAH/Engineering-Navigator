# Engineering Navigator App

A comprehensive Flutter application designed to assist engineering students and faculty with academic resources, communication, and campus navigation.

## Features

### 1. User Interface
- Modern, responsive UI with dark/light theme support
- Smooth animations and transitions
- Custom geometric patterns and gradients for visual appeal
- Adaptive design for both mobile and desktop platforms

### 2. Core Functionalities

#### For Students
- **Study Materials Access**
  - Download and view course materials
  - Multiple file format support (PDF, documents, videos, presentations)
  - Organized by course, year, and semester

- **Engineering Assistant (AI Chatbot)**
  - Real-time assistance with engineering queries
  - Voice input support
  - Context-aware responses
  - Navigation suggestions to relevant resources

- **Faculty Information**
  - Access faculty profiles and contact information
  - Direct communication channels
  - Office hours and availability

#### For Administrators
- **Content Management**
  - Upload and manage study materials
  - Update faculty information
  - Manage campus maps and locations
  - Send notifications to users

### 3. Technical Features
- Firebase Integration
  - Authentication
  - Cloud Firestore for data storage
  - Firebase Storage for file management
- Real-time updates and notifications
- Cross-platform compatibility (iOS, Android, Web)
- Offline support capabilities

## Getting Started

### Prerequisites
- Flutter SDK (^3.5.4)
- Dart SDK
- Firebase account and project setup
- Android Studio / VS Code with Flutter plugins

### Installation

1. Clone the repository

2. Install dependencies

3. Configure Firebase
- Add your `google-services.json` for Android
- Add your `GoogleService-Info.plist` for iOS
- Configure web Firebase settings

4. Run the app

### Environment Setup
Ensure you have the following configurations:
- Minimum SDK version: 21 (Android)
- iOS deployment target: 12.0
- Web support enabled

## Dependencies

Key packages used:
- `firebase_core`: ^2.24.2
- `cloud_firestore`: ^4.14.0
- `firebase_storage`: ^11.6.0
- `firebase_auth`: ^4.20.0
- `url_launcher`: ^6.2.4
- `file_picker`: ^6.1.1
- `speech_to_text`: ^6.6.1
- `flutter_tts`: ^4.2.0
- `dart_openai`: ^5.1.0

## Architecture

The app follows a structured architecture:
- `lib/pages/` - UI screens and widgets
- `lib/services/` - Business logic and API services
- `lib/models/` - Data models
- `lib/config/` - Configuration files
- `lib/utils/` - Utility functions

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the [MIT License](LICENSE)

## Contact

AHMAD DRAGHMAH  - [engineering.navigator@gmail.com]
