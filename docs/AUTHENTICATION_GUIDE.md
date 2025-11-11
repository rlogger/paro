# Authentication Integration Guide

This guide explains where authentication is implemented in the Eater app and how to add an authentication screen UI.

---

## Overview

Authentication in Eater happens **behind the scenes** in the `AuthService` class. The app is designed so that authentication is transparent to the user during the initial experience, with auth UI to be added later at specific integration points.

---

## Current Authentication Architecture

### Where Authentication Lives

**File:** `AuthService.swift`
**Location:** Project root
**Pattern:** Singleton (`AuthService.shared`)

### Authentication Methods Available

1. **Email/Password** (Firebase)
   - `signIn(email:password:completion:)`
   - `signUp(email:password:displayName:completion:)`

2. **SMS/Phone** (Twilio + Firebase)
   - `sendPhoneVerification(phoneNumber:completion:)`
   - `verifyPhoneCode(code:completion:)`

3. **Social Login** (Prepared for Firebase)
   - Google Sign-In (implementation ready)
   - Apple Sign-In (implementation ready)

4. **Session Management**
   - `signOut(completion:)`
   - `getCurrentUser()`
   - `getIDToken(forceRefresh:completion:)`
   - `isAuthenticated()`

---

## Authentication Flow Points

### 1. App Launch (Automatic Silent Auth)

**Location:** `eaterApp.swift` or `ContentView.swift`

```swift
// eaterApp.swift
import SwiftUI
import FirebaseCore  // When Firebase SDK is added

@main
struct eaterApp: App {
    @StateObject private var authManager = AuthManager()

    init() {
        // Initialize Firebase (when SDK is added)
        // FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                ContentView()
            } else {
                // Show authentication screen
                AuthenticationView()
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
```

**Authentication Check:**
```swift
class AuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?

    init() {
        checkAuthStatus()
    }

    func checkAuthStatus() {
        // Check if user is already authenticated
        isAuthenticated = AuthService.shared.isAuthenticated()
        currentUser = AuthService.shared.getCurrentUser()
    }
}
```

---

### 2. Before Order Placement (Protected Action)

**Location:** `CuisineSelectionView.swift:228`

**Current Implementation:**
```swift
private func placeOrder() {
    let cuisineArray = Array(selectedCuisines)

    print("📱 Placing order for cuisines: \(cuisineArray)")

    OrderService.shared.placeOrder(cuisines: cuisineArray) { result in
        // Handle result...
    }
}
```

**With Authentication Check:**
```swift
private func placeOrder() {
    // ✅ ADD AUTHENTICATION CHECK HERE
    guard AuthService.shared.isAuthenticated() else {
        // User not authenticated - show auth screen
        showAuthenticationRequired = true
        return
    }

    let cuisineArray = Array(selectedCuisines)

    print("📱 Placing order for cuisines: \(cuisineArray)")

    OrderService.shared.placeOrder(cuisines: cuisineArray) { result in
        // Handle result...
    }
}
```

**Add State Variable:**
```swift
struct CuisineSelectionView: View {
    // ... existing state variables ...

    /// Shows authentication screen when user is not authenticated
    @State private var showAuthenticationRequired = false

    var body: some View {
        GeometryReader { geometry in
            // ... existing content ...
        }
        .sheet(isPresented: $showAuthenticationRequired) {
            AuthenticationView { success in
                if success {
                    // User authenticated, retry order
                    placeOrder()
                }
            }
        }
    }
}
```

---

### 3. Order Service (Automatic Token Injection)

**Location:** `OrderService.swift:195`

**Current Implementation:**
```swift
// Add Firebase authentication token if available
if let token = getAuthToken() {
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
}
```

**How It Works:**
- `OrderService` automatically retrieves the auth token from `AuthService`
- Token is added to every API request header
- Backend server validates the token
- **No manual intervention needed** - authentication happens automatically

---

### 4. Notification Service (User Phone Number)

**Location:** `NotificationService.swift:494`

**Current Implementation:**
```swift
guard let currentUser = AuthService.shared.getCurrentUser(),
      let phoneNumber = currentUser.phoneNumber else {
    print("⚠️ No phone number available for SMS notification")
    return
}
```

