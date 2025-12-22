# All-in-One Fitness App - Flutter Frontend

A comprehensive Flutter mobile application that integrates with the Flask backend at `kingsdiri007/all_in_one_fitness_app`. This app provides a complete fitness solution with workout tracking, meal planning, and gym recommendations.

## Features

- **User Authentication**: Secure login and registration with JWT tokens
- **Multi-Step Registration**: Intuitive 4-step onboarding process
  - Goal selection (Lose Weight, Gain Muscle, Maintain Figure, Gain Weight)
  - Personal information (weight, height, fitness metrics)
  - Healthy habits selection (8 customizable habits)
  - Account creation with email and password
- **Personalized Experience**: Tailored recommendations based on user goals
- **Gym Finder**: Discover nearby gyms with ratings and amenities
- **Modern UI**: Clean, responsive design with smooth animations
- **Secure Storage**: JWT token storage with flutter_secure_storage
- **State Management**: Provider pattern for efficient state management

## Screenshots Description

- **Splash Screen**: Gradient background with animated welcome message and journey start button
- **Registration Flow**: 4-step guided registration with progress indicator
  - Step 1: Visual goal selection cards
  - Step 2: Comprehensive personal information form
  - Step 3: Interactive healthy habits checklist
  - Step 4: Secure account creation
- **Login Screen**: Simple email/password authentication with password visibility toggle
- **Home Screen**: Personalized dashboard with gym recommendations and user welcome message

## Prerequisites

- **Flutter SDK**: 3.0 or higher
- **Dart SDK**: 2.17 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **Backend Server**: Running instance of `kingsdiri007/all_in_one_fitness_app`

## Backend Setup

### Required Backend Modifications

The backend at `kingsdiri007/all_in_one_fitness_app` needs the following modifications:

#### 1. User Model Fields (`backend/app/models.py`)

Add these fields to the User model:

```python
goal_weight = db.Column(db.Float)
estimated_daily_steps = db.Column(db.Integer)
free_time_per_week = db.Column(db.Float)
workout_difficulty = db.Column(db.String(20))
location = db.Column(db.String(100))
healthy_habits = db.Column(db.JSON)
weight_unit = db.Column(db.String(10), default='kg')
height_unit = db.Column(db.String(10), default='cm')
```

#### 2. New API Endpoints Required

**Forgot Password Endpoint:**
```python
# POST /api/auth/forgot-password
# Request: { "email": "user@example.com" }
# Response: { "message": "Password reset email sent" }
```

**Nearby Gyms Endpoint:**
```python
# GET /api/gyms/nearby?location={location}
# Response: [
#   {
#     "id": 1,
#     "name": "Fitness Center",
#     "address": "123 Main St",
#     "distance": "0.5 km",
#     "phone": "+1234567890",
#     "rating": 4.5,
#     "amenities": ["WiFi", "Parking", "Showers", "Personal Training"]
#   }
# ]
```

## Installation

### 1. Clone the Repository

```bash
git clone https://github.com/kingsdiri007/login_register_flutter_fitness_app.git
cd login_register_flutter_fitness_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure API URL

Edit `lib/services/api_config.dart` to set your backend URL:

```dart
// For Android Emulator (default)
static const String baseUrl = 'http://10.0.2.2:5000';

// For iOS Simulator
// static const String baseUrl = 'http://localhost:5000';

// For Physical Device (use your computer's IP)
// static const String baseUrl = 'http://192.168.1.XXX:5000';

// For Production
// static const String baseUrl = 'https://your-api-domain.com';
```

### 4. Run the App

```bash
# Start backend server first
cd ../all_in_one_fitness_app
python run.py

# Then run Flutter app
cd ../login_register_flutter_fitness_app
flutter run
```

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/                            # Data models
│   ├── user_model.dart               # User data structure
│   ├── registration_data.dart        # Registration form data
│   └── gym_model.dart                # Gym information model
├── screens/                           # UI screens
│   ├── splash_screen.dart            # Welcome/splash screen
│   ├── login_screen.dart             # User login
│   ├── registration_screen.dart      # Multi-step registration
│   └── home_screen.dart              # Main dashboard
├── widgets/                           # Reusable UI components
│   ├── custom_button.dart            # Custom button widget
│   ├── custom_text_field.dart        # Custom input field
│   ├── goal_card.dart                # Goal selection card
│   ├── habit_checkbox.dart           # Habit checkbox
│   └── progress_bar.dart             # Animated progress bar
├── services/                          # Business logic layer
│   ├── api_config.dart               # API configuration
│   ├── api_service.dart              # HTTP service
│   ├── auth_service.dart             # Authentication logic
│   └── storage_service.dart          # Local storage
├── providers/                         # State management
│   ├── auth_provider.dart            # Auth state management
│   └── registration_provider.dart    # Registration state
└── utils/                            # Utilities
    ├── app_theme.dart                # App theming
    ├── constants.dart                # App constants
    └── validators.dart               # Form validators
```

