//
//  NotificationService.swift
//  paro
//
//  Real-time SMS notifications via Twilio API
//

import Foundation

/**
 Service for managing SMS notifications via Twilio.

 `NotificationService` handles all SMS-based notifications for order updates,
 delivery status changes, and authentication codes using Twilio's Messaging API.

 - Important: Uses the singleton pattern. Access via `NotificationService.shared`.

 ## Features
 - SMS notifications for order status updates
 - Real-time delivery tracking alerts
 - Two-factor authentication codes
 - Customizable message templates
 - Delivery confirmation

 ## Prerequisites
 Before using this service:
 1. Sign up for Twilio account (https://www.twilio.com/try-twilio)
 2. Get Account SID and Auth Token from Twilio Console
 3. Purchase a Twilio phone number
 4. Configure environment variables on backend server
 5. Backend server must have Twilio SDK installed

 ## Backend Integration
 The iOS app communicates with your backend server, which then calls Twilio API.
 This keeps your Twilio credentials secure on the server side.

 ## Usage Example
 ```swift
 // Send order confirmation
 NotificationService.shared.sendOrderConfirmation(
     to: "+14155551234",
     order: completedOrder
 ) { result in
     switch result {
     case .success:
         print("Notification sent!")
     case .failure(let error):
         print("Failed: \(error)")
     }
 }
 ```

 - Note: All SMS operations are processed through the backend server.
         The app never directly accesses Twilio API credentials.
 */
class NotificationService {
    // MARK: - Properties

    /// Shared singleton instance
    static let shared = NotificationService()

    /// Base URL for the backend API
    private let baseURL = "https://your-backend-server.com/api"

    /// URL session for API calls
    private let session: URLSession

    /// Request timeout interval
    private let timeoutInterval: TimeInterval = 30.0

    // MARK: - Initialization

    /**
     Private initializer for singleton pattern.
     */
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = timeoutInterval
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Public Methods

    /**
     Sends order confirmation SMS notification.

     Sends a text message to the user confirming their order was placed successfully.
     Includes order details, confirmation code, and estimated delivery time.

     - Parameters:
       - phoneNumber: User's phone number (E.164 format, e.g., +14155551234)
       - order: The order that was placed
       - completion: Completion handler indicating success or failure

     ## Example
     ```swift
     NotificationService.shared.sendOrderConfirmation(
         to: "+14155551234",
         order: myOrder
     ) { result in
         if case .success = result {
             print("SMS sent successfully")
         }
     }
     ```

     - Note: Phone numbers must be in E.164 format (+[country code][number])
     */
    func sendOrderConfirmation(
        to phoneNumber: String,
        order: Order,
        completion: @escaping (Result<Void, NotificationError>) -> Void
    ) {
        let message = """
        🥕 Paro Order Confirmed!

        Order #\(order.confirmationCode)
        Platform: \(order.platform ?? "Unknown")
        Item: \(order.itemName ?? "Your order")
        Total: $\(String(format: "%.2f", order.totalPrice ?? 0))

        Track your order in the app!
        """

        sendSMS(to: phoneNumber, message: message, type: .orderConfirmation, completion: completion)
    }

    /**
     Sends order status update notification.

     Notifies user when order status changes (preparing, out for delivery, delivered).

     - Parameters:
       - phoneNumber: User's phone number
       - status: New order status
       - orderId: Order confirmation code
       - completion: Completion handler

     ## Example
     ```swift
     NotificationService.shared.sendStatusUpdate(
         to: "+14155551234",
         status: .delivering,
         orderId: "123456"
     ) { _ in }
     ```
     */
    func sendStatusUpdate(
        to phoneNumber: String,
        status: OrderStatus,
        orderId: String,
        completion: @escaping (Result<Void, NotificationError>) -> Void
    ) {
        let message: String

        switch status {
        case .preparing:
            message = "🍳 Your order #\(orderId) is being prepared!"
        case .delivering:
            message = "🚗 Your order #\(orderId) is out for delivery! Your food will arrive soon."
        case .delivered:
            message = "✅ Your order #\(orderId) has been delivered! Enjoy your meal!"
        case .cancelled:
            message = "❌ Your order #\(orderId) has been cancelled."
        default:
            message = "📦 Order #\(orderId) status: \(status.rawValue)"
        }

        sendSMS(to: phoneNumber, message: message, type: .statusUpdate, completion: completion)
    }

    /**
     Sends SMS verification code for authentication.

     Sends a 6-digit verification code to user's phone number for two-factor authentication.

     - Parameters:
       - phoneNumber: User's phone number
       - code: 6-digit verification code
       - completion: Completion handler

     ## Example
     ```swift
     let code = String(Int.random(in: 100000...999999))
     NotificationService.shared.sendVerificationCode(
         to: "+14155551234",
         code: code
     ) { _ in }
     ```

     - Important: Verification codes should be generated on the backend for security.
     */
    func sendVerificationCode(
        to phoneNumber: String,
        code: String,
        completion: @escaping (Result<Void, NotificationError>) -> Void
    ) {
        let message = """
        Your Paro verification code is: \(code)

        This code will expire in 10 minutes.
        Do not share this code with anyone.
        """

        sendSMS(to: phoneNumber, message: message, type: .verification, completion: completion)
    }

