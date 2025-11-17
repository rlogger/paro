//
//  OrderService.swift
//  paro
//
//  API service layer for handling food delivery orders
//

import Foundation

// MARK: - API Error Types

/**
 Errors that can occur during API operations.

 This enum provides comprehensive error handling for all possible failure scenarios
 when communicating with the backend API. Each case includes associated values
 with additional context about the error.

 - Note: Conforms to `LocalizedError` to provide user-friendly error messages.

 ## Error Cases
 - `networkError`: Network connection failed
 - `invalidResponse`: Invalid response from server
 - `serverError`: Server returned an error status code
 - `decodingError`: Failed to decode the response
 - `invalidURL`: Invalid URL
 - `timeout`: Request timeout
 - `unknown`: Unknown error occurred
 */
enum APIError: LocalizedError {
    /// Network connection failed
    case networkError(Error)

    /// Invalid response from server
    case invalidResponse

    /// Server returned an error status code
    case serverError(statusCode: Int, message: String?)

    /// Failed to decode the response
    case decodingError(Error)

    /// Invalid URL
    case invalidURL

    /// Request timeout
    case timeout

    /// Unknown error occurred
    case unknown

    /**
     User-friendly error description.

     Provides a localized, human-readable description of the error suitable
     for display to end users.

     - Returns: A descriptive error message string
     */
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message ?? "Unknown error")"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .invalidURL:
            return "Invalid API URL"
        case .timeout:
            return "Request timed out"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}

// MARK: - Order Service

/**
 Service class for handling all order-related API operations.

 `OrderService` provides a centralized interface for all backend API communication
 related to food delivery orders. It handles network requests, error handling,
 response parsing, and provides both callback-based and async/await APIs.

 - Important: Uses the singleton pattern. Access via `OrderService.shared`.

 ## Features
 - Asynchronous order placement with completion handlers
 - Modern async/await support (iOS 15+)
 - Comprehensive error handling
 - Configurable timeout intervals
 - Mock data support for development

 ## Usage Example
 ```swift
 OrderService.shared.placeOrder(cuisines: ["Thai", "Italian"]) { result in
     switch result {
     case .success(let order):
         print("Order placed: \\(order.confirmationCode)")
     case .failure(let error):
         print("Error: \\(error.localizedDescription)")
     }
 }
 ```
 */
class OrderService {
    // MARK: - Properties

    /// Shared singleton instance
    static let shared = OrderService()

    /// Base URL for the API (replace with your actual API endpoint)
    private let baseURL = "https://your-backend-server.com/api"

    /// Postmates API base URL (for future direct integration if needed)
    private let postmatesBaseURL = "https://api.postmates.com/v1"

    /// URL session configuration
    private let session: URLSession

    /// Request timeout interval in seconds
    private let timeoutInterval: TimeInterval = 30.0

    // MARK: - Initialization

    /**
     Private initializer for singleton pattern.

     Configures the URL session with appropriate timeout settings and
     network policies.
     */
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutInterval
        configuration.timeoutIntervalForResource = timeoutInterval
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Public Methods

    /**
     Places an order with the selected cuisines.

     Sends a POST request to the backend API to place a new food delivery order.
     The method handles all aspects of the API call including request creation,
     network execution, response parsing, and error handling.

     - Parameters:
       - cuisines: Array of selected cuisine types
       - deliveryAddress: Optional delivery address
       - specialInstructions: Optional special instructions
       - completion: Completion handler with Result containing Order or APIError

     - Note: The completion handler is always called on the main queue.
     - Important: Currently uses mock data for development. Remove mock logic for production.

     ## Example
     ```swift
     OrderService.shared.placeOrder(
         cuisines: ["Thai", "Indian"],
         deliveryAddress: "123 Main St",
         specialInstructions: "Ring doorbell"
     ) { result in
         // Handle result
     }
     ```
     */
    func placeOrder(
        cuisines: [String],
        deliveryAddress: String? = nil,
        specialInstructions: String? = nil,
        completion: @escaping (Result<Order, APIError>) -> Void
    ) {
        // Validate input
        guard !cuisines.isEmpty else {
            completion(.failure(.invalidResponse))
            return
        }

        // Create the request
        guard let url = URL(string: "\(baseURL)/order") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("1.0", forHTTPHeaderField: "X-API-Version")

        // Add Firebase authentication token if available
        if let token = getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Create request body
        let orderRequest = OrderRequest(
            cuisines: cuisines,
            deliveryAddress: deliveryAddress,
            specialInstructions: specialInstructions
        )

        do {
            request.httpBody = try JSONEncoder().encode(orderRequest)
        } catch {
            completion(.failure(.decodingError(error)))
            return
        }

        // Make the API call
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            // Handle network errors
            if let error = error {
                if (error as NSError).code == NSURLErrorTimedOut {
                    completion(.failure(.timeout))
                } else {
                    completion(.failure(.networkError(error)))
                }
                return
            }

            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }

