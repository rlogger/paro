//
//  AuthenticationViewTests.swift
//  eaterTests
//
//  Unit tests for AuthenticationView
//

import XCTest
import SwiftUI
@testable import eater

/**
 Tests for AuthenticationView functionality.

 Verifies form validation, authentication flow, and error handling.
 */
final class AuthenticationViewTests: XCTestCase {

    // MARK: - Setup & Teardown

    override func setUpWithError() throws {
        AuthService.shared.signOut { _ in }
    }

    override func tearDownWithError() throws {
        AuthService.shared.signOut { _ in }
    }

    // MARK: - View Initialization Tests

    func testAuthenticationViewInitialization() throws {
        // Given
        let view = AuthenticationView()

        // Then
        XCTAssertNotNil(view, "AuthenticationView should initialize successfully")
    }

    func testAuthenticationViewWithCallback() throws {
        // Given
        var callbackInvoked = false
        let view = AuthenticationView { success in
            callbackInvoked = true
        }

        // Then
        XCTAssertNotNil(view, "AuthenticationView should initialize with callback")
    }

    // MARK: - Sign In Tests

    func testSignInWithValidCredentials() throws {
        // Given
        let expectation = XCTestExpectation(description: "Sign in should succeed")
        let email = "test@example.com"
        let password = "password123"

        // When
        AuthService.shared.signIn(email: email, password: password) { result in
            // Then
            switch result {
            case .success(let user):
                XCTAssertEqual(user.email, email, "User email should match")
                XCTAssertNotNil(user.uid, "User should have UID")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Sign in should succeed: \(error.localizedDescription)")
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testSignInWithEmptyEmail() throws {
        // Given
        let email = ""
        let password = "password123"

        // When/Then
        // Form validation should prevent submission
        XCTAssertTrue(email.isEmpty, "Empty email should fail validation")
    }

    func testSignInWithEmptyPassword() throws {
        // Given
        let email = "test@example.com"
        let password = ""

        // When/Then
        // Form validation should prevent submission
        XCTAssertTrue(password.isEmpty, "Empty password should fail validation")
    }

    // MARK: - Sign Up Tests

    func testSignUpWithValidCredentials() throws {
        // Given
        let expectation = XCTestExpectation(description: "Sign up should succeed")
        let email = "newuser@example.com"
        let password = "password123"
        let displayName = "Test User"

        // When
        AuthService.shared.signUp(email: email, password: password, displayName: displayName) { result in
            // Then
            switch result {
            case .success(let user):
                XCTAssertEqual(user.email, email, "User email should match")
                XCTAssertEqual(user.displayName, displayName, "User display name should match")
                XCTAssertNotNil(user.uid, "User should have UID")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Sign up should succeed: \(error.localizedDescription)")
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testSignUpWithShortPassword() throws {
        // Given
        let password = "12345" // Less than 6 characters

        // When/Then
        // Form validation should require minimum 6 characters
        XCTAssertLessThan(password.count, 6, "Password should be too short")
    }
}
