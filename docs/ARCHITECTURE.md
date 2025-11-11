# Eater App Architecture

Quick reference guide for understanding the app's architecture and code organization.

## Overview

Eater follows a simple, maintainable architecture focused on clarity and ease of development:

- **Pattern:** Model-View-Service (MVS)
- **UI Framework:** SwiftUI
- **Data Persistence:** SwiftData (local) + Firestore (cloud)
- **Networking:** URLSession with custom service layer
- **Authentication:** Firebase Authentication

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────────┐
│                   SwiftUI Views                      │
│  (WelcomeView, CuisineSelectionView, etc.)          │
└──────────────────┬──────────────────────────────────┘
                   │
                   │ @State, @StateObject
                   │
┌──────────────────▼──────────────────────────────────┐
│                Service Layer                         │
│  ┌──────────────┐  ┌──────────────┐                │
│  │ AuthService  │  │ OrderService │                 │
│  └──────────────┘  └──────────────┘                │
└──────────────────┬──────────────────────────────────┘
                   │
                   │ URLSession / Firebase SDK
                   │
┌──────────────────▼──────────────────────────────────┐
│              External Services                       │
│  ┌──────────────┐  ┌──────────────┐                │
│  │   Firebase   │  │   Backend    │                 │
│  │   (Auth +    │  │   API        │                 │
│  │   Firestore) │  │   (Postmates)│                 │
│  └──────────────┘  └──────────────┘                │
└─────────────────────────────────────────────────────┘
```

---

## Layer Responsibilities

### 1. View Layer (SwiftUI)

**Location:** Root directory (all *View.swift files)

**Responsibilities:**
- Render UI components
- Handle user interactions
- Manage local UI state with `@State`
- Observe service layer with `@StateObject`

**Files:**
- `WelcomeView.swift` - Landing screen
- `CuisineSelectionView.swift` - Cuisine selection and ordering
- `ConfirmationView.swift` - Order confirmation display
- `ContentView.swift` - Root view container

**Best Practices:**
- Keep views simple and focused
- Extract complex UI into sub-components
- Use computed properties for simple transformations
- Delegate business logic to services

### 2. Service Layer

**Location:** Root directory (*Service.swift files)

**Responsibilities:**
- Business logic
- API communication
- Data transformation
- State management

**Files:**
- `AuthService.swift` - Firebase authentication
  - Sign in/up/out
  - Token management
  - User session handling

- `OrderService.swift` - Order management
  - Place orders
  - Get delivery quotes
  - Track order status
  - API communication

**Best Practices:**
- Use singleton pattern (`shared` instance)
- Provide both callback and async/await APIs
- Comprehensive error handling
- Mock data support for development

### 3. Model Layer

**Location:** `Item.swift`

**Responsibilities:**
- Data structures
- Business entities
- Codable conformance for serialization

**Types:**
- `Order` - Order information
- `User` - User profile
- `OrderStatus` - Order state enum
- `DeliveryQuote` - Postmates quote
- Request/Response models

**Best Practices:**
- Immutable by default (use `let`)
- Conform to `Codable` for API/persistence
- Include validation logic when needed
- Document all properties

---

## Data Flow

### Authentication Flow

```
User Action (Sign In)
    ↓
WelcomeView / AuthView
    ↓
AuthService.signIn(email, password)
    ↓
Firebase SDK
    ↓
Firebase Auth Server
    ↓
Return ID Token
    ↓
Store Token (Keychain)
    ↓
Update UI State
```

### Order Placement Flow

```
User Action (Tap Order)
    ↓
CuisineSelectionView
    ↓
OrderService.placeOrder(cuisines)
    ↓
Add Auth Token to Request
    ↓
Backend API
    ↓
Postmates API (Get Quote + Create Delivery)
    ↓
Save to Firestore
    ↓
Return Order Details
    ↓
