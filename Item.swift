//
//  Item.swift
//  eater
//
//  Created by rajdeep singh on 9/20/25.
//

import Foundation
import SwiftData

// MARK: - Order Model

/// Represents a food delivery order with complete order details
/// This model is persisted using SwiftData for order history tracking
@Model
final class Item {
    /// Timestamp when the order was created
    var timestamp: Date

    /// Creates a new order item
    /// - Parameter timestamp: The time when the order was created
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

// MARK: - Order Data Model

/// Complete order information including cuisine selections and order details
struct Order: Codable, Identifiable {
    /// Unique identifier for the order
    let id: UUID

    /// List of selected cuisine types
    let cuisines: [String]

    /// Timestamp when the order was placed
    let timestamp: Date

    /// Confirmation code for the order
    let confirmationCode: String

    /// Name of the delivery platform (e.g., Uber Eats, DoorDash)
    var platform: String?

    /// Name of the food item ordered
    var itemName: String?

    /// Customization options for the order
    var customization: String?

    /// Base price of the order before fees
    var price: Double?

    /// Total price after fees and taxes
    var totalPrice: Double?

    /// Current status of the order
    var status: OrderStatus

    /// Creates a new order with the specified cuisines
    /// - Parameter cuisines: Array of selected cuisine types
    init(cuisines: [String]) {
        self.id = UUID()
        self.cuisines = cuisines
        self.timestamp = Date()
        self.confirmationCode = String(Int.random(in: 100000...999999))
        self.status = .pending
    }
}

// MARK: - Order Status

/// Represents the current status of an order
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

/// API request structure for placing orders
struct OrderRequest: Codable {
    /// Selected cuisines to order
    let cuisines: [String]

    /// Optional delivery address
    let deliveryAddress: String?

    /// Optional special instructions
    let specialInstructions: String?

    /// Creates a new order request
    /// - Parameters:
    ///   - cuisines: List of selected cuisine types
    ///   - deliveryAddress: Optional delivery address
    ///   - specialInstructions: Optional special instructions for the order
    init(cuisines: [String], deliveryAddress: String? = nil, specialInstructions: String? = nil) {
        self.cuisines = cuisines
        self.deliveryAddress = deliveryAddress
        self.specialInstructions = specialInstructions
    }
}

// MARK: - Order Response

/// API response structure for order placement
struct OrderResponse: Codable {
    /// Indicates if the order was successful
    let success: Bool

    /// The created order information
    let order: OrderDetails?

    /// Error message if the order failed
    let message: String?

    /// Nested order details structure
    struct OrderDetails: Codable {
        let confirmationCode: String
        let estimatedDeliveryTime: Int // minutes
        let platform: String
        let itemName: String
        let customization: String?
        let price: Double
        let totalPrice: Double
    }
}
