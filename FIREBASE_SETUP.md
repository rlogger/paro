# Firebase Setup Guide for Eater App

This guide walks you through setting up Firebase Authentication and Firestore for the Eater app.

---

## Prerequisites

- Xcode 15.0 or later
- iOS 17.0 or later deployment target
- Apple Developer account (for Apple Sign-In)
- Google account (for Firebase Console access)

---

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Add project" or "Create a project"
3. Enter project name: `eater-app` (or your preferred name)
4. (Optional) Enable Google Analytics
5. Click "Create project"

---

## Step 2: Add iOS App to Firebase Project

1. In Firebase Console, click the iOS icon (⊕) to add an iOS app
2. Enter your iOS bundle ID: `com.eater.app` (or your actual bundle ID)
3. Enter app nickname: `Eater iOS`
4. (Optional) Enter App Store ID
5. Click "Register app"

---

## Step 3: Download GoogleService-Info.plist

1. Download the `GoogleService-Info.plist` file
2. Add it to your Xcode project:
   - Drag and drop into Xcode project navigator
   - Make sure "Copy items if needed" is checked
   - Add to target: eater
   - Place it in the project root alongside other Swift files

**IMPORTANT:** Never commit `GoogleService-Info.plist` to version control!

Add to `.gitignore`:
```
GoogleService-Info.plist
```

---

## Step 4: Install Firebase SDK

### Option A: Swift Package Manager (Recommended)

1. In Xcode, go to **File → Add Package Dependencies**
2. Enter URL: `https://github.com/firebase/firebase-ios-sdk`
3. Select version: Latest release
4. Add the following packages:
   - ✅ FirebaseAuth
   - ✅ FirebaseCore
   - ✅ FirebaseFirestore
   - ✅ FirebaseMessaging (for push notifications)
   - ✅ FirebaseAnalytics (optional)

### Option B: CocoaPods

Create a `Podfile`:
```ruby
platform :ios, '17.0'
use_frameworks!

target 'eater' do
  pod 'Firebase/Auth'
  pod 'Firebase/Firestore'
  pod 'Firebase/Messaging'
  pod 'Firebase/Analytics'
end
```

Then run:
```bash
pod install
```

---

## Step 5: Initialize Firebase in App

Update `eaterApp.swift`:

```swift
import SwiftUI
import SwiftData
import FirebaseCore  // Add this import

@main
struct eaterApp: App {
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
```

---

## Step 6: Enable Authentication Providers

### Email/Password Authentication

1. In Firebase Console, go to **Authentication**
2. Click **Get Started** (if first time)
3. Go to **Sign-in method** tab
4. Click **Email/Password**
5. Enable **Email/Password**
6. Click **Save**

### Google Sign-In (Optional)

1. In **Sign-in method** tab, click **Google**
2. Enable Google Sign-In
3. Enter support email
4. Click **Save**
5. Download `GoogleService-Info.plist` again (it will have updated OAuth client ID)

**Additional Setup for Google Sign-In:**

Add to your Xcode project:

1. Install GoogleSignIn SDK:
   ```
   https://github.com/google/GoogleSignIn-iOS
   ```

2. Add URL scheme to `Info.plist`:
   - Open your `GoogleService-Info.plist`
   - Copy the `REVERSED_CLIENT_ID` value
   - In Xcode, go to your target → Info → URL Types
   - Add new URL scheme with the `REVERSED_CLIENT_ID`

3. Update `AuthService.swift` to import GoogleSignIn:
   ```swift
   import GoogleSignIn
   ```

### Apple Sign-In (Optional)

1. In **Sign-in method** tab, click **Apple**
2. Enable Apple Sign-In
3. Click **Save**

**Additional Setup for Apple Sign-In:**

1. In Xcode, go to **Signing & Capabilities**
2. Click **+ Capability**
3. Add **Sign in with Apple**

### Phone Authentication (Optional)

1. In **Sign-in method** tab, click **Phone**
2. Enable Phone authentication
3. Click **Save**

**Note:** Phone auth requires:
- Apple Push Notification service (APNs) certificates
- reCAPTCHA verification

---

