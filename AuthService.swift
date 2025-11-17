//
//  AuthService.swift
//  eater
//
//  Firebase authentication service for user management
//

import Foundation

/**
 Service class for handling Firebase authentication.

 `AuthService` provides a centralized interface for all Firebase authentication
 operations including sign-in, sign-out, token management, and user session handling.

 - Important: Uses the singleton pattern. Access via `AuthService.shared`.

 ## Features
 - Email/password authentication
 - Google Sign-In support
 - Apple Sign-In support
 - Phone authentication
 - Secure token storage
 - Automatic token refresh

 ## Prerequisites
 Before using this service, you must:
 1. Add Firebase to your iOS project
 2. Download GoogleService-Info.plist from Firebase Console
 3. Add GoogleService-Info.plist to your Xcode project
 4. Install Firebase SDK via Swift Package Manager:
    - FirebaseAuth
    - FirebaseCore
 5. Initialize Firebase in your App struct

 ## Usage Example
 ```swift
 // In eaterApp.swift
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

 // Sign in with email
 AuthService.shared.signIn(email: "user@example.com", password: "password") { result in
     switch result {
     case .success(let user):
         print("Signed in: \(user.uid)")
     case .failure(let error):
         print("Error: \(error.localizedDescription)")
     }
 }
 ```

 ## Installation Steps
 1. Add Firebase SDK to your project:
    - In Xcode: File → Add Package Dependencies
    - URL: https://github.com/firebase/firebase-ios-sdk
    - Add: FirebaseAuth, FirebaseCore

 2. Download GoogleService-Info.plist:
    - Go to Firebase Console (https://console.firebase.google.com)
    - Select your project
    - Go to Project Settings → iOS app
    - Download GoogleService-Info.plist
    - Add to Xcode project root

 3. Uncomment the Firebase import statements in this file
 4. Uncomment the implementation code below
 5. Call FirebaseApp.configure() in your app's init

 - Note: This file is currently configured with placeholder implementations.
         Uncomment Firebase-specific code once Firebase SDK is installed.
 */
class AuthService {
    // MARK: - Properties

    /// Shared singleton instance
    static let shared = AuthService()

    /// Key for storing Firebase token in UserDefaults
    /// TODO: Move to Keychain for production
    private let tokenKey = "firebaseToken"

    /// Key for storing user ID
    private let userIdKey = "userId"

    // MARK: - Initialization

    /**
     Private initializer for singleton pattern.
     */
    private init() {
        // Initialize any required state
    }

    // MARK: - Authentication Methods

