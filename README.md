## design: removes pâro when ordering food delivery
**pâro** n. the feeling that everything you do is always somehow wrong

<br>

**Status:** Inactive Development - See known limitations

POC: Simple 2-page mobile app with preset food ordering options based on cuisine selection. Backend API integration with Uber Eats for real-time delivery quotes and order placement.

## ⚠️ Known Limitations

**Third-Party API Access**: Delivery platform APIs (Uber Eats, DoorDash) are not publicly available to individual developers. Access requires enterprise partnerships or formal commercial agreements, making this project non-deployable for personal use without alternative solutions.

## Screenshots

<div align="center">
  <img src="img/screenshot_1.png" width="45%" alt="Welcome Screen" />
  <img src="img/screenshot_2.png" width="45%" alt="Cuisine Selection" />
</div>

<p align="center">
  <em>Left: Welcome screen with signature "Eater" branding | Right: Cuisine selection interface</em>
</p>

## Quick Start

### Prerequisites
- Xcode 15.0+
- iOS 17.0+
- Firebase account
- Uber Eats API credentials

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/rlogger/eaterr.git
   cd eaterr
   ```

2. **Set up Firebase**
   - Follow the detailed guide in [`docs/FIREBASE_SETUP.md`](docs/FIREBASE_SETUP.md)
   - Download `GoogleService-Info.plist` from Firebase Console
   - Add it to the Xcode project

3. **Configure server**
   - See [`docs/server-config.txt`](docs/server-config.txt) for complete backend setup
   - Set up Uber Eats API credentials
   - Deploy backend server

4. **Build and run**
   ```bash
   open eater.xcodeproj  # Or eater.xcworkspace if using CocoaPods
   # Build and run in Xcode
   ```

## Project Structure

```
eaterr/
├── WelcomeView.swift           # Landing screen with app branding
├── CuisineSelectionView.swift  # Cuisine selection and order placement
├── ConfirmationView.swift      # Order confirmation display
├── OrderService.swift          # API client for backend communication
├── AuthService.swift           # Firebase authentication service
├── Item.swift                  # Data models (Order, User, etc.)
├── eaterApp.swift              # App entry point
├── ContentView.swift           # Root view controller
├── Assets.xcassets/            # Image and color assets
└── docs/
    ├── SYSTEM_DESIGN.md        # System architecture documentation
    ├── FIREBASE_SETUP.md       # Firebase setup guide
    └── server-config.txt       # Server-side configuration reference
```

## Delivery Platform Integrations

- **Uber Eats** (Primary - Active Integration)
- Weedmaps (Considering)
- Direct restaurant integrations (Considering)

## Technology Stack

- **Frontend:** Swift, SwiftUI, SwiftData
- **Backend:** Node.js, Express.js
- **Authentication:** Firebase Auth
- **Database:** Firestore
- **Cloud Services:** Google Cloud Platform
- **Delivery APIs:** Uber Eats API

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