## API Endpoints Documentation

### Authentication

- **POST** `/api/auth/register` - Register new user
  - Request: Registration data (see RegistrationData model)
  - Response: `{ "message": "User created successfully" }`

- **POST** `/api/auth/login` - User login
  - Request: `{ "email": "user@example.com", "password": "password123" }`
  - Response: `{ "access_token": "jwt_token", "user": {...} }`

- **GET** `/api/auth/me` - Get current user (requires auth token)
  - Response: User object

- **POST** `/api/auth/forgot-password` - Request password reset
  - Request: `{ "email": "user@example.com" }`
  - Response: `{ "message": "Password reset email sent" }`

### Gyms

- **GET** `/api/gyms/nearby?location={location}` - Get nearby gyms
  - Response: Array of gym objects

## Configuration

### Environment-Specific API URLs

#### Development (Android Emulator)
```dart
static const String baseUrl = 'http://10.0.2.2:5000';
```

#### Development (iOS Simulator)
```dart
static const String baseUrl = 'http://localhost:5000';
```

#### Development (Physical Device)
```dart
static const String baseUrl = 'http://YOUR_COMPUTER_IP:5000';
```
Note: Find your IP with `ipconfig` (Windows) or `ifconfig` (Mac/Linux)

#### Production
```dart
static const String baseUrl = 'https://api.yourfitnessdomain.com';
```

### Backend Configuration

Ensure your backend Flask app is configured with:
- CORS enabled for your Flutter app domain
- JWT secret key configured
- Database properly set up with required tables
- All required endpoints implemented

## Building for Production

### Android

```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Google Play Store)
flutter build appbundle --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
# Build iOS app
flutter build ios --release
```

Note: Requires macOS and Xcode. Follow [Flutter iOS deployment guide](https://docs.flutter.dev/deployment/ios).

## Development

### Running in Debug Mode

```bash
flutter run
```

### Hot Reload
Press `r` in the terminal while the app is running to hot reload changes.

### Hot Restart
Press `R` in the terminal for a full restart.

## Troubleshooting

### Issue: Cannot connect to backend

**Solution:**
- Check that backend server is running on port 5000
- Verify API URL in `api_config.dart` matches your setup
- For Android emulator, use `10.0.2.2` instead of `localhost`
- For physical device, use your computer's local network IP
- Ensure firewall allows connections on port 5000

### Issue: Secure storage errors on Android

**Solution:**
- Minimum Android SDK should be 18 or higher
- Add required permissions in `android/app/src/main/AndroidManifest.xml`
- Rebuild the app: `flutter clean && flutter pub get && flutter run`

### Issue: Build fails with dependency conflicts

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: "Waiting for another flutter command to release the startup lock"

**Solution:**
```bash
# Delete the lock file
rm -rf $HOME/.flutter_tool_state/flutter.lock
```

### Issue: iOS build fails

**Solution:**
- Ensure Xcode is installed and up to date
- Run `pod install` in the `ios/` directory
- Update CocoaPods: `sudo gem install cocoapods`

### Issue: Hot reload not working

**Solution:**
- Stop the app and restart with `flutter run`
- Check for syntax errors in your code
- Try hot restart (press `R`) instead of hot reload

### Issue: Registration fails with validation errors

**Solution:**
- Ensure all required fields are filled
- Check password meets minimum 8 character requirement
- Verify email format is valid
- Ensure at least one healthy habit is selected

## Testing

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/widget_test.dart
```

### Code Coverage
```bash
flutter test --coverage
```

## Code Quality

### Analyze Code
```bash
flutter analyze
```

### Format Code
```bash
flutter format lib/
```

## Technologies Used

- **Flutter**: UI framework
- **Provider**: State management
- **HTTP**: API communication
- **Flutter Secure Storage**: Secure token storage
- **Shared Preferences**: Local data persistence
- **Google Fonts**: Custom typography

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Commit changes: `git commit -am 'Add feature'`
4. Push to branch: `git push origin feature-name`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and questions:
- Open an issue on GitHub
- Contact: [Your contact information]

## Roadmap

Future features planned:
- [ ] Workout tracking and logging
- [ ] Meal planning and nutrition tracking
- [ ] Progress photos and measurements
- [ ] Social features and community
- [ ] Integration with fitness wearables
- [ ] Push notifications for workout reminders
- [ ] Offline mode support
- [ ] Dark mode theme
- [ ] Multiple language support
- [ ] Apple Health and Google Fit integration

## Acknowledgments

- Flutter team for the amazing framework
- Backend API by kingsdiri007/all_in_one_fitness_app
- Material Design guidelines
- Flutter community for packages and support