## Step 7: Set Up Firestore Database

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Select **Start in production mode** (we'll add security rules later)
4. Choose location: `us-central1` (or closest to your users)
5. Click **Enable**

### Set Up Firestore Security Rules

In Firestore → Rules tab, paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper function to check if user is authenticated
    function isSignedIn() {
      return request.auth != null;
    }

    // Helper function to check if user owns the resource
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    // Users collection
    match /users/{userId} {
      allow read, write: if isOwner(userId);
    }

    // Orders collection
    match /orders/{orderId} {
      allow read: if isSignedIn() &&
                     resource.data.userId == request.auth.uid;
      allow create: if isSignedIn();
      allow update: if isSignedIn() &&
                       resource.data.userId == request.auth.uid;
      allow delete: if isOwner(resource.data.userId);
    }

    // Delivery addresses
    match /deliveryAddresses/{userId}/{document=**} {
      allow read, write: if isOwner(userId);
    }

    // Delivery tracking
    match /deliveryTracking/{trackingId} {
      allow read: if isSignedIn();
      allow write: if false; // Only backend can write
    }
  }
}
```

Click **Publish**

### Create Firestore Indexes

In Firestore → Indexes tab, create composite indexes:

**Index 1: User Orders by Date**
- Collection: `orders`
- Fields:
  - `userId` (Ascending)
  - `createdAt` (Descending)

**Index 2: User Orders by Status**
- Collection: `orders`
- Fields:
  - `userId` (Ascending)
  - `status` (Ascending)
  - `createdAt` (Descending)

---

## Step 8: Set Up Cloud Messaging (Push Notifications)

1. In Firebase Console, go to **Project Settings** → **Cloud Messaging**
2. Under **Apple app configuration**, upload:
   - APNs Authentication Key (.p8 file)
   - Key ID
   - Team ID

**To create APNs key:**
1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Go to **Certificates, Identifiers & Profiles**
3. Click **Keys** → **+** (Create new key)
4. Enable **Apple Push Notifications service (APNs)**
5. Download the .p8 file (save it securely!)
6. Note the Key ID

3. Add Push Notification capability in Xcode:
   - Go to **Signing & Capabilities**
   - Click **+ Capability**
   - Add **Push Notifications**
   - Add **Background Modes**
   - Check **Remote notifications**

---

## Step 9: Update AuthService.swift

Uncomment the Firebase code in `AuthService.swift`:

1. Uncomment all `import FirebaseAuth` statements
2. Uncomment all Firebase-specific implementation code
3. Remove or comment out placeholder implementations

---

## Step 10: Test Authentication

Build and run the app:

```bash
# Build the project
xcodebuild -scheme eater -destination 'platform=iOS Simulator,name=iPhone 15' build
```

Test sign-in flow:
1. Launch app
2. Navigate to sign-in screen
3. Create account with email/password
4. Verify user appears in Firebase Console → Authentication → Users

---

## Step 11: Set Up Backend Server

See `server-config.txt` for complete backend setup instructions.

### Quick Backend Setup (Node.js)

1. Install Firebase Admin SDK:
   ```bash
   npm install firebase-admin
   ```

2. Download service account key:
   - Firebase Console → Project Settings → Service Accounts
   - Click "Generate new private key"
   - Save as `serviceAccountKey.json`
   - **Never commit this file!**

3. Initialize Firebase Admin:
   ```javascript
   const admin = require('firebase-admin');
   const serviceAccount = require('./serviceAccountKey.json');

   admin.initializeApp({
     credential: admin.credential.cert(serviceAccount),
     databaseURL: 'https://eater-app-xxxxx.firebaseio.com'
   });

   const db = admin.firestore();
   const auth = admin.auth();
   ```

4. Verify ID tokens in API endpoints:
   ```javascript
   async function verifyToken(req, res, next) {
     const token = req.headers.authorization?.replace('Bearer ', '');

     if (!token) {
       return res.status(401).json({ error: 'No token provided' });
     }

     try {
       const decodedToken = await admin.auth().verifyIdToken(token);
       req.user = decodedToken;
       next();
     } catch (error) {
       return res.status(401).json({ error: 'Invalid token' });
     }
   }

   // Use in routes
   app.post('/api/orders', verifyToken, async (req, res) => {
     const userId = req.user.uid;
     // Create order...
   });
   ```

---

## Troubleshooting

### Issue: "FirebaseApp.configure() must be called before using Firebase"

**Solution:** Make sure you call `FirebaseApp.configure()` in your app's `init()` method before any Firebase usage.

### Issue: "GoogleService-Info.plist not found"

**Solution:**
- Ensure the file is added to your Xcode project
- Check that it's included in your target's Copy Bundle Resources
- Clean build folder (Cmd + Shift + K) and rebuild

### Issue: "No client ID found in GoogleService-Info.plist"

**Solution:** Download a fresh `GoogleService-Info.plist` from Firebase Console after enabling Google Sign-In.

### Issue: Push notifications not working

**Solution:**
- Verify APNs certificate is uploaded to Firebase
- Check that Push Notifications capability is enabled in Xcode
- Test with a real device (not simulator)
- Check Firebase Console → Cloud Messaging for errors

### Issue: Firestore permission denied

**Solution:**
- Check Firestore security rules
- Verify user is authenticated
- Ensure `request.auth.uid` matches document `userId`

---

## Security Checklist

- [ ] `GoogleService-Info.plist` is in `.gitignore`
- [ ] Backend service account key is in `.gitignore`
- [ ] Firestore security rules are set to production mode
- [ ] API keys are stored in environment variables, not hardcoded
- [ ] APNs certificates are properly configured
- [ ] Firebase tokens are stored in Keychain (not UserDefaults) in production

---

## Next Steps

1. Implement sign-in UI in WelcomeView
2. Add authentication check before order placement
3. Store user data in Firestore
4. Set up push notifications for order updates
5. Test complete order flow with authentication

---

## Useful Links

- [Firebase iOS Documentation](https://firebase.google.com/docs/ios/setup)
- [Firebase Authentication Docs](https://firebase.google.com/docs/auth/ios/start)
- [Firestore Documentation](https://firebase.google.com/docs/firestore/quickstart)
- [Cloud Messaging Docs](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [Firebase Console](https://console.firebase.google.com)

---

**Last Updated:** November 11, 2025
