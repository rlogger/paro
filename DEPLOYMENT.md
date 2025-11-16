# Eater App - Deployment Guide

This guide explains how to build, test, and deploy the Eater food delivery app.

## Prerequisites

- **Xcode 15.0+** installed
- **iOS 17.0+** target device or simulator
- **Apple Developer Account** (for App Store deployment)
- **CocoaPods or Swift Package Manager** for dependencies

## Project Structure

```
eater/
├── eaterApp.swift              # App entry point
├── ContentView.swift            # Root view
├── Views/
│   ├── WelcomeView.swift       # Landing screen
│   ├── AuthenticationView.swift # Sign in/up
│   ├── CuisineSelectionView.swift # Order screen
│   └── ConfirmationView.swift  # Confirmation screen
├── Services/
│   ├── AuthService.swift       # Authentication
│   ├── OrderService.swift      # Order management
│   ├── NotificationService.swift # SMS notifications
│   └── KeychainHelper.swift    # Secure storage
├── Models/
│   └── Item.swift              # Data models
├── Tests/
│   └── eaterTests/             # Unit tests
├── Package.swift               # Swift Package Manager
└── Info.plist                  # App configuration
```

## Building the App

### Option 1: Using Xcode

1. **Create Xcode Project:**
   ```bash
   # In Xcode: File → New → Project
   # Choose: iOS → App
   # Name: eater
   # Interface: SwiftUI
   # Language: Swift
   ```

2. **Add Source Files:**
   - Add all `.swift` files to the project
   - Add `Assets.xcassets` for images
   - Add `Info.plist` to project

3. **Configure Project Settings:**
   - Bundle Identifier: `com.eater.app`
   - Team: Your Apple Developer Team
   - Deployment Target: iOS 17.0
   - Supported Devices: iPhone, iPad

4. **Build:**
   ```
   Cmd + B (or Product → Build)
   ```

### Option 2: Using Swift Package Manager

1. **Build from command line:**
   ```bash
   swift build
   ```

2. **Run tests:**
   ```bash
   swift test
   ```

## Running Tests

### Run all tests:
```bash
# In Xcode
Cmd + U (or Product → Test)

# Or via command line
swift test
```

### Test Coverage:
- ✅ WelcomeView - Authentication flow
- ✅ AuthenticationView - Sign in/up validation
- ✅ CuisineSelectionView - Order placement
- ✅ ConfirmationView - Order display
- ✅ AuthService - User authentication
- ✅ OrderService - Order processing
- ✅ KeychainHelper - Secure storage

### Expected Results:
All tests should pass ✅. If any fail, review the error messages.

## Firebase Setup (Required for Production)

1. **Create Firebase Project:**
   - Go to https://console.firebase.google.com
   - Create new project
   - Add iOS app with bundle ID `com.eater.app`

2. **Download Configuration:**
   - Download `GoogleService-Info.plist`
   - Add to Xcode project root

3. **Install Firebase SDK:**
   ```ruby
   # Using CocoaPods
   pod 'Firebase/Auth'
   pod 'Firebase/Firestore'

   # Or Swift Package Manager
   # Add: https://github.com/firebase/firebase-ios-sdk
   ```

4. **Update Code:**
   - Uncomment Firebase imports in `AuthService.swift`
   - Uncomment Firebase implementation code
   - Add `FirebaseApp.configure()` in `eaterApp.swift`

## Backend Server Setup (Required for Production)

The app requires a backend server for:
- Order processing (Postmates API integration)
- SMS notifications (Twilio integration)
- Phone authentication

See `docs/server-config.txt` for complete backend setup.

## App Store Deployment

### 1. Prepare App

- [ ] Update version number in `Info.plist`
- [ ] Add app icons to `Assets.xcassets`
- [ ] Add launch screen assets
- [ ] Test on real devices
- [ ] Review App Store guidelines

### 2. Archive Build

```
# In Xcode
Product → Archive
```

### 3. Upload to App Store Connect

1. Open Organizer (Window → Organizer)
2. Select your archive
3. Click "Distribute App"
4. Choose "App Store Connect"
5. Follow the wizard

### 4. Configure App Store Listing

- App name: "Eater"
- Subtitle: "Order food without the pâro"
- Keywords: "food delivery, restaurant, order"
- Description: Use README content
- Screenshots: Add from `img/` directory
- Privacy policy URL (required)

### 5. Submit for Review

- Complete all required fields
- Submit for review
- Monitor status in App Store Connect

## TestFlight Distribution (Beta Testing)

1. **Create Build:**
   ```
   Product → Archive
   ```

2. **Upload to TestFlight:**
   - Open Organizer
   - Select archive
   - Click "Distribute App"
   - Choose "App Store Connect"
   - Select "Upload"

3. **Add Testers:**
   - Go to TestFlight in App Store Connect
   - Add internal/external testers
   - Send invitations

## Environment Configuration

### Development
- Uses mock data in `OrderService`
- Uses placeholder Firebase auth
- No real API calls

### Staging
- Point to staging backend server
- Use test Postmates/Twilio accounts
- Enable debug logging

### Production
- Point to production backend
- Use production API credentials
- Disable debug logging
- Enable analytics

## Security Checklist

- [ ] API keys stored on backend (not in app)
- [ ] HTTPS for all network calls
- [ ] Keychain for token storage (not UserDefaults)
- [ ] Input validation on all forms
- [ ] No sensitive data in logs
- [ ] App Transport Security configured
- [ ] Code obfuscation for production

## Performance Optimization

- [ ] Lazy loading for images
- [ ] Caching for API responses
- [ ] Minimize network requests
- [ ] Optimize SwiftUI view updates
- [ ] Profile with Instruments

## Monitoring & Analytics

Consider adding:
- Firebase Analytics
- Crashlytics for crash reporting
- Performance monitoring
- Custom events for user actions

## Troubleshooting

### Build Errors
- Clean build folder: `Cmd + Shift + K`
- Delete derived data
- Verify Xcode version
- Check Swift version compatibility

### Test Failures
- Review test logs
- Check authentication state
- Verify mock data
- Clean test environment

### Runtime Issues
- Check console logs
- Verify network connectivity
- Review API endpoints
- Check Firebase configuration

## Support

For issues:
1. Check documentation in `docs/`
2. Review error logs
3. Open GitHub issue: https://github.com/rlogger/eaterr/issues

## License

MIT License - See LICENSE file
