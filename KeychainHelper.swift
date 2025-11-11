//
//  KeychainHelper.swift
//  eater
//
//  Secure storage for authentication tokens using iOS Keychain
//

import Foundation
import Security

/**
 Helper class for securely storing and retrieving data from iOS Keychain.

 Much more secure than cookies or UserDefaults for storing authentication tokens.
 Keychain data persists across app deletions and device restarts.

 ## Why Keychain Instead of Cookies?

 iOS apps don't use cookies like web apps. Instead, iOS provides Keychain Services:
 - ✅ **Encrypted storage** - Data is encrypted automatically
 - ✅ **Persistent** - Survives app deletions and OS updates
 - ✅ **Secure** - Protected by device passcode/biometrics
 - ✅ **Private** - Only your app can access its keychain items
 - ✅ **No expiration** - Tokens stay until explicitly deleted

 Cookies are for web/HTTP, Keychain is the iOS-native solution.

 ## Usage
 ```swift
 // Save token
 KeychainHelper.shared.save("my-auth-token", forKey: "firebaseToken")

 // Retrieve token
 if let token = KeychainHelper.shared.get(forKey: "firebaseToken") {
     print("Token: \(token)")
 }

 // Delete token (on sign out)
 KeychainHelper.shared.delete(forKey: "firebaseToken")
 ```

 - Note: Tokens stored in Keychain keep users logged in between app launches.
 */
class KeychainHelper {
    // MARK: - Properties

    /// Shared singleton instance
    static let shared = KeychainHelper()

    /// Service identifier for keychain items
    private let service = "com.eater.app"

    // MARK: - Initialization

    /**
     Private initializer for singleton pattern.
     */
    private init() {}

    // MARK: - Public Methods

    /**
     Saves a string value to the Keychain.

     - Parameters:
       - value: The string value to store
       - key: The key to store it under

     - Returns: true if successful, false otherwise

     ## Example
     ```swift
     let success = KeychainHelper.shared.save("my-token-123", forKey: "authToken")
     if success {
         print("Token saved securely")
     }
     ```
     */
    @discardableResult
    func save(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else {
            return false
        }

        // Delete any existing item with this key first
        delete(forKey: key)

        // Create query for adding new item
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        // Add to keychain
        let status = SecItemAdd(query as CFDictionary, nil)

        return status == errSecSuccess
    }

    /**
     Retrieves a string value from the Keychain.

     - Parameter key: The key to retrieve

     - Returns: The stored string value, or nil if not found

     ## Example
     ```swift
     if let token = KeychainHelper.shared.get(forKey: "authToken") {
         print("Retrieved token: \(token)")
     } else {
         print("No token found")
     }
     ```
     */
    func get(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    /**
     Deletes a value from the Keychain.

     - Parameter key: The key to delete

     - Returns: true if successful, false otherwise

     ## Example
     ```swift
     let success = KeychainHelper.shared.delete(forKey: "authToken")
     if success {
         print("Token deleted")
     }
     ```
     */
    @discardableResult
    func delete(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        return status == errSecSuccess || status == errSecItemNotFound
    }

    /**
     Deletes all keychain items for this app.

     Useful for complete sign out or app reset.

     - Returns: true if successful, false otherwise

     ## Example
     ```swift
     KeychainHelper.shared.deleteAll()
     print("All keychain data cleared")
     ```

     - Warning: This will delete ALL keychain items for this app.
     */
    @discardableResult
    func deleteAll() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]

        let status = SecItemDelete(query as CFDictionary)

        return status == errSecSuccess || status == errSecItemNotFound
    }

    /**
     Checks if a value exists in the Keychain.

     - Parameter key: The key to check

     - Returns: true if exists, false otherwise

     ## Example
     ```swift
     if KeychainHelper.shared.exists(forKey: "authToken") {
         print("User has saved token")
     }
     ```
     */
    func exists(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: false
        ]

        let status = SecItemCopyMatching(query as CFDictionary, nil)

        return status == errSecSuccess
    }
}

// MARK: - Migration Helper

extension KeychainHelper {
    /**
     Migrates tokens from UserDefaults to Keychain.

     Call this once to migrate existing tokens to secure storage.

     ## Example
     ```swift
     KeychainHelper.shared.migrateFromUserDefaults()
     ```
     */
    func migrateFromUserDefaults() {
        let keys = ["firebaseToken", "userId"]

        for key in keys {
            if let value = UserDefaults.standard.string(forKey: key) {
                // Save to Keychain
                save(value, forKey: key)

                // Remove from UserDefaults
                UserDefaults.standard.removeObject(forKey: key)

                print("✅ Migrated \(key) from UserDefaults to Keychain")
            }
        }
    }
}