            // Check status code
            guard (200...299).contains(httpResponse.statusCode) else {
                let message = String(data: data ?? Data(), encoding: .utf8)
                completion(.failure(.serverError(statusCode: httpResponse.statusCode, message: message)))
                return
            }

            // Parse response data
            guard let data = data else {
                completion(.failure(.invalidResponse))
                return
            }

            // Decode response
            do {
                let response = try JSONDecoder().decode(OrderResponse.self, from: data)

                if response.success, let orderDetails = response.order {
                    // Create Order object from response
                    var order = Order(cuisines: cuisines)
                    order.platform = orderDetails.platform
                    order.itemName = orderDetails.itemName
                    order.customization = orderDetails.customization
                    order.price = orderDetails.price
                    order.totalPrice = orderDetails.totalPrice
                    order.status = .submitted

                    // Send order confirmation SMS notification
                    self?.sendOrderNotification(order: order)

                    completion(.success(order))
                } else {
                    let message = response.message ?? "Order placement failed"
                    completion(.failure(.serverError(statusCode: httpResponse.statusCode, message: message)))
                }
            } catch {
                // DEMO MODE: Always succeed with mock order
                // This makes the app work without a backend server
                print("✅ DEMO MODE: Using mock order (no real API)")
                let mockOrder = self?.createMockOrder(cuisines: cuisines)
                completion(.success(mockOrder!))

                // For production with real backend, use:
                // completion(.failure(.decodingError(error)))
            }
        }

        task.resume()
    }

    /**
     Places an order asynchronously using async/await.

     Modern Swift concurrency API for placing orders. Provides a cleaner
     syntax for asynchronous operations compared to callbacks.

     - Parameters:
       - cuisines: Array of selected cuisine types
       - deliveryAddress: Optional delivery address
       - specialInstructions: Optional special instructions

     - Returns: The created Order

     - Throws: APIError if the request fails

     - Requires: iOS 15.0 or later

     ## Example
     ```swift
     do {
         let order = try await OrderService.shared.placeOrder(
             cuisines: ["Thai", "Italian"]
         )
         print("Order placed: \\(order.confirmationCode)")
     } catch {
         print("Error: \\(error)")
     }
     ```
     */
    @available(iOS 15.0, *)
    func placeOrder(
        cuisines: [String],
        deliveryAddress: String? = nil,
        specialInstructions: String? = nil
    ) async throws -> Order {
        return try await withCheckedThrowingContinuation { continuation in
            placeOrder(
                cuisines: cuisines,
                deliveryAddress: deliveryAddress,
                specialInstructions: specialInstructions
            ) { result in
                continuation.resume(with: result)
            }
        }
    }

    // MARK: - Private Helper Methods

    /**
     Creates a mock order for development/testing purposes.

     Generates realistic order data based on the selected cuisines for
     development and testing without requiring a backend API.

     - Parameter cuisines: Selected cuisines

     - Returns: A mock Order object with simulated data

     - Important: This method should be removed in production builds.
     */
    private func createMockOrder(cuisines: [String]) -> Order {
        var order = Order(cuisines: cuisines)

        // DEMO MODE: Realistic order data for demonstrations
        let firstCuisine = cuisines.first ?? "Water"

        switch firstCuisine {
        case "Italian":
            order.platform = "Uber Eats"
            order.itemName = "Margherita Pizza"
            order.customization = "Extra cheese, thin crust"
            order.price = 14.95
            order.totalPrice = 22.45
        case "Thai":
            order.platform = "Uber Eats"
            order.itemName = "Pad Thai Noodles"
            order.customization = "Choice of Protein: Vegetables"
            order.price = 13.95
            order.totalPrice = 23.80
        case "Indian":
            order.platform = "DoorDash"
            order.itemName = "Chicken Tikka Masala"
            order.customization = "Mild spice, extra naan"
            order.price = 16.95
            order.totalPrice = 25.60
        case "Fries":
            order.platform = "Uber Eats"
            order.itemName = "Loaded Fries"
            order.customization = "Extra bacon, cheese sauce"
            order.price = 8.95
            order.totalPrice = 15.20
        case "Panda":
            order.platform = "Grubhub"
            order.itemName = "Orange Chicken Bowl"
            order.customization = "Fried rice, extra sauce"
            order.price = 11.95
            order.totalPrice = 18.75
        case "Water":
            order.platform = "Uber Eats"
            order.itemName = "Premium Water Bottle"
            order.customization = "Sparkling"
            order.price = 2.99
            order.totalPrice = 8.50
        default:
            order.platform = "Uber Eats"
            order.itemName = "Mixed Cuisine Special"
            order.customization = "Chef's choice"
            order.price = 15.95
            order.totalPrice = 24.30
        }

        order.status = .submitted
        print("✅ DEMO MODE: Created order for \(firstCuisine) - \(order.itemName ?? "Unknown")")
        return order
    }

    /**
     Retrieves the current Firebase authentication token.

     Gets the stored Firebase ID token from UserDefaults (or Keychain in production).
     This token is used to authenticate API requests with the backend.

     - Returns: The Firebase ID token if available, nil otherwise

     - Note: In production, tokens should be stored in Keychain for security
     */
    private func getAuthToken() -> String? {
        // In production, retrieve from Keychain
        // For now, using UserDefaults as placeholder
        return UserDefaults.standard.string(forKey: "firebaseToken")
    }

    /**
     Gets a delivery quote from Postmates.

     Requests a delivery quote from the backend, which queries Postmates API
     for pricing and estimated delivery time.

     - Parameters:
       - pickupAddress: Address where food will be picked up
       - dropoffAddress: Address where food will be delivered
       - completion: Completion handler with Result containing quote details or APIError

     - Note: Requires authentication
     */
    func getDeliveryQuote(
        pickupAddress: String,
        dropoffAddress: String,
        completion: @escaping (Result<DeliveryQuote, APIError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/delivery/quote") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add authentication
        if let token = getAuthToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let quoteRequest = DeliveryQuoteRequest(
            pickupAddress: pickupAddress,
            dropoffAddress: dropoffAddress
        )

        do {
            request.httpBody = try JSONEncoder().encode(quoteRequest)
        } catch {
            completion(.failure(.decodingError(error)))
            return
        }

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                completion(.failure(.invalidResponse))
                return
            }

            do {
                let quote = try JSONDecoder().decode(DeliveryQuote.self, from: data)
                completion(.success(quote))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }

        task.resume()
    }

    // MARK: - Notification Helpers

    /**
     Sends SMS notification for successful order placement.

     Automatically triggers an SMS notification via NotificationService when
     an order is successfully placed. This notifies the user about their order
     confirmation with key details.

     - Parameter order: The successfully placed order

     - Note: This method fires asynchronously and does not block the order flow.
             If SMS fails, the order is still considered successful.
     */
    private func sendOrderNotification(order: Order) {
        // Get user's phone number from current user
        // TODO: Replace with actual phone number from user profile
        // For now, this is a placeholder - phone number should come from:
        // 1. Firebase user profile (if using Firebase Phone Auth)
        // 2. Backend API user profile endpoint
        // 3. Cached user data in UserDefaults/Keychain

        guard let currentUser = AuthService.shared.getCurrentUser(),
              let phoneNumber = currentUser.phoneNumber else {
            print("⚠️ No phone number available for SMS notification")
            return
        }

        // Send order confirmation SMS
        NotificationService.shared.sendOrderConfirmation(
            to: phoneNumber,
            order: order
        ) { result in
            switch result {
            case .success:
                print("✅ Order confirmation SMS sent successfully")
            case .failure(let error):
                print("⚠️ Failed to send order confirmation SMS: \(error.localizedDescription)")
                // Don't fail the order if SMS fails - it's a nice-to-have
            }
        }
    }

    /**
     Cancels an active order.

     Sends a cancellation request to the backend API for the specified order.

     - Parameters:
       - orderId: The ID of the order to cancel
       - completion: Completion handler indicating success or failure

     - Note: This is a placeholder for future functionality.
     */
    func cancelOrder(orderId: UUID, completion: @escaping (Result<Void, APIError>) -> Void) {
        // Implementation for order cancellation
        // This is a placeholder for future functionality
        print("Cancel order: \(orderId)")
        completion(.success(()))
    }

    /**
     Fetches the current status of an order.

     Queries the backend API for the current status of a specific order.

     - Parameters:
       - orderId: The ID of the order
       - completion: Completion handler with the order status

     - Note: This is a placeholder for future functionality.
     */
    func getOrderStatus(orderId: UUID, completion: @escaping (Result<OrderStatus, APIError>) -> Void) {
        // Implementation for fetching order status
        // This is a placeholder for future functionality
        print("Fetch status for order: \(orderId)")
        completion(.success(.preparing))
    }
}