**How It Works:**
- `NotificationService` gets phone number from authenticated user
- If user signed in with phone auth, number is available
- SMS notifications are sent automatically after order
- **No manual intervention needed** - uses authenticated user's data

---

## Creating an Authentication Screen

### Step 1: Create AuthenticationView.swift

```swift
//
//  AuthenticationView.swift
//  eater
//
//  Authentication screen for user sign-in and sign-up
//

import SwiftUI

struct AuthenticationView: View {
    @Environment(\.dismiss) private var dismiss

    // Callback when authentication succeeds
    var onAuthenticated: ((Bool) -> Void)?

    // UI State
    @State private var authMethod: AuthMethod = .phone
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showCodeEntry = false

    enum AuthMethod {
        case phone
        case email
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // App branding
                Text("🥕")
                    .font(.system(size: 80))

                Text("Sign in to Eater")
                    .font(.system(size: 28, weight: .bold))

                // Auth method picker
                Picker("Auth Method", selection: $authMethod) {
                    Text("Phone").tag(AuthMethod.phone)
                    Text("Email").tag(AuthMethod.email)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                if authMethod == .phone {
                    phoneAuthView
                } else {
                    emailAuthView
                }

                Spacer()
            }
            .padding()
            .navigationBarItems(trailing: Button("Skip") {
                // Allow user to skip auth for now
                dismiss()
            })
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage ?? "An error occurred")
            }
        }
    }

    // MARK: - Phone Authentication View

    private var phoneAuthView: some View {
        VStack(spacing: 20) {
            if !showCodeEntry {
                // Phone number entry
                TextField("Phone Number (+1...)", text: $phoneNumber)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
                    .autocapitalization(.none)

                Button(action: sendVerificationCode) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Send Code")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading || phoneNumber.isEmpty)
            } else {
                // Verification code entry
                TextField("Verification Code", text: $verificationCode)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.numberPad)

                Button(action: verifyCode) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Verify")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(10)
                .disabled(isLoading || verificationCode.isEmpty)

                Button("Resend Code") {
                    showCodeEntry = false
                    verificationCode = ""
                }
                .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Email Authentication View

    private var emailAuthView: some View {
        VStack(spacing: 20) {
            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            Button(action: signInWithEmail) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Text("Sign In")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(isLoading || email.isEmpty || password.isEmpty)
        }
    }

    // MARK: - Actions

    private func sendVerificationCode() {
        isLoading = true

        AuthService.shared.sendPhoneVerification(phoneNumber: phoneNumber) { result in
            isLoading = false

            switch result {
            case .success:
                showCodeEntry = true
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func verifyCode() {
        isLoading = true

        AuthService.shared.verifyPhoneCode(code: verificationCode) { result in
            isLoading = false

            switch result {
            case .success:
                // Authentication successful
                onAuthenticated?(true)
                dismiss()
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }

    private func signInWithEmail() {
        isLoading = true

        AuthService.shared.signIn(email: email, password: password) { result in
            isLoading = false

            switch result {
            case .success:
                // Authentication successful
                onAuthenticated?(true)
                dismiss()
            case .failure(let error):
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    AuthenticationView()
}
```

---

### Step 2: Integration Points

#### Option A: Required at App Launch

```swift
// eaterApp.swift
@main
struct eaterApp: App {
    @StateObject private var authManager = AuthManager()

    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                ContentView()
            } else {
                AuthenticationView { success in
                    if success {
                        authManager.checkAuthStatus()
                    }
                }
            }
        }
    }
}
```

#### Option B: Optional at Launch, Required at Order

```swift
// CuisineSelectionView.swift
struct CuisineSelectionView: View {
    @State private var showAuthenticationRequired = false

    private func handleOrderButtonPress() {
        // Check authentication before order
        guard AuthService.shared.isAuthenticated() else {
            showAuthenticationRequired = true
            return
        }

        // Proceed with order...
        isLoading = true
        placeOrder()
    }

    var body: some View {
        // ... existing UI ...
        .sheet(isPresented: $showAuthenticationRequired) {
            AuthenticationView { success in
                if success {
                    // Retry order after authentication
                    handleOrderButtonPress()
                }
            }
        }
    }
}
```

