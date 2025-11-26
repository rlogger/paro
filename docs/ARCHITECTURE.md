# Architecture

Model-View-Service pattern with SwiftUI, Firebase Auth, and Uber Eats delivery.

## Stack

- **UI:** SwiftUI + SwiftData
- **Auth:** Firebase Authentication
- **Backend:** Custom API + Firestore
- **Delivery:** Uber Eats API

## Layers

**Views** (`*View.swift`)
- WelcomeView, CuisineSelectionView, ConfirmationView
- Manage UI state with `@State`
- Delegate logic to services

**Services** (`*Service.swift`)
- `AuthService` - Firebase auth, token management
- `OrderService` - API calls, order placement
- Singleton pattern with async/await

**Models** (`Item.swift`)
- Order, User, OrderStatus, DeliveryQuote
- Codable for API/DB serialization

## Key Flows

**Auth:** User signs in → Firebase token → Stored in Keychain → Added to API requests

**Order:** Select cuisines → OrderService → Backend → Uber Eats → Firestore → Confirmation

## File Structure

```
eaterr/
├── *View.swift     # UI layer
├── *Service.swift  # Business logic
├── Item.swift      # Data models
└── eaterApp.swift  # App entry
```

## Dependencies

- Firebase (Auth, Firestore, Messaging)
- URLSession for networking
- SwiftData for local storage

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for configuration details.
