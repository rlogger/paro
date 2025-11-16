//
//  KeychainHelperTests.swift
//  eaterTests
//
//  Unit tests for KeychainHelper
//

import XCTest
@testable import eater

/**
 Tests for KeychainHelper functionality.

 Verifies secure storage, retrieval, and deletion of keychain items.
 */
final class KeychainHelperTests: XCTestCase {

    var keychainHelper: KeychainHelper!
    let testKey = "testKey"
    let testValue = "testValue"

    override func setUpWithError() throws {
        keychainHelper = KeychainHelper.shared
        // Clean up any existing test data
        keychainHelper.delete(forKey: testKey)
    }

    override func tearDownWithError() throws {
        // Clean up after each test
        keychainHelper.delete(forKey: testKey)
        keychainHelper = nil
    }

    // MARK: - Service Initialization Tests

    func testKeychainHelperSingleton() throws {
        // Given
        let helper1 = KeychainHelper.shared
        let helper2 = KeychainHelper.shared

        // Then
        XCTAssertTrue(helper1 === helper2, "KeychainHelper should be a singleton")
    }

    // MARK: - Save Tests

    func testSaveValue() throws {
        // When
        let success = keychainHelper.save(testValue, forKey: testKey)

        // Then
        XCTAssertTrue(success, "Save should succeed")
    }

    func testSaveOverwritesExistingValue() throws {
        // Given: Save initial value
        _ = keychainHelper.save("initialValue", forKey: testKey)

        // When: Save new value with same key
        let success = keychainHelper.save(testValue, forKey: testKey)

        // Then
        XCTAssertTrue(success, "Overwrite should succeed")

        let retrieved = keychainHelper.get(forKey: testKey)
        XCTAssertEqual(retrieved, testValue, "Should retrieve new value")
    }

    // MARK: - Retrieve Tests

    func testGetValue() throws {
        // Given
        _ = keychainHelper.save(testValue, forKey: testKey)

        // When
        let retrieved = keychainHelper.get(forKey: testKey)

        // Then
        XCTAssertEqual(retrieved, testValue, "Retrieved value should match saved value")
    }

    func testGetNonExistentValue() throws {
        // When
        let retrieved = keychainHelper.get(forKey: "nonExistentKey")

        // Then
        XCTAssertNil(retrieved, "Should return nil for non-existent key")
    }

    // MARK: - Delete Tests

    func testDeleteValue() throws {
        // Given: Save a value
        _ = keychainHelper.save(testValue, forKey: testKey)

        // When: Delete the value
        let success = keychainHelper.delete(forKey: testKey)

        // Then
        XCTAssertTrue(success, "Delete should succeed")

        let retrieved = keychainHelper.get(forKey: testKey)
        XCTAssertNil(retrieved, "Value should be nil after deletion")
    }

    func testDeleteNonExistentValue() throws {
        // When: Delete non-existent value
        let success = keychainHelper.delete(forKey: "nonExistentKey")

        // Then: Should still return true (delete of non-existent is success)
        XCTAssertTrue(success, "Delete of non-existent should succeed")
    }

    // MARK: - Exists Tests

    func testExistsForSavedValue() throws {
        // Given
        _ = keychainHelper.save(testValue, forKey: testKey)

        // When
        let exists = keychainHelper.exists(forKey: testKey)

        // Then
        XCTAssertTrue(exists, "Should return true for saved value")
    }

    func testExistsForNonExistentValue() throws {
        // When
        let exists = keychainHelper.exists(forKey: "nonExistentKey")

        // Then
        XCTAssertFalse(exists, "Should return false for non-existent value")
    }

    // MARK: - Multiple Keys Tests

    func testSaveMultipleKeys() throws {
        // Given
        let key1 = "key1"
        let key2 = "key2"
        let value1 = "value1"
        let value2 = "value2"

        // When
        _ = keychainHelper.save(value1, forKey: key1)
        _ = keychainHelper.save(value2, forKey: key2)

        // Then
        XCTAssertEqual(keychainHelper.get(forKey: key1), value1, "Should retrieve first value")
        XCTAssertEqual(keychainHelper.get(forKey: key2), value2, "Should retrieve second value")

        // Cleanup
        keychainHelper.delete(forKey: key1)
        keychainHelper.delete(forKey: key2)
    }
}