Show ConfirmationView
```

---

## State Management

### View-Level State (@State)

For simple, local UI state:
```swift
@State private var selectedCuisines: Set<String> = []
@State private var isLoading = false
@State private var showError = false
```

### Service-Level State (Singleton)

For app-wide state:
```swift
// Access shared services
AuthService.shared.getCurrentUser()
OrderService.shared.placeOrder(...)
```

### Persistent State

**Local (SwiftData):**
- Order history
- User preferences

**Cloud (Firestore):**
- User profile
- Order records
- Delivery addresses

---

## Error Handling

### Service Layer

Use `Result` type for async operations:
```swift
func placeOrder(completion: @escaping (Result<Order, APIError>) -> Void) {
    // Implementation
}
```

Custom error enums:
```swift
enum APIError: LocalizedError {
    case networkError(Error)
    case invalidResponse
    case serverError(statusCode: Int, message: String?)
    // ...
}
```

### View Layer

Display errors to users:
```swift
.alert("Error", isPresented: $showError) {
    Button("OK", role: .cancel) { }
} message: {
    Text(errorMessage ?? "An error occurred")
}
```

---

## Networking

### URLSession Configuration

```swift
private let session: URLSession

init() {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest = 30.0
    self.session = URLSession(configuration: configuration)
}
```

### Request Pattern

```swift
// 1. Create URL
guard let url = URL(string: "\(baseURL)/endpoint") else {
    completion(.failure(.invalidURL))
    return
}

// 2. Configure request
var request = URLRequest(url: url)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")
request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

// 3. Encode body
let body = try JSONEncoder().encode(requestData)
request.httpBody = body

// 4. Execute request
let task = session.dataTask(with: request) { data, response, error in
    // Handle response
}
task.resume()
```

---

## Security

### Token Storage

**Current (Development):**
```swift
UserDefaults.standard.set(token, forKey: "firebaseToken")
```

**Production (Recommended):**
```swift
// Store in Keychain
let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccount as String: "firebaseToken",
    kSecValueData as String: tokenData
]
SecItemAdd(query as CFDictionary, nil)
```

### API Authentication

All backend requests include Firebase ID token:
```swift
request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
```

Backend verifies token:
```javascript
const decodedToken = await admin.auth().verifyIdToken(token);
const userId = decodedToken.uid;
```

---

## Testing Strategy

### Unit Tests (Future)

- Service layer methods
- Model transformations
- Error handling

### Integration Tests (Future)

- API communication
- Authentication flow
- Order placement

### UI Tests (Future)

- Navigation flow
- User interactions
- Error states

---

## Code Organization

### File Structure

```
eaterr/
├── Views/              (Future organization)
│   ├── WelcomeView.swift
│   ├── CuisineSelectionView.swift
│   └── ConfirmationView.swift
├── Services/           (Future organization)
│   ├── AuthService.swift
│   └── OrderService.swift
├── Models/             (Future organization)
│   └── Item.swift
└── Supporting Files/
    ├── eaterApp.swift
    └── Assets.xcassets/
```

### Code Style

- Use MARK comments for organization
- Document public APIs
- Keep functions focused and small
- Prefer composition over inheritance

---

## Dependencies

### Current

- **SwiftUI** - UI framework (native)
- **SwiftData** - Local persistence (native)
- **Firebase SDK** - Authentication and Firestore
  - FirebaseAuth
  - FirebaseCore
  - FirebaseFirestore
  - FirebaseMessaging

### Future

- SwiftLint - Code linting
- Quick/Nimble - Testing framework

---

## Performance Considerations

### View Optimization

- Use `@State` sparingly
- Extract complex computations
- Lazy loading for lists
- Avoid unnecessary re-renders

### Network Optimization

- Request timeout: 30 seconds
- Connection pooling (URLSession)
- Token caching
- Retry logic for failures

### Database Optimization

- Index frequently queried fields
- Limit query results
- Use pagination for large datasets
- Cache frequently accessed data

---

## Deployment

### Development

- Use Firebase emulator for testing
- Mock API responses
- Development certificates

### Production

- Production Firebase project
- Production API endpoints
- Production certificates
- App Store distribution

---

For more detailed information, see:
- [System Design](SYSTEM_DESIGN.md) - Complete architecture
- [Firebase Setup](FIREBASE_SETUP.md) - Firebase integration
- [Contributing](../CONTRIBUTING.md) - Development guidelines