    /**
     Signs in a user with email and password.

     This method authenticates the user with Firebase using email/password credentials.
     On success, it stores the Firebase ID token for subsequent API calls.

     - Parameters:
       - email: User's email address
       - password: User's password
       - completion: Completion handler with Result containing User or AuthError

     - Note: Requires Firebase Authentication to be set up with Email/Password provider enabled.

     ## Example
     ```swift
     AuthService.shared.signIn(email: "user@example.com", password: "password123") { result in
         switch result {
         case .success(let user):
             print("Welcome, \(user.email ?? "User")!")
         case .failure(let error):
             print("Sign in failed: \(error.localizedDescription)")
         }
     }
     ```
     */
    func signIn(email: String, password: String, completion: @escaping (Result<User, AuthError>) -> Void) {
        // TODO: Uncomment when Firebase SDK is installed
        /*
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                completion(.failure(.authenticationFailed(error.localizedDescription)))
                return
            }

            guard let firebaseUser = authResult?.user else {
                completion(.failure(.unknownError))
                return
            }

            // Get ID token
            firebaseUser.getIDToken { token, error in
                if let error = error {
                    completion(.failure(.tokenError(error.localizedDescription)))
                    return
                }

                if let token = token {
                    self?.saveToken(token)
                    self?.saveUserId(firebaseUser.uid)

                    let user = User(
                        uid: firebaseUser.uid,
                        email: firebaseUser.email,
                        displayName: firebaseUser.displayName
                    )
                    completion(.success(user))
                }
            }
        }
        */

        // DEMO MODE: Accept any email/password for demo purposes
        // This allows the app to work without Firebase configuration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            // Create demo user with provided email
            let displayName = email.components(separatedBy: "@").first?.capitalized ?? "Demo User"
            let mockUser = User(
                uid: "demo_\(UUID().uuidString.prefix(8))",
                email: email,
                displayName: displayName,
                phoneNumber: "+14155551234"
            )

            // Save demo token and user ID
            self.saveToken("demo_token_\(UUID().uuidString)")
            self.saveUserId(mockUser.uid)

            print("✅ DEMO MODE: Signed in as \(displayName)")
            completion(.success(mockUser))
        }
    }

    /**
     Creates a new user account with email and password.

     Registers a new user in Firebase Authentication and automatically signs them in.

     - Parameters:
       - email: Desired email address
       - password: Desired password (minimum 6 characters)
       - displayName: Optional display name for the user
       - completion: Completion handler with Result containing User or AuthError

     ## Example
     ```swift
     AuthService.shared.signUp(
         email: "newuser@example.com",
         password: "securepass123",
         displayName: "John Doe"
     ) { result in
         // Handle result
     }
     ```
     */
    func signUp(
        email: String,
        password: String,
        displayName: String? = nil,
        completion: @escaping (Result<User, AuthError>) -> Void
    ) {
        // TODO: Uncomment when Firebase SDK is installed
        /*
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                completion(.failure(.authenticationFailed(error.localizedDescription)))
                return
            }

            guard let firebaseUser = authResult?.user else {
                completion(.failure(.unknownError))
                return
            }

            // Update display name if provided
            if let displayName = displayName {
                let changeRequest = firebaseUser.createProfileChangeRequest()
                changeRequest.displayName = displayName
                changeRequest.commitChanges { error in
                    if let error = error {
                        print("Failed to update display name: \(error)")
                    }
                }
            }

            // Get ID token and complete
            firebaseUser.getIDToken { token, error in
                if let error = error {
                    completion(.failure(.tokenError(error.localizedDescription)))
                    return
                }

                if let token = token {
                    self?.saveToken(token)
                    self?.saveUserId(firebaseUser.uid)

                    let user = User(
                        uid: firebaseUser.uid,
                        email: firebaseUser.email,
                        displayName: firebaseUser.displayName ?? displayName
                    )
                    completion(.success(user))
                }
            }
        }
        */

        // DEMO MODE: Accept any sign up for demo purposes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            let mockUser = User(
                uid: "demo_\(UUID().uuidString.prefix(8))",
                email: email,
                displayName: displayName ?? "Demo User",
                phoneNumber: "+14155551234"
            )

            // Save demo token and user ID
            self.saveToken("demo_token_\(UUID().uuidString)")
            self.saveUserId(mockUser.uid)

            print("✅ DEMO MODE: Created account for \(displayName ?? "Demo User")")
            completion(.success(mockUser))
        }
    }

    // MARK: - SMS Authentication (Twilio)

    /**
     Initiates SMS authentication by sending a verification code.

     Sends a 6-digit verification code to the user's phone number via SMS.
     The code is valid for 10 minutes and can be used to verify phone ownership.

     - Parameters:
       - phoneNumber: User's phone number in E.164 format (e.g., +14155551234)
       - completion: Completion handler with Result containing verification ID or AuthError

     ## Authentication Flow
     1. User enters phone number
     2. App calls this method to send verification code
     3. Backend generates code and sends via Twilio
     4. User receives SMS with code
     5. User enters code in app
     6. App calls `verifyPhoneCode()` to complete authentication

     ## Example
     ```swift
     AuthService.shared.sendPhoneVerification(phoneNumber: "+14155551234") { result in
         switch result {
         case .success(let verificationId):
             print("Code sent! Verification ID: \(verificationId)")
             // Show code entry screen
         case .failure(let error):
             print("Error: \(error)")
         }
     }
     ```

     - Important: Phone number must be in E.164 format (+[country code][number])
     - Note: This method communicates with your backend, which then uses Twilio API
     */
    func sendPhoneVerification(
        phoneNumber: String,
        completion: @escaping (Result<String, AuthError>) -> Void
    ) {
        // Validate phone number format
        guard isValidPhoneNumber(phoneNumber) else {
            completion(.failure(.invalidPhoneNumber))
            return
        }

        // Create API request to backend
        guard let url = URL(string: "https://your-backend-server.com/api/auth/send-verification") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["phoneNumber": phoneNumber]

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(.authenticationFailed("Failed to encode request")))
            return
        }

        // Make API call to backend
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.authenticationFailed(error.localizedDescription)))
                    return
                }

                guard let data = data,
                      let json = try? JSONDecoder().decode([String: String].self, from: data),
                      let verificationId = json["verificationId"] else {
                    completion(.failure(.authenticationFailed("Invalid response")))
                    return
                }

                // Store verification ID for later use
                UserDefaults.standard.set(verificationId, forKey: "pendingVerificationId")
                UserDefaults.standard.set(phoneNumber, forKey: "pendingPhoneNumber")

                completion(.success(verificationId))
            }
        }.resume()

        // Placeholder for development (comment out when backend is ready)
        // DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //     let mockVerificationId = UUID().uuidString
        //     UserDefaults.standard.set(mockVerificationId, forKey: "pendingVerificationId")
        //     UserDefaults.standard.set(phoneNumber, forKey: "pendingPhoneNumber")
        //     completion(.success(mockVerificationId))
        // }
    }

    /**
     Verifies the SMS code and completes phone authentication.

     Validates the verification code entered by the user and creates/signs in the user account.

     - Parameters:
       - code: 6-digit verification code from SMS
       - completion: Completion handler with Result containing User or AuthError

     ## Example
     ```swift
     AuthService.shared.verifyPhoneCode(code: "123456") { result in
         switch result {
         case .success(let user):
             print("Phone verified! User: \(user.uid)")
             // Navigate to main app
         case .failure(let error):
             print("Invalid code: \(error)")
         }
     }
     ```

     - Important: Must be called after `sendPhoneVerification()`
     - Note: Code expires after 10 minutes
     */
    func verifyPhoneCode(
        code: String,
        completion: @escaping (Result<User, AuthError>) -> Void
    ) {
        // Get pending verification details
        guard let verificationId = UserDefaults.standard.string(forKey: "pendingVerificationId"),
              let phoneNumber = UserDefaults.standard.string(forKey: "pendingPhoneNumber") else {
            completion(.failure(.authenticationFailed("No pending verification")))
            return
        }

        // Validate code format (6 digits)
        guard code.count == 6, code.allSatisfy({ $0.isNumber }) else {
            completion(.failure(.invalidVerificationCode))
            return
        }

        // Create API request to backend
        guard let url = URL(string: "https://your-backend-server.com/api/auth/verify-phone") else {
            completion(.failure(.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = [
            "verificationId": verificationId,
            "code": code,
            "phoneNumber": phoneNumber
        ]

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            completion(.failure(.authenticationFailed("Failed to encode request")))
            return
        }

        // Make API call to backend
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.authenticationFailed(error.localizedDescription)))
                    return
                }

                guard let data = data,
                      let json = try? JSONDecoder().decode([String: String].self, from: data),
                      let token = json["token"],
                      let userId = json["userId"] else {
                    completion(.failure(.invalidVerificationCode))
                    return
                }

                // Clear pending verification
                UserDefaults.standard.removeObject(forKey: "pendingVerificationId")
                UserDefaults.standard.removeObject(forKey: "pendingPhoneNumber")

                // Save token and user info
                self?.saveToken(token)
                self?.saveUserId(userId)

                let user = User(
                    uid: userId,
                    email: nil,
                    displayName: nil,
                    phoneNumber: phoneNumber
                )

                completion(.success(user))
            }
        }.resume()

        // Placeholder for development (comment out when backend is ready)
        // DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //     // Mock successful verification
        //     UserDefaults.standard.removeObject(forKey: "pendingVerificationId")
        //     UserDefaults.standard.removeObject(forKey: "pendingPhoneNumber")
        //
        //     let mockUser = User(
        //         uid: "phone_user_\(UUID().uuidString)",
        //         email: nil,
        //         displayName: nil,
        //         phoneNumber: phoneNumber
        //     )
        //     self.saveToken("mock_phone_token_\(UUID().uuidString)")
        //     self.saveUserId(mockUser.uid)
        //     completion(.success(mockUser))
        // }
    }

    /**
     Validates phone number format.

     Checks if phone number is in E.164 format (+[country code][number]).

     - Parameter phoneNumber: Phone number to validate
     - Returns: true if valid E.164 format, false otherwise

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

    /**
     Signs out the current user.

     Clears the Firebase session and removes stored authentication tokens.

     - Parameter completion: Completion handler indicating success or failure

     ## Example
     ```swift
     AuthService.shared.signOut { result in
         if case .success = result {
             print("Signed out successfully")
         }
     }
     ```
     */
    func signOut(completion: @escaping (Result<Void, AuthError>) -> Void) {
        // TODO: Uncomment when Firebase SDK is installed
        /*
        do {
            try Auth.auth().signOut()
            clearToken()
            clearUserId()
            completion(.success(()))
        } catch {
            completion(.failure(.signOutFailed(error.localizedDescription)))
        }
        */

        // Placeholder implementation
        clearToken()
        clearUserId()
        completion(.success(()))
    }

    /**
     Gets the current authenticated user.

     Returns the currently signed-in user or nil if no user is authenticated.

     - Returns: Current User if authenticated, nil otherwise

     ## Example
     ```swift
     if let user = AuthService.shared.getCurrentUser() {
         print("Current user: \(user.email ?? "Unknown")")
     } else {
         print("No user signed in")
     }
     ```
     */
    func getCurrentUser() -> User? {
        // TODO: Uncomment when Firebase SDK is installed
        /*
        guard let firebaseUser = Auth.auth().currentUser else {
            return nil
        }

        return User(
            uid: firebaseUser.uid,
            email: firebaseUser.email,
            displayName: firebaseUser.displayName
        )
        */

        // Placeholder implementation
        guard let userId = getUserId(),
              let token = getToken() else {
            return nil
        }

        return User(
            uid: userId,
            email: "mock@example.com",
            displayName: "Mock User"
        )
    }

    /**
     Gets the current Firebase ID token.

     Retrieves the stored Firebase ID token, refreshing it if necessary.
     This token is used to authenticate API requests to the backend.

     - Parameter forceRefresh: If true, forces token refresh even if not expired
     - Parameter completion: Completion handler with Result containing token string or AuthError

     ## Example
     ```swift
     AuthService.shared.getIDToken(forceRefresh: false) { result in
         switch result {
         case .success(let token):
             // Use token for API call
             print("Token: \(token)")
         case .failure(let error):
             print("Token error: \(error)")
         }
     }
     ```
     */
    func getIDToken(forceRefresh: Bool = false, completion: @escaping (Result<String, AuthError>) -> Void) {
        // TODO: Uncomment when Firebase SDK is installed
        /*
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(.notAuthenticated))
            return
        }

        currentUser.getIDTokenForcingRefresh(forceRefresh) { [weak self] token, error in
            if let error = error {
                completion(.failure(.tokenError(error.localizedDescription)))
                return
            }

            if let token = token {
                self?.saveToken(token)
                completion(.success(token))
            } else {
                completion(.failure(.tokenError("No token available")))
            }
        }
        */

        // Placeholder implementation
        if let token = getToken() {
            completion(.success(token))
        } else {
            completion(.failure(.notAuthenticated))
        }
    }

    /**
     Checks if a user is currently authenticated.

     - Returns: true if user is signed in, false otherwise
     */
    func isAuthenticated() -> Bool {
        // TODO: Uncomment when Firebase SDK is installed
        // return Auth.auth().currentUser != nil

        // Placeholder implementation
        return getToken() != nil && getUserId() != nil
    }

    // MARK: - Token Management

    /**
     Saves the Firebase ID token securely to Keychain.

     - Parameter token: The Firebase ID token to save

     - Note: Uses Keychain for secure, persistent storage (better than cookies or UserDefaults).
             Tokens persist between app launches, keeping users logged in.
     */
    private func saveToken(_ token: String) {
        KeychainHelper.shared.save(token, forKey: tokenKey)
    }

    /**
     Retrieves the stored Firebase ID token from Keychain.

     - Returns: The Firebase ID token if available, nil otherwise
     */
    private func getToken() -> String? {
        return KeychainHelper.shared.get(forKey: tokenKey)
    }

    /**
     Clears the stored Firebase ID token from Keychain.
     */
    private func clearToken() {
        KeychainHelper.shared.delete(forKey: tokenKey)
    }

    /**
     Saves the user ID securely to Keychain.

     - Parameter userId: The user ID to save
     */
    private func saveUserId(_ userId: String) {
        KeychainHelper.shared.save(userId, forKey: userIdKey)
    }

    /**
     Retrieves the stored user ID from Keychain.

     - Returns: The user ID if available, nil otherwise
     */
    private func getUserId() -> String? {
        return KeychainHelper.shared.get(forKey: userIdKey)
    }

    /**
     Clears the stored user ID from Keychain.
     */
    private func clearUserId() {
        KeychainHelper.shared.delete(forKey: userIdKey)
    }
}

