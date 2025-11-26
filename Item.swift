//
//  Item.swift
//  eater
//
//  Created by rajdeep singh on 9/20/25.
//

import Foundation
import SwiftData

// MARK: - Order Model

/**
 Represents a food delivery order with complete order details.

 This model is persisted using SwiftData for order history tracking.
 Each item stores a timestamp indicating when the order was created.

 - Note: This class uses SwiftData's `@Model` macro for automatic persistence.
 - Important: The timestamp is used to track order history chronologically.
 */
@Model
final class Item {
    /// Timestamp when the order was created
    var timestamp: Date

    /**
     Creates a new order item.

     - Parameter timestamp: The time when the order was created

     - Returns: A new `Item` instance with the specified timestamp
     */
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

// MARK: - Order Data Model

/**
 Complete order information including cuisine selections and order details.

 The `Order` struct encapsulates all information related to a food delivery order,
 including selected cuisines, pricing, platform details, and order status. This
 structure is used throughout the app to pass order information between views
 and to communicate with the API service.

 - Note: Conforms to `Codable` for API communication and `Identifiable` for SwiftUI lists.

 ## Usage Example
 ```swift
 var order = Order(cuisines: ["Thai", "Italian"])
 order.platform = "Uber Eats"
 order.itemName = "Pad Thai Noodles"
 order.price = 13.95
 ```
 */
struct Order: Codable, Identifiable {
    /// Unique identifier for the order
    let id: UUID

    /// List of selected cuisine types
    let cuisines: [String]

    /// Timestamp when the order was placed
    let timestamp: Date

    /// Confirmation code for the order (6-digit random number)
    let confirmationCode: String

    /// Name of the delivery platform (e.g., Uber Eats, DoorDash)
    var platform: String?

    /// Name of the food item ordered
    var itemName: String?

    /// Customization options for the order (e.g., "Extra cheese, thin crust")
    var customization: String?

    /// Base price of the order before fees
    var price: Double?

    /// Total price after fees and taxes
    var totalPrice: Double?

    /// Current status of the order
    var status: OrderStatus

    /**
     Creates a new order with the specified cuisines.

     This initializer automatically generates a unique ID, timestamp, and
     confirmation code for the order. The initial status is set to `.pending`.

     - Parameter cuisines: Array of selected cuisine types

     - Returns: A new `Order` instance with generated ID and confirmation code
     */
    init(cuisines: [String]) {
        self.id = UUID()
        self.cuisines = cuisines
        self.timestamp = Date()
        self.confirmationCode = String(Int.random(in: 100000...999999))
        self.status = .pending
    }
}

// MARK: - Order Status

/**
 Represents the current status of an order.

 The order lifecycle progresses through these states:
 1. `pending` - Order created but not submitted
 2. `submitted` - Order sent to restaurant
 3. `preparing` - Restaurant is preparing the order
 4. `delivering` - Driver is delivering the order
 5. `delivered` - Order successfully delivered
 6. `cancelled` - Order was cancelled

 - Note: Conforms to `Codable` for API communication.
 */
enum OrderStatus: String, Codable {
    /// Order has been created but not yet submitted
    case pending = "Pending"

    /// Order has been submitted to the restaurant
    case submitted = "Submitted"

    /// Restaurant is preparing the order
    case preparing = "Preparing"

    /// Driver is on the way to deliver the order
    case delivering = "Out for Delivery"

    /// Order has been successfully delivered
    case delivered = "Delivered"

    /// Order was cancelled
    case cancelled = "Cancelled"
}

// MARK: - Order Request

/**
 API request structure for placing orders.

 This structure is encoded to JSON and sent to the backend API when
 placing a new order. It contains all necessary information for order
 processing.

 - Note: Conforms to `Codable` for JSON serialization.

 ## Usage Example
 ```swift
 let request = OrderRequest(
     cuisines: ["Thai", "Indian"],
     deliveryAddress: "123 Main St",
     specialInstructions: "Ring doorbell"
 )
 ```
 */
struct OrderRequest: Codable {
    /// Selected cuisines to order
    let cuisines: [String]

    /// Optional delivery address
    let deliveryAddress: String?

    /// Optional special instructions for the order
    let specialInstructions: String?

    /**
     Creates a new order request.

     - Parameters:
       - cuisines: List of selected cuisine types
       - deliveryAddress: Optional delivery address
       - specialInstructions: Optional special instructions for the order

     - Returns: A new `OrderRequest` instance ready for API submission
     */
    init(cuisines: [String], deliveryAddress: String? = nil, specialInstructions: String? = nil) {
        self.cuisines = cuisines
        self.deliveryAddress = deliveryAddress
        self.specialInstructions = specialInstructions
    }
}

// MARK: - Order Response

/**
 API response structure for order placement.

 This structure is decoded from the JSON response received from the backend
 API after attempting to place an order. It indicates success or failure
 and provides order details or error messages accordingly.

 - Note: Conforms to `Codable` for JSON deserialization.

 ## Response Structure
 - On success: `success` is `true` and `order` contains the order details
 - On failure: `success` is `false` and `message` contains the error description
 */
struct OrderResponse: Codable {
    /// Indicates if the order was successful
    let success: Bool

    /// The created order information (present on success)
    let order: OrderDetails?

    /// Error message if the order failed (present on failure)
    let message: String?

    /**
     Nested order details structure.

     Contains the detailed information about a successfully placed order,
     including confirmation code, delivery estimates, and pricing.
     */
    struct OrderDetails: Codable {
        /// Confirmation code for the order
        let confirmationCode: String

        /// Estimated delivery time in minutes
        let estimatedDeliveryTime: Int

        /// Name of the delivery platform
        let platform: String

        /// Name of the food item ordered
        let itemName: String

        /// Optional customization details
        let customization: String?

        /// Base price before fees
        let price: Double

        /// Total price including fees
        let totalPrice: Double
    }
}

// MARK: - Delivery Quote

/**
 Represents a delivery quote from Uber Eats.

 Contains pricing and timing information for a potential delivery.
 Used to show users the cost and estimated delivery time before confirming order.

 - Note: Conforms to `Codable` for API communication.
 */
struct DeliveryQuote: Codable {
    /// Unique quote identifier
    let id: String

    /// Delivery fee in cents (e.g., 599 = $5.99)
    let fee: Int

    /// Currency code (e.g., "usd")
    let currency: String

    /// Estimated delivery time in minutes
    let duration: Int

    /// ISO 8601 timestamp when the quote expires
    let expires: String

    /// Formatted delivery fee for display
    var formattedFee: String {
        let dollars = Double(fee) / 100.0
        return String(format: "$%.2f", dollars)
    }
}

/**
 Request structure for getting a delivery quote.

 - Note: Conforms to `Codable` for JSON serialization.
 */
struct DeliveryQuoteRequest: Codable {
    /// Pickup address (restaurant location)
    let pickupAddress: String

    /// Dropoff address (customer location)
    let dropoffAddress: String
}
