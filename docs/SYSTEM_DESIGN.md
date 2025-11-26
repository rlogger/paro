# System Design

Food delivery app with simplified ordering through preset cuisine selections.

## Architecture

```
┌─────────────────────────┐
│    iOS App (SwiftUI)    │
│  - Auth (Firebase SDK)  │
│  - OrderService         │
└───────────┬─────────────┘
            │ HTTPS + Firebase Token
            ▼
┌─────────────────────────┐
│   Backend (Node.js)     │
│  - Token verification   │
│  - Order orchestration  │
└────┬──────────┬─────────┘
     │          │
     ▼          ▼
┌─────────┐  ┌───────────┐
│Firebase │  │Uber Eats  │
│Auth/DB  │  │    API    │
└─────────┘  └───────────┘
```

## Core Flow

**Auth:** User signs in → Firebase token → Stored in Keychain → Included in API requests

**Order:** Cuisines selected → Backend → Uber Eats quote → User confirms → Delivery created → Saved to Firestore → Confirmation shown

**Tracking:** Uber Eats webhooks → Backend updates Firestore → Push notification sent

## Tech Stack

**iOS:**
- Swift 5.9+, SwiftUI, SwiftData
- Firebase Auth SDK, URLSession
- Keychain for secure token storage

**Backend:**
- Node.js, Express.js
- Firebase Admin SDK
- Uber Eats API integration

**Data:**
- Firestore (users, orders, addresses)
- SwiftData (local caching)

## Collections

**users/{userId}**
```
email, displayName, phoneNumber, preferences, stats
```

**orders/{orderId}**
```
userId, cuisines, platform, status, itemName, price,
deliveryAddress, uberEatsDeliveryId, confirmationCode, timestamps
```

**deliveryAddresses/{userId}/addresses/{addressId}**
```
label, address, coordinates, isDefault
```

## Security

- Firebase ID tokens for authentication
- Tokens stored in Keychain (production)
- Firestore rules restrict access to user's own data
- Backend validates tokens via Firebase Admin SDK
- HTTPS only, rate limiting

## API Endpoints

```
POST   /api/auth/login
POST   /api/orders              # Create order
GET    /api/orders/:id          # Order status
POST   /api/delivery/quote      # Uber Eats quote
POST   /api/webhooks/ubereats   # Status updates
```

## Performance

- URLSession connection pooling
- Firestore indexed queries
- Token caching (1 hour)
- Request timeout: 30s
- Auto-scaling backend

## Uber Eats Flow

1. Get delivery quote (pickup → dropoff)
2. User confirms order
3. Create delivery with quote_id
4. Uber Eats assigns courier
5. Webhooks update order status
6. Push notifications to user

**Status states:** pending → accepted → preparing → pickup → delivering → delivered

## Monitoring

- Firebase Analytics for user events
- Error tracking (Sentry/Crashlytics)
- Performance monitoring
- API response time tracking

## Future Phases

**Phase 2:** Order history, delivery tracking map, favorites, dietary filters

**Phase 3:** Multi-platform (Uber Eats, DoorDash), price comparison

**Phase 4:** Group ordering, split payment

**Phase 5:** Smart recommendations, scheduled orders, subscriptions