// MARK: - User Model

/**
 Represents a Firebase authenticated user.

 Contains basic user information retrieved from Firebase Authentication.
 */
struct User: Codable {
    /// Unique user identifier from Firebase
    let uid: String

    /// User's email address
    let email: String?

    /// User's display name
    let displayName: String?

    /// User's phone number (if using phone auth)
    var phoneNumber: String?

    /// URL to user's profile photo
    var photoURL: String?
}

// MARK: - Authentication Errors

/**
 Errors that can occur during authentication operations.

 Provides detailed error information for all authentication-related failures.
 */
enum AuthError: LocalizedError {
    /// User is not authenticated
    case notAuthenticated

    /// Authentication failed with a specific reason
    case authenticationFailed(String)

    /// Error retrieving or refreshing token
    case tokenError(String)

    /// Sign out operation failed
    case signOutFailed(String)

    /// Invalid credentials provided
    case invalidCredentials

    /// Invalid phone number format
    case invalidPhoneNumber

    /// Invalid verification code
    case invalidVerificationCode

    /// Invalid URL
    case invalidURL

    /// Unknown error occurred
    case unknownError

    /**
     User-friendly error description.

     - Returns: A descriptive error message string
     */
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You are not signed in. Please sign in to continue."
        case .authenticationFailed(let message):
            return "Authentication failed: \(message)"
        case .tokenError(let message):
            return "Token error: \(message)"
        case .signOutFailed(let message):
            return "Sign out failed: \(message)"
        case .invalidCredentials:
            return "Invalid email or password"
        case .invalidPhoneNumber:
            return "Invalid phone number. Please use E.164 format (e.g., +14155551234)"
        case .invalidVerificationCode:
            return "Invalid verification code. Please check and try again."
        case .invalidURL:
            return "Invalid API URL"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}
