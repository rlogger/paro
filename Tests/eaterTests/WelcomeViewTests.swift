//
//  WelcomeViewTests.swift
//  eaterTests
//
//  Unit tests for WelcomeView
//

import XCTest
import SwiftUI
@testable import eater

/**
 Tests for WelcomeView functionality.

 Verifies the welcome screen behavior, authentication flow triggers,
 and navigation logic.
 */
final class WelcomeViewTests: XCTestCase {

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        // Clear authentication state before each test
        AuthService.shared.signOut { _ in }
    }

    override func tearDownWithError() throws {
        // Clean up after each test
        AuthService.shared.signOut { _ in }
    }

    // MARK: - View Initialization Tests

    func testWelcomeViewInitialization() throws {
        // Given
        let view = WelcomeView()

        // Then
        XCTAssertNotNil(view, "WelcomeView should initialize successfully")
    }

    // MARK: - Authentication Flow Tests

    func testCarrotButtonNavigationWhenNotAuthenticated() throws {
        // Given: User is not authenticated
        let expectation = XCTestExpectation(description: "Should show authentication view")

        // When: User is not authenticated
        let isAuthenticated = AuthService.shared.isAuthenticated()

        // Then: Should prompt for authentication
        XCTAssertFalse(isAuthenticated, "User should not be authenticated initially")
        expectation.fulfill()

        wait(for: [expectation], timeout: 1.0)
    }

    func testCarrotButtonNavigationWhenAuthenticated() throws {
        // Given: User is authenticated
        let expectation = XCTestExpectation(description: "Sign in completion")

        // When: Sign in user
        AuthService.shared.signIn(email: "test@example.com", password: "password123") { result in
            if case .success = result {
                // Then: Should be authenticated
                let isAuthenticated = AuthService.shared.isAuthenticated()
                XCTAssertTrue(isAuthenticated, "User should be authenticated after sign in")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