    /**
     Sends courier arrival notification.

     Alerts user that delivery courier is nearby (within 5 minutes).

     - Parameters:
       - phoneNumber: User's phone number
       - orderId: Order confirmation code
       - estimatedMinutes: Estimated minutes until arrival
       - completion: Completion handler
     */
    func sendCourierArrivalAlert(
        to phoneNumber: String,
        orderId: String,
        estimatedMinutes: Int,
        completion: @escaping (Result<Void, NotificationError>) -> Void
    ) {
        let message = "🚨 Your delivery is almost here! Order #\(orderId) will arrive in approximately \(estimatedMinutes) minute\(estimatedMinutes == 1 ? "" : "s")."

        sendSMS(to: phoneNumber, message: message, type: .courierNearby, completion: completion)
    }

    // MARK: - Private Methods

    /**
     Sends SMS via backend API.

     Makes a POST request to the backend server, which then uses Twilio API to send the SMS.

     - Parameters:
       - phoneNumber: Recipient's phone number (E.164 format)
       - message: Message content
       - type: Notification type for tracking/analytics
       - completion: Completion handler

     - Important: This method calls your backend server, NOT Twilio directly.
                  Your backend server must have Twilio credentials configured.
     */
    private func sendSMS(
        to phoneNumber: String,
        message: String,
        type: NotificationType,
        completion: @escaping (Result<Void, NotificationError>) -> Void
    ) {
        // Validate phone number format
        guard isValidPhoneNumber(phoneNumber) else {
            completion(.failure(.invalidPhoneNumber))
            return
        }

        // Create API endpoint URL
        guard let url = URL(string: "\(baseURL)/notifications/sms") else {
            completion(.failure(.invalidURL))
            return
        }

        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Add authentication token
        if let token = AuthService.shared.getCurrentToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Create request body
        let requestBody = SMSRequest(
            to: phoneNumber,
            message: message,
            type: type.rawValue
        )

        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            completion(.failure(.encodingError))
            return
        }

        // Make API call
        let task = session.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error.localizedDescription)))
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.invalidResponse))
                    return
                }

                guard (200...299).contains(httpResponse.statusCode) else {
                    if let data = data,
                       let errorMessage = String(data: data, encoding: .utf8) {
                        completion(.failure(.serverError(httpResponse.statusCode, errorMessage)))
                    } else {
                        completion(.failure(.serverError(httpResponse.statusCode, "Unknown error")))
                    }
                    return
                }

                completion(.success(()))
            }
        }

        task.resume()
    }

    /**
     Validates phone number format.

     Checks if phone number is in E.164 format (+[country code][number]).

     - Parameter phoneNumber: Phone number to validate
     - Returns: true if valid, false otherwise

     ## Valid Examples
     - +14155551234 (US)
     - +442071234567 (UK)
     - +33612345678 (France)
     */
    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let pattern = "^\\+[1-9]\\d{1,14}$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(location: 0, length: phoneNumber.utf16.count)
        return regex?.firstMatch(in: phoneNumber, range: range) != nil
    }
}

// MARK: - Supporting Types

/**
 Types of SMS notifications.
 */
enum NotificationType: String, Codable {
    case orderConfirmation = "order_confirmation"
    case statusUpdate = "status_update"
    case verification = "verification"
    case courierNearby = "courier_nearby"
    case deliveryComplete = "delivery_complete"
}

/**
 SMS request structure sent to backend.
 */
struct SMSRequest: Codable {
    /// Recipient phone number (E.164 format)
    let to: String

    /// Message content
    let message: String

    /// Notification type
    let type: String
}

/**
 Errors that can occur during notification operations.
 */
enum NotificationError: LocalizedError {
    case invalidPhoneNumber
    case invalidURL
    case encodingError
    case networkError(String)
    case invalidResponse
    case serverError(Int, String)
    case twilioError(String)

    var errorDescription: String? {
        switch self {
        case .invalidPhoneNumber:
            return "Invalid phone number format. Use E.164 format (e.g., +14155551234)"
        case .invalidURL:
            return "Invalid API URL"
        case .encodingError:
            return "Failed to encode request"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid response from server"
        case .serverError(let code, let message):
            return "Server error (\(code)): \(message)"
        case .twilioError(let message):
            return "Twilio error: \(message)"
        }
    }
}

// MARK: - Extension for AuthService

extension AuthService {
    /**
     Gets the current authentication token.

     - Returns: Current Firebase ID token if authenticated, nil otherwise

     - Note: This is a helper method to get the token for API requests.
     */
    func getCurrentToken() -> String? {
        return UserDefaults.standard.string(forKey: "firebaseToken")
    }
}
