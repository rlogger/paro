# Firebase Setup

Quick setup guide for Firebase Authentication and Firestore.

## Create Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create project: `eater-app`
3. Add iOS app with bundle ID: `com.eater.app`
4. Download `GoogleService-Info.plist` to project root
5. Add to `.gitignore`

## Install SDK

**Swift Package Manager:**
```
https://github.com/firebase/firebase-ios-sdk
```

Add packages: FirebaseAuth, FirebaseCore, FirebaseFirestore, FirebaseMessaging

## Initialize App

```swift
// eaterApp.swift
import FirebaseCore

@main
struct eaterApp: App {
    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Enable Auth Providers

**Firebase Console > Authentication > Sign-in method:**
- Email/Password
- Google (optional)
- Apple (optional, requires Sign in with Apple capability)
- Phone (optional, requires APNs setup)

## Setup Firestore

1. Create database in production mode
2. Location: `us-central1`

**Security Rules:**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    match /orders/{orderId} {
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      allow create: if request.auth != null;
      allow update: if request.auth != null && resource.data.userId == request.auth.uid;
    }
  }
}
```

**Indexes:**
- orders: userId (Asc), createdAt (Desc)
- orders: userId (Asc), status (Asc), createdAt (Desc)

## Push Notifications

1. Upload APNs key (.p8) to Firebase Console > Project Settings > Cloud Messaging
2. Add capabilities in Xcode:
   - Push Notifications
   - Background Modes > Remote notifications

## Backend Setup

```javascript
// Node.js
const admin = require('firebase-admin');
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: 'https://eater-app-xxxxx.firebaseio.com'
});

const db = admin.firestore();
const auth = admin.auth();
```

## Security Checklist

- [ ] GoogleService-Info.plist in .gitignore
- [ ] Service account key in .gitignore
- [ ] Firestore rules set to production mode
- [ ] Tokens stored in Keychain (not UserDefaults) in production
- [ ] APNs certificates configured

## Troubleshooting

**"FirebaseApp.configure() must be called"** - Call in app init() before any Firebase usage

**"GoogleService-Info.plist not found"** - Ensure file is in project and target's Copy Bundle Resources

**Push not working** - Test on real device (not simulator), verify APNs certificate uploaded
