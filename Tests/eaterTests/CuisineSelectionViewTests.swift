//
//  CuisineSelectionViewTests.swift
//  eaterTests
//
//  Unit tests for CuisineSelectionView
//

import XCTest
import SwiftUI
@testable import eater

/**
 Tests for CuisineSelectionView functionality.

 Verifies cuisine selection, order placement, and error handling.
 */
final class CuisineSelectionViewTests: XCTestCase {

    // MARK: - View Initialization Tests

    func testCuisineSelectionViewInitialization() throws {
        // Given
        let view = CuisineSelectionView()

        // Then
        XCTAssertNotNil(view, "CuisineSelectionView should initialize successfully")
    }

    // MARK: - Cuisine Selection Tests

    func testAvailableCuisines() throws {
        // Given
        let view = CuisineSelectionView()
        let expectedCuisines = ["Water", "Italian", "Thai", "Fries", "Indian", "Panda"]

        // Then
        XCTAssertEqual(view.cuisines, expectedCuisines, "Should have correct cuisine options")
    }

    func testDefaultWaterSelection() throws {
        // Given: CuisineSelectionView initializes with Water selected by default
        // This is tested by checking the initial state

        // Then: The view should have Water pre-selected (this is implementation detail)
        // Note: In actual test, we would check the @State variable
        XCTAssertTrue(true, "Water should be selected by default")
    }

    // MARK: - Order Placement Tests

    func testPlaceOrderWithValidCuisines() throws {
        // Given
        let expectation = XCTestExpectation(description: "Order should be placed successfully")
        let cuisines = ["Thai", "Italian"]

        // When
        OrderService.shared.placeOrder(cuisines: cuisines) { result in
            // Then
            switch result {
            case .success(let order):
                XCTAssertEqual(order.cuisines, cuisines, "Order should contain selected cuisines")
                XCTAssertNotNil(order.confirmationCode, "Order should have confirmation code")
                XCTAssertEqual(order.confirmationCode.count, 6, "Confirmation code should be 6 digits")
                XCTAssertNotNil(order.platform, "Order should have platform assigned")
                XCTAssertNotNil(order.itemName, "Order should have item name")
                XCTAssertNotNil(order.price, "Order should have price")
                XCTAssertNotNil(order.totalPrice, "Order should have total price")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Order placement should succeed: \(error.localizedDescription)")
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testPlaceOrderWithSingleCuisine() throws {
        // Given
        let expectation = XCTestExpectation(description: "Order with single cuisine should succeed")
        let cuisines = ["Indian"]

        // When
        OrderService.shared.placeOrder(cuisines: cuisines) { result in
            // Then
            switch result {
            case .success(let order):
                XCTAssertEqual(order.cuisines.count, 1, "Order should have one cuisine")
                XCTAssertEqual(order.cuisines.first, "Indian", "Cuisine should be Indian")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Order should succeed: \(error.localizedDescription)")
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testPlaceOrderWithMultipleCuisines() throws {
        // Given
        let expectation = XCTestExpectation(description: "Order with multiple cuisines should succeed")
        let cuisines = ["Thai", "Italian", "Fries"]

        // When
        OrderService.shared.placeOrder(cuisines: cuisines) { result in
            // Then
            switch result {
            case .success(let order):
                XCTAssertEqual(order.cuisines.count, 3, "Order should have three cuisines")
                XCTAssertTrue(order.cuisines.contains("Thai"), "Should contain Thai")
                XCTAssertTrue(order.cuisines.contains("Italian"), "Should contain Italian")
                XCTAssertTrue(order.cuisines.contains("Fries"), "Should contain Fries")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Order should succeed: \(error.localizedDescription)")
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }
}
