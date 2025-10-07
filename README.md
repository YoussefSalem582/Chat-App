# Chat App

A modern chat application built with Flutter and Firebase, featuring a clean UI and real-time messaging capabilities.

## Features

- 🌓 Light and Dark mode themes
- 🔐 Secure authentication with Firebase
- 💬 Real-time messaging
- 📱 Cross-platform support (iOS, Android, Web)
- 🎨 Customizable user interface

## Screenshots

<p float="left">
  <img src="https://github.com/user-attachments/assets/1ab00436-b4a9-4c5e-8ac6-993d4217b049" width="200" alt="Login Screen"/>
  <img src="https://github.com/user-attachments/assets/04f9ffdc-141a-483d-834b-fcc1a9f44ec4" width="200" alt="Chat Screen"/>
  <img src="https://github.com/user-attachments/assets/82e8e26e-153f-46a8-afa8-fea30a4bdeeb" width="200" alt="Home screen"/>
  <img src="https://github.com/user-attachments/assets/e26bca29-3b22-4bd8-a435-c13045ffab45" width="200" alt="drawer"/>
  <img src="https://github.com/user-attachments/assets/804f23ab-873b-44e9-81c9-40dc4ae52c72" width="200" alt="Chat"/>
  <img src="https://github.com/user-attachments/assets/fe3e933e-28ab-466e-81c3-45c2c1c13e78" width="200" alt="Settings"/>
  <img src="https://github.com/user-attachments/assets/d6649551-24cf-414d-b923-212bebbac7dc" width="200" alt="light Mode"/>
</p>

## Getting Started

### Prerequisites

- [Flutter](https://flutter.dev/docs/get-started/install) (2.0.0 or higher)
- [Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)

### Installation

1. Clone the repository:
   ```sh
   git clone https://github.com/ysalem2182/chat_app.git
   cd chat_app
   ```

2. Install dependencies:
   ```sh
   flutter pub get
   ```

3. Configure Firebase:
    - Create a new Firebase project
    - Add Android & iOS apps in Firebase Console
    - Download and place configuration files:
        - Android: `google-services.json` in `android/app`
        - iOS: `GoogleService-Info.plist` in `ios/Runner`

### Running the App

```sh
flutter run
```

## Project Structure

```
lib/
├── main.dart                  # App entry point
├── components/                # Reusable UI components
│   ├── chat_bubble.dart       # Chat message bubble widget
│   ├── my_button.dart         # Custom button widget
│   ├── my_drawer.dart         # App drawer/navigation panel
│   ├── my_textfield.dart      # Custom text input field
│   └── user_tile.dart         # User list item widget
├── models/                    # Data models
│   └── message.dart           # Message data model
├── pages/                     # App screens/pages
│   ├── chat_page.dart         # Chat conversation screen
│   ├── home_page.dart         # Main home screen
│   ├── login_page.dart        # Login screen
│   ├── register_page.dart     # Registration screen
│   └── settings_page.dart     # App settings screen
├── services/                  # Business logic/services
│   ├── auth/                  # Authentication services
│   │   ├── auth_gate.dart     # Auth routing widget
│   │   ├── auth_service.dart  # Auth service implementation
│   │   └── login_or_register.dart # Auth flow switcher
│   └── chat/                  # Chat services
│       └── chat_service.dart  # Chat service implementation
├── themes/                    # App theming
│   ├── dark_mode.dart         # Dark theme configuration
│   ├── light_mode.dart        # Light theme configuration
│   └── theme_provider.dart    # Theme state management
└── firebase_options.dart      # Firebase configuration
```

## Technical Details

- **State Management**: Provider
- **Backend**: Firebase
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **Theme**: Dynamic theme switching

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

