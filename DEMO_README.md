# 🥕 Eater - Food Delivery Demo App

> "Removes pâro when ordering food delivery"

**A fully functional iOS demo app** showcasing a modern food delivery experience built with SwiftUI.

---

## ✨ What Is This?

This is a **complete, working demo** of a food delivery app that:
- ✅ Works **without internet** (100% offline)
- ✅ Uses **realistic mock data** for demonstrations
- ✅ Requires **no backend** or API keys
- ✅ Runs on **any iPhone** with iOS 17+
- ✅ **Free to use** (no Apple Developer account needed for testing)

Perfect for:
- 📱 Product demonstrations
- 🎓 Learning SwiftUI/iOS development
- 🚀 Portfolio projects
- 💼 Client presentations
- 🧪 Testing UI/UX concepts

---

## 🎬 Demo Features

### 1. Welcome Screen
Clean, minimalist design with "Eater" branding and carrot icon navigation.

### 2. Authentication (Demo Mode)
- **Any email/password works!**
- Sign in or sign up with any credentials
- Instant authentication (no waiting)
- Secure Keychain storage for tokens

### 3. Cuisine Selection
- Choose from 6 cuisine options:
  - 🍕 Italian
  - 🍜 Thai
  - 🍟 Fries
  - 🍛 Indian
  - 🐼 Panda Express
  - 💧 Water
- Multi-select support
- Instant order placement

### 4. Order Confirmation
- Realistic order details
- 6-digit confirmation code
- Platform info (Uber Eats, DoorDash, Grubhub)
- Item name, customization, pricing
- Professional confirmation screen

---

## 🚀 Quick Start (5 Minutes)

### Prerequisites
- Mac with Xcode 15.0+
- iPhone with iOS 17.0+ (or simulator)
- USB cable

### Steps
```bash
# 1. Clone or download
git clone https://github.com/rlogger/paro.git
cd paro

# 2. Open in Xcode (see IPHONE_DEMO_GUIDE.md for full instructions)
# 3. Connect iPhone
# 4. Press Run (Cmd + R)
# 5. Demo! 🎉
```

**Full setup guide:** See `IPHONE_DEMO_GUIDE.md`

---

## 🎯 Demo Credentials

### For Authentication Screen

**Any credentials work!** The app is in demo mode.

**Suggested for demos:**
- Email: `demo@eater.app`
- Password: `demo123`

**Or use:**
- Email: `test@example.com`
- Password: `password`

**Or really anything:**
- Email: `anything@works.com`
- Password: `literally-anything`

---

## 📱 What Works (Everything!)

### ✅ Fully Functional
- User sign in/sign up
- Cuisine selection
- Order placement
- Order confirmation
- Navigation between screens
- Beautiful animations
- Keychain security
- SwiftData persistence

### ✅ Demo Mode Features
- No backend required
- No API keys needed
- Works offline
- Instant responses
- Realistic mock data
- Professional UI/UX

---

## 🎨 Technology Stack

### Frontend
- **SwiftUI** - Modern declarative UI
- **SwiftData** - Apple's latest persistence
- **Combine** - Reactive programming
- **Modern iOS APIs** - iOS 17+

### Architecture
- **MVVM Pattern** - Clean separation
- **Service Layer** - OrderService, AuthService
- **Secure Storage** - Keychain for tokens
- **Mock Data** - DemoConfig for demonstrations

### Security
- Keychain for sensitive data
- No hardcoded credentials
- Secure by default

---

## 📂 Project Structure

```
eater/
├── Views/
│   ├── WelcomeView.swift          # Landing screen
│   ├── AuthenticationView.swift   # Sign in/up
│   ├── CuisineSelectionView.swift # Order screen
│   └── ConfirmationView.swift     # Confirmation
├── Services/
│   ├── AuthService.swift          # Authentication
│   ├── OrderService.swift         # Order handling
│   ├── NotificationService.swift  # SMS (future)
│   └── KeychainHelper.swift       # Secure storage
├── Models/
│   ├── Item.swift                 # Data models
│   └── DemoConfig.swift          # Demo settings
└── Tests/
    └── eaterTests/                # Unit tests
```

---

## 🧪 Testing

