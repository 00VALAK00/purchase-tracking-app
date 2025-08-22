# Purchase Tracker Mobile App

A Flutter mobile application for tracking purchases and receipts using OCR technology. Users can upload receipt photos, which are automatically processed to extract purchase details.

## Features

### 🔐 Authentication
- **User Registration**: Create new accounts with username, email, and password
- **User Login**: Secure authentication with JWT tokens
- **Session Management**: Automatic token storage and restoration

### 📱 Purchase Management
- **Purchase History**: View all your past transactions
- **Transaction Details**: See individual items, amounts, and dates
- **Statistics**: Track total spending and monthly totals
- **Smart Date Display**: Shows "Today", "Yesterday", or actual dates

### 📸 Receipt Processing
- **Camera Integration**: Take photos directly in the app
- **Gallery Selection**: Choose existing photos from device
- **OCR Processing**: Automatic text extraction from receipt images
- **Fidelity Card Support**: Optional loyalty card number input

### 🎨 User Interface
- **Modern Design**: Clean, Material Design 3 interface
- **Responsive Layout**: Works on all screen sizes
- **Dark/Light Theme**: Consistent with system preferences
- **Smooth Animations**: Professional user experience

## Screenshots

The app includes several key screens:
- **Login Screen**: User authentication
- **Register Screen**: Account creation
- **Home Screen**: Dashboard with purchase history and statistics
- **Add Receipt Screen**: Photo capture and OCR processing

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio / VS Code
- Android SDK (for Android development)
- iOS SDK (for iOS development, macOS only)

### Installation

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd purchase_tracking_app/frontend
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure backend URL**
   - Open `lib/utils/constants.dart`
   - Update the `baseUrl` constant to match your Django backend:
     ```dart
     // For Android emulator
     static const String baseUrl = 'http://10.0.2.2:8000';
     
     // For iOS simulator
     static const String baseUrl = 'http://localhost:8000';
     
     // For physical device
     static const String baseUrl = 'http://your-ip:8000';
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Backend Configuration

Ensure your Django backend has:
- JWT authentication enabled
- CORS configured for mobile app
- Receipt processing endpoint (`/api/receipts/process/`)
- Transaction endpoints (`/api/transactions/`)
- User profile endpoints (`/api/users/profile/`)

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart            # User and UserProfile models
│   └── transaction.dart     # Transaction and Item models
├── providers/               # State management
│   ├── auth_provider.dart   # Authentication state
│   └── transaction_provider.dart # Transaction state
├── screens/                 # UI screens
│   ├── login_screen.dart    # Login interface
│   ├── register_screen.dart # Registration interface
│   ├── home_screen.dart     # Main dashboard
│   └── add_receipt_screen.dart # Receipt upload
├── services/                # API services
│   └── api_service.dart     # HTTP requests to backend
├── utils/                   # Utilities
│   └── constants.dart       # App constants and configuration
└── widgets/                 # Reusable UI components
    └── transaction_card.dart # Transaction display widget
```

## Dependencies

### Core Dependencies
- **flutter**: Core Flutter framework
- **provider**: State management
- **http**: HTTP requests to backend
- **image_picker**: Camera and gallery access
- **shared_preferences**: Local data storage
- **flutter_secure_storage**: Secure token storage

### Development Dependencies
- **flutter_test**: Testing framework
- **flutter_lints**: Code quality rules

## API Integration

The app communicates with your Django backend through RESTful APIs:

- **Authentication**: JWT-based login/register
- **Transactions**: CRUD operations for purchase data
- **Receipt Processing**: Image upload and OCR processing
- **User Profile**: User information and preferences

## Permissions

The app requires the following permissions:

### Android
- `CAMERA`: Take receipt photos
- `READ_EXTERNAL_STORAGE`: Access gallery images
- `WRITE_EXTERNAL_STORAGE`: Save processed images

### iOS
- `NSCameraUsageDescription`: Camera access for receipts
- `NSPhotoLibraryUsageDescription`: Gallery access

## Testing

Run tests with:
```bash
flutter test
```

## Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## Troubleshooting

### Common Issues

1. **Backend Connection Failed**
   - Check if Django server is running
   - Verify the `baseUrl` in constants.dart
   - Ensure CORS is properly configured

2. **Image Picker Not Working**
   - Check camera permissions
   - Verify image_picker dependency is installed
   - Test on physical device (emulator may have limitations)

3. **Authentication Issues**
   - Verify JWT tokens are being sent correctly
   - Check backend authentication endpoints
   - Ensure token storage is working

### Debug Mode

Enable debug logging:
```dart
// In main.dart
debugShowCheckedModeBanner: true,
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

---

**Note**: This app is designed to work with the Django backend that includes OCR processing capabilities. Ensure your backend is properly configured before testing the mobile app.