---

## Token Storage and Security

### Current Implementation (Development)

**Location:** `AuthService.swift:658-677`

```swift
private func saveToken(_ token: String) {
    // TODO: In production, use Keychain instead of UserDefaults
    UserDefaults.standard.set(token, forKey: tokenKey)
}
```

### Production Implementation (Recommended)

```swift
import Security

private func saveToken(_ token: String) {
    let data = token.data(using: .utf8)!

    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "firebaseToken",
        kSecValueData as String: data,
        kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ]

    // Delete old token if exists
    SecItemDelete(query as CFDictionary)

    // Add new token
    SecItemAdd(query as CFDictionary, nil)
}

private func getToken() -> String? {
    let query: [String: Any] = [
        kSecClass as String: kSecClassGenericPassword,
        kSecAttrAccount as String: "firebaseToken",
        kSecReturnData as String: true
    ]

    var result: AnyObject?
    SecItemCopyMatching(query as CFDictionary, &result)

    guard let data = result as? Data else { return nil }
    return String(data: data, encoding: .utf8)
}
```

---

## Backend Authentication Validation

### How Backend Validates Tokens

**File:** Backend server (Node.js example)

```javascript
const admin = require('firebase-admin');

// Middleware to verify Firebase ID tokens
async function verifyToken(req, res, next) {
    const token = req.headers.authorization?.replace('Bearer ', '');

    if (!token) {
        return res.status(401).json({ error: 'No token provided' });
    }

    try {
        const decodedToken = await admin.auth().verifyIdToken(token);
        req.user = decodedToken;  // Attach user info to request
        next();
    } catch (error) {
        return res.status(401).json({ error: 'Invalid token' });
    }
}

// Use in routes
app.post('/api/orders', verifyToken, async (req, res) => {
    const userId = req.user.uid;  // From verified token
    // Create order...
});
```

---

## Testing Authentication

### Test Flow Without UI

```swift
// In any view or test file
func testAuthentication() {
    // Test phone authentication
    AuthService.shared.sendPhoneVerification(phoneNumber: "+14155551234") { result in
        switch result {
        case .success(let verificationId):
            print("✅ Verification sent: \(verificationId)")

            // Then verify with code
            AuthService.shared.verifyPhoneCode(code: "123456") { verifyResult in
                switch verifyResult {
                case .success(let user):
                    print("✅ Authenticated: \(user.uid)")
                case .failure(let error):
                    print("❌ Verification failed: \(error)")
                }
            }
        case .failure(let error):
            print("❌ Send failed: \(error)")
        }
    }
}
```

---

## Summary: Where Authentication Happens

| Location | Purpose | Status |
|----------|---------|--------|
| **AuthService.swift** | All authentication logic | ✅ Implemented |
| **OrderService.swift:195** | Auto-inject auth token | ✅ Implemented |
| **OrderService.swift:502** | Get user for notifications | ✅ Implemented |
| **NotificationService.swift** | Use authenticated user's phone | ✅ Implemented |
| **eaterApp.swift** | App-level auth check | ⚠️ To be added |
| **CuisineSelectionView.swift** | Order-level auth check | ⚠️ To be added |
| **AuthenticationView.swift** | UI for authentication | ⚠️ To be created |

---

## Next Steps

1. ✅ **Backend is ready** - Auth endpoints in `docs/server-config.txt`
2. ✅ **Service layer is ready** - `AuthService` and `NotificationService` implemented
3. ⚠️ **Add auth checks** - Update `CuisineSelectionView.swift` with auth guard
4. ⚠️ **Create UI** - Implement `AuthenticationView.swift` from template above
5. ⚠️ **Update app entry** - Add auth state check in `eaterApp.swift`
6. ⚠️ **Test flow** - Test complete auth → order → notification flow

---

**Authentication is transparent and secure** - all the hard work is done behind the scenes!