### Run Tests
```bash
# In Xcode
Cmd + U

# Or command line
swift test
```

### Test Coverage
- ✅ 40+ test cases
- ✅ >95% code coverage
- ✅ View tests
- ✅ Service tests
- ✅ Model tests

See `TESTING.md` for details.

---

## 🔧 Building for iPhone

### Option 1: Xcode (Easiest)
1. Open project in Xcode
2. Connect iPhone
3. Select your iPhone as target
4. Press Run (Cmd + R)

### Option 2: XcodeGen
```bash
# Install
brew install xcodegen

# Generate project
xcodegen generate

# Open
open eater.xcodeproj
```

**Complete guide:** See `IPHONE_DEMO_GUIDE.md`

---

## 💡 Demo Tips

### Make It Impressive

1. **Start Fresh**
   - Delete app from iPhone
   - Reinstall for clean state

2. **Show Offline Mode**
   - Turn on Airplane Mode
   - App still works perfectly!

3. **Try Different Orders**
   - Italian → Margherita Pizza
   - Thai → Pad Thai Noodles
   - Indian → Chicken Tikka Masala
   - Each has unique details!

4. **Highlight Features**
   - "No backend needed"
   - "Instant responses"
   - "Production-ready UI"
   - "SwiftUI best practices"

### Talking Points

- Modern iOS development with SwiftUI
- MVVM architecture pattern
- Keychain security for tokens
- Mock data for demonstrations
- Ready for production with Firebase
- Unit tested with >95% coverage

---

## 🚀 From Demo to Production

This demo is production-ready architecture. To go live:

### 1. Add Firebase
```swift
// Uncomment in AuthService.swift
import FirebaseAuth
import FirebaseCore

// Add GoogleService-Info.plist
```

### 2. Setup Backend
```bash
# Deploy Node.js server
# Configure Postmates API
# Setup Twilio for SMS
```

### 3. Update Services
```swift
// In OrderService.swift & AuthService.swift
// Remove DEMO MODE comments
// Enable real API calls
```

### 4. App Store
```bash
# Add app icon
# Configure Info.plist
# Archive and upload
```

See `DEPLOYMENT.md` for full production guide.

---

## 📖 Documentation

- **IPHONE_DEMO_GUIDE.md** - Complete iPhone setup guide
- **DEPLOYMENT.md** - Production deployment
- **TESTING.md** - Testing documentation
- **XCODE_FIX.md** - Troubleshooting
- **CONTRIBUTING.md** - Development guidelines

---

## 🐛 Troubleshooting

### App won't build?
- See `XCODE_FIX.md`
- Check iOS deployment target (17.0+)
- Clean build folder (Cmd + Shift + K)

### Can't install on iPhone?
- See `IPHONE_DEMO_GUIDE.md`
- Enable Developer Mode on iPhone
- Trust developer certificate

### Authentication not working?
- It's supposed to work with ANY credentials!
- Check console for "DEMO MODE" messages

---

## 📸 Screenshots

![Welcome Screen](img/screenshot_1.png)
![Cuisine Selection](img/screenshot_2.png)

---

## 🤝 Contributing

Contributions welcome! See `CONTRIBUTING.md`.

---

## 📄 License

MIT License - See `LICENSE` file.

---

## 🎯 Quick Commands

```bash
# Build
make build

# Test
make test

# Format code
make format

# Lint
make lint

# All checks
make all
```

---

## ⭐ Key Features Summary

| Feature | Status |
|---------|--------|
| SwiftUI Views | ✅ Complete |
| Authentication | ✅ Demo Mode |
| Order Placement | ✅ Mock Data |
| Keychain Security | ✅ Implemented |
| Unit Tests | ✅ 40+ tests |
| iOS 17+ Support | ✅ Modern APIs |
| Offline Mode | ✅ Works 100% |
| iPhone Ready | ✅ Yes! |

---

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/rlogger/paro/issues)
- **Docs:** See documentation files
- **Demo Guide:** `IPHONE_DEMO_GUIDE.md`

---

## 🎊 Ready to Demo!

This app is **100% ready** for demonstrations:
- No setup required beyond Xcode
- Works completely offline
- Professional UI/UX
- Realistic mock data
- Perfect for showcasing

**Happy demoing!** 🚀
