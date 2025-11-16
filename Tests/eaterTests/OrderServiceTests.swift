//
//  OrderServiceTests.swift
//  eaterTests
//
//  Unit tests for OrderService
//

import XCTest
@testable import eater

/**
 Tests for OrderService functionality.

 Verifies order placement, API communication, and error handling.
 */
final class OrderServiceTests: XCTestCase {

    var orderService: OrderService!

    override func setUpWithError() throws {
        orderService = OrderService.shared
    }

    override func tearDownWithError() throws {
        orderService = nil
    }

    // MARK: - Service Initialization Tests

    func testOrderServiceSingleton() throws {
        // Given
        let service1 = OrderService.shared
        let service2 = OrderService.shared

        // Then
        XCTAssertTrue(service1 === service2, "OrderService should be a singleton")
    }

    // MARK: - Order Placement Tests

    func testPlaceOrderSuccess() throws {
        // Given
        let expectation = XCTestExpectation(description: "Order placement should succeed")
        let cuisines = ["Italian", "Thai"]

        // When
        orderService.placeOrder(cuisines: cuisines) { result in
            // Then
            switch result {
            case .success(let order):
                XCTAssertEqual(order.cuisines, cuisines, "Order should contain correct cuisines")
                XCTAssertNotNil(order.id, "Order should have ID")
                XCTAssertNotNil(order.confirmationCode, "Order should have confirmation code")
                XCTAssertEqual(order.status, .submitted, "Order status should be submitted")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Order should succeed: \(error.localizedDescription)")
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testPlaceOrderWithDeliveryAddress() throws {
        // Given
        let expectation = XCTestExpectation(description: "Order with address should succeed")
        let cuisines = ["Indian"]
        let address = "123 Main St, San Francisco, CA 94102"

        // When
        orderService.placeOrder(
            cuisines: cuisines,
            deliveryAddress: address
        ) { result in
            // Then
            switch result {
            case .success(let order):
                XCTAssertEqual(order.cuisines, cuisines, "Order should have correct cuisines")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Order should succeed: \(error.localizedDescription)")
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testPlaceOrderWithSpecialInstructions() throws {
        // Given
        let expectation = XCTestExpectation(description: "Order with instructions should succeed")
        let cuisines = ["Fries"]
        let instructions = "Ring doorbell, leave at door"

        // When
        orderService.placeOrder(
            cuisines: cuisines,
            specialInstructions: instructions
        ) { result in
            // Then
            switch result {
            case .success(let order):
                XCTAssertNotNil(order.confirmationCode, "Order should have confirmation code")
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Order should succeed: \(error.localizedDescription)")
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    // MARK: - Mock Data Tests

    func testMockOrderForItalian() throws {
        // Given
        let expectation = XCTestExpectation(description: "Italian order should have correct mock data")

        // When
        orderService.placeOrder(cuisines: ["Italian"]) { result in
            if case .success(let order) = result {
                // Then
                XCTAssertEqual(order.platform, "Uber Eats", "Italian should use Uber Eats")
                XCTAssertEqual(order.itemName, "Margherita Pizza", "Should be Margherita Pizza")
                XCTAssertNotNil(order.price, "Should have price")
                XCTAssertNotNil(order.totalPrice, "Should have total price")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testMockOrderForThai() throws {
        // Given
        let expectation = XCTestExpectation(description: "Thai order should have correct mock data")

        // When
        orderService.placeOrder(cuisines: ["Thai"]) { result in
            if case .success(let order) = result {
                // Then
                XCTAssertEqual(order.itemName, "Pad Thai Noodles", "Should be Pad Thai Noodles")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testMockOrderForIndian() throws {
        // Given
        let expectation = XCTestExpectation(description: "Indian order should have correct mock data")

        // When
        orderService.placeOrder(cuisines: ["Indian"]) { result in
            if case .success(let order) = result {
                // Then
                XCTAssertEqual(order.platform, "DoorDash", "Indian should use DoorDash")
                XCTAssertEqual(order.itemName, "Chicken Tikka Masala", "Should be Chicken Tikka Masala")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }

    func testMockOrderForWater() throws {
        // Given
        let expectation = XCTestExpectation(description: "Water order should have correct mock data")

        // When
        orderService.placeOrder(cuisines: ["Water"]) { result in
            if case .success(let order) = result {
                // Then
                XCTAssertEqual(order.itemName, "Premium Water Bottle", "Should be Premium Water Bottle")
                XCTAssertEqual(order.customization, "Sparkling", "Should be Sparkling")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 3.0)
    }
}
