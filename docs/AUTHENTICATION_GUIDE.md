# Authentication Guide

Auth is implemented in `AuthService.swift` (singleton pattern) with Firebase + Twilio.

## Methods

- Email/Password: `signIn()`, `signUp()`
- Phone/SMS: `sendPhoneVerification()`, `verifyPhoneCode()`
- Social: Google, Apple (ready for Firebase integration)
- Session: `signOut()`, `getCurrentUser()`, `getIDToken()`, `isAuthenticated()`

## Integration Points

**App Launch** (`eaterApp.swift`)
- Check `AuthService.shared.isAuthenticated()`
- Show AuthenticationView if needed

**Before Order** (`CuisineSelectionView.swift:228`)
```swift
guard AuthService.shared.isAuthenticated() else {
    showAuthenticationRequired = true
    return
}
```

**Auto Token Injection** (`OrderService.swift:195`)
- Automatically adds Firebase token to API request headers

**Notifications** (`NotificationService.swift:494`)
- Uses authenticated user's phone number

## Token Storage

**Development:** UserDefaults (current)
**Production:** Keychain (recommended)

```swift
// Production: Store in Keychain
let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccount as String: "firebaseToken",
    kSecValueData as String: tokenData
]
SecItemAdd(query as CFDictionary, nil)
```

## Backend Validation

```javascript
// Middleware verifies Firebase ID token
const decodedToken = await admin.auth().verifyIdToken(token);
const userId = decodedToken.uid;
```

## Status

| Component | Status |
|-----------|--------|
| AuthService | Ready |
| OrderService integration | Ready |
| NotificationService integration | Ready |
| App-level auth check | TODO |
| Order-level auth guard | TODO |
| AuthenticationView UI | TODO |
