//
//  AuthServiceTests.swift
//  eaterTests
//
//  Unit tests for AuthService
//

import XCTest
@testable import eater

/**
 Tests for AuthService functionality.

 Verifies authentication, sign-in/sign-up, token management, and session handling.
 */
final class AuthServiceTests: XCTestCase {

    var authService: AuthService!

    override func setUpWithError() throws {
        authService = AuthService.shared
        // Sign out before each test
        authService.signOut { _ in }
    }

    override func tearDownWithError() throws {
        // Clean up after each test
        authService.signOut { _ in }
        authService = nil
    }

    // MARK: - Service Initialization Tests

    func testAuthServiceSingleton() throws {
        // Given
        let service1 = AuthService.shared
        let service2 = AuthService.shared

        // Then
        XCTAssertTrue(service1 === service2, "AuthService should be a singleton")
    }

    // MARK: - Sign In Tests

    func testSignInWithValidCredentials() throws {
        // Given
        let expectation = XCTestExpectation(description: "Sign in should succeed")
        let email = "test@example.com"
        let password = "password123"

        // When
        authService.signIn(email: email, password: password) { result in
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

    func testSignInSetsAuthenticationState() throws {
        // Given
        let expectation = XCTestExpectation(description: "Authentication state should be set")

        // When
        authService.signIn(email: "test@example.com", password: "password123") { result in
            if case .success = result {
                // Then
                let isAuthenticated = self.authService.isAuthenticated()
                XCTAssertTrue(isAuthenticated, "User should be authenticated after sign in")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Sign Up Tests

    func testSignUpWithValidCredentials() throws {
        // Given
        let expectation = XCTestExpectation(description: "Sign up should succeed")
        let email = "newuser@example.com"
        let password = "password123"
        let displayName = "New User"

        // When
        authService.signUp(email: email, password: password, displayName: displayName) { result in
            // Then
            switch result {
            case .success(let user):
                XCTAssertEqual(user.email, email, "User email should match")
                XCTAssertEqual(user.displayName, displayName, "Display name should match")
                XCTAssertNotNil(user.uid, "User should have UID")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Sign up should succeed: \(error.localizedDescription)")
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }

    func testSignUpSetsAuthenticationState() throws {
        // Given
        let expectation = XCTestExpectation(description: "Authentication state should be set after sign up")

        // When
        authService.signUp(email: "test@example.com", password: "password123") { result in
            if case .success = result {
                // Then
                let isAuthenticated = self.authService.isAuthenticated()
                XCTAssertTrue(isAuthenticated, "User should be authenticated after sign up")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }

    // MARK: - Sign Out Tests

    func testSignOut() throws {
        // Given: User is signed in
        let signInExpectation = XCTestExpectation(description: "Sign in first")

        authService.signIn(email: "test@example.com", password: "password123") { result in
            if case .success = result {
                signInExpectation.fulfill()
            }
        }

        wait(for: [signInExpectation], timeout: 2.0)

        // When: Sign out
        let signOutExpectation = XCTestExpectation(description: "Sign out should succeed")

        authService.signOut { result in
            // Then
            if case .success = result {
                let isAuthenticated = self.authService.isAuthenticated()
                XCTAssertFalse(isAuthenticated, "User should not be authenticated after sign out")
                signOutExpectation.fulfill()
            } else {
                XCTFail("Sign out should succeed")
            }
        }

        wait(for: [signOutExpectation], timeout: 2.0)
    }

    // MARK: - Authentication State Tests

    func testIsAuthenticatedWhenSignedOut() throws {
        // Given: User is signed out
        authService.signOut { _ in }

        // Then
        let isAuthenticated = authService.isAuthenticated()
        XCTAssertFalse(isAuthenticated, "User should not be authenticated when signed out")
    }

    func testGetCurrentUserWhenSignedOut() throws {
        // Given: User is signed out
        authService.signOut { _ in }

        // When
        let currentUser = authService.getCurrentUser()

        // Then
        XCTAssertNil(currentUser, "Should return nil when no user is signed in")
    }

    func testGetCurrentUserWhenSignedIn() throws {
        // Given: User is signed in
        let expectation = XCTestExpectation(description: "Get current user after sign in")

        authService.signIn(email: "test@example.com", password: "password123") { result in
            if case .success = result {
                // When
                let currentUser = self.authService.getCurrentUser()

                // Then
                XCTAssertNotNil(currentUser, "Should return user when signed in")
                XCTAssertNotNil(currentUser?.uid, "User should have UID")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 2.0)
    }
}
