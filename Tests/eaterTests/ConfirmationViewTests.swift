//
//  ConfirmationViewTests.swift
//  eaterTests
//
//  Unit tests for ConfirmationView
//

import XCTest
import SwiftUI
@testable import eater

/**
 Tests for ConfirmationView functionality.

 Verifies order confirmation display and data presentation.
 */
final class ConfirmationViewTests: XCTestCase {

    // MARK: - Test Data

    var sampleOrder: Order!

    override func setUpWithError() throws {
        // Create a sample order for testing
        var order = Order(cuisines: ["Thai", "Italian"])
        order.platform = "Uber Eats"
        order.itemName = "Pad Thai Noodles"
        order.customization = "Extra vegetables"
        order.price = 13.95
        order.totalPrice = 23.80
        order.status = .submitted

        sampleOrder = order
    }

    override func tearDownWithError() throws {
        sampleOrder = nil
    }

    // MARK: - View Initialization Tests

    func testConfirmationViewInitialization() throws {
        // Given
        let view = ConfirmationView(order: sampleOrder)

        // Then
        XCTAssertNotNil(view, "ConfirmationView should initialize successfully")
    }

    func testConfirmationViewWithOrder() throws {
        // Given
        let view = ConfirmationView(order: sampleOrder)

        // Then
        XCTAssertEqual(view.order.confirmationCode, sampleOrder.confirmationCode, "Should display correct confirmation code")
        XCTAssertEqual(view.order.platform, "Uber Eats", "Should display correct platform")
        XCTAssertEqual(view.order.itemName, "Pad Thai Noodles", "Should display correct item name")
    }

    // MARK: - Order Data Tests

    func testOrderConfirmationCode() throws {
        // Given
        let confirmationCode = sampleOrder.confirmationCode

        // Then
        XCTAssertEqual(confirmationCode.count, 6, "Confirmation code should be 6 digits")
        XCTAssertTrue(confirmationCode.allSatisfy { $0.isNumber }, "Confirmation code should be numeric")
    }

    func testOrderPlatformInformation() throws {
        // Then
        XCTAssertNotNil(sampleOrder.platform, "Order should have platform information")
        XCTAssertEqual(sampleOrder.platform, "Uber Eats", "Platform should be Uber Eats")
    }

    func testOrderPricingInformation() throws {
        // Then
        XCTAssertNotNil(sampleOrder.price, "Order should have base price")
        XCTAssertNotNil(sampleOrder.totalPrice, "Order should have total price")

        if let price = sampleOrder.price, let total = sampleOrder.totalPrice {
            XCTAssertGreaterThan(total, price, "Total price should be greater than base price (includes fees)")
        }
    }

    func testOrderStatusInformation() throws {
        // Then
        XCTAssertEqual(sampleOrder.status, .submitted, "New order should have submitted status")
    }

    func testOrderCuisinesList() throws {
        // Then
        XCTAssertEqual(sampleOrder.cuisines.count, 2, "Order should have 2 cuisines")
        XCTAssertTrue(sampleOrder.cuisines.contains("Thai"), "Should contain Thai")
        XCTAssertTrue(sampleOrder.cuisines.contains("Italian"), "Should contain Italian")
    }

    func testOrderTimestamp() throws {
        // Then
        XCTAssertNotNil(sampleOrder.timestamp, "Order should have timestamp")

        let now = Date()
        let difference = now.timeIntervalSince(sampleOrder.timestamp)

        // Order should have been created very recently (within 5 seconds)
        XCTAssertLessThan(difference, 5.0, "Order timestamp should be recent")
    }
}
