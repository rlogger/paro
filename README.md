# Paro

> Food delivery without the pâro

A minimalist iOS demo app for ordering food delivery. Works completely offline with realistic mock data.

## Features

- Clean SwiftUI interface
- Offline-first architecture
- Instant order placement
- Secure Keychain storage

## Getting Started

### Requirements

- macOS with Xcode 15+
- iPhone running iOS 17+
- USB cable

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/rlogger/paro.git
   cd paro
   ```

2. **Open in Xcode**
   - File → New → Project → iOS App
   - Name: `paro`
   - Drag all .swift files into project
   - Add Assets.xcassets folder

3. **Connect iPhone**
   - Enable Developer Mode: Settings → Privacy & Security → Developer Mode
   - Connect via USB and trust computer

4. **Build and Run**
   - In Xcode: Cmd + R

### First Run

On first launch:
1. Settings → General → VPN & Device Management
2. Trust your Apple ID developer certificate
3. Relaunch app

## Demo Mode

The app runs in demo mode with no backend required.

### Authentication
- Any email/password works
- Try: `demo@paro.app` / `demo`

### Order Flow
1. Tap carrot icon
2. Sign in with any credentials
3. Select cuisines
4. Place order
5. View confirmation

## Architecture

```
paro/
├── ParoApp.swift           # App entry point
├── ContentView.swift       # Root view
├── WelcomeView.swift       # Landing screen
├── AuthenticationView.swift # Sign in/up
├── CuisineSelectionView.swift # Order screen
├── ConfirmationView.swift  # Confirmation
├── AuthService.swift       # Authentication
├── OrderService.swift      # Order handling
├── KeychainHelper.swift    # Secure storage
├── DemoConfig.swift        # Demo settings
└── Item.swift              # Data models
```

## Technology

- **SwiftUI** - Declarative UI framework
- **SwiftData** - Data persistence
- **Keychain** - Secure token storage
- **Combine** - Reactive programming

## Development

### Build
```bash
swift build
```

### Test
```bash
swift test
```

### Format
```bash
swiftformat .
```

### Lint
```bash
swiftlint
```

## Production Deployment

To deploy with real backend:

1. **Setup Firebase**
   - Add GoogleService-Info.plist
   - Uncomment Firebase code in AuthService

2. **Configure Backend**
   - Deploy API server
   - Add Postmates/Twilio credentials

3. **Update Services**
   - Remove demo mode flags
   - Enable real API calls

4. **App Store**
   - Add app icon
   - Archive and upload

## License

MIT License - See LICENSE file

## Contributing

See CONTRIBUTING.md for development guidelines.
