//
//  ConfirmationView.swift
//  paro
//
//  View displaying order confirmation details
//

import SwiftUI

/**
 View that displays order confirmation with all order details.

 `ConfirmationView` presents a comprehensive summary of a successfully placed order.
 It shows the confirmation code, order details, pricing information, and delivery
 updates. Users can dismiss the view using the Done button to return to the main flow.

 ## Displayed Information
 - Confirmation code (6-digit)
 - Delivery platform name
 - Item name and customization
 - Price breakdown (base price and total)
 - Selected cuisines
 - Order status
 - Timestamp

 ## Layout
 The view uses responsive design with GeometryReader to adapt to different screen
 sizes. Text sizes scale proportionally while maintaining readability.

 - Important: Requires an Order object to be passed during initialization.

 ## Usage Example
 ```swift
 ConfirmationView(order: completedOrder)
 ```
 */
struct ConfirmationView: View {
    // MARK: - Properties

    /// The completed order to display
    let order: Order

    /// Environment property to dismiss the view
    @Environment(\.dismiss) private var dismiss

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 0) {

                // MARK: - Confirmation Code
                Text(order.confirmationCode)
                    .font(.system(size: min(geometry.size.width * 0.15, 80), weight: .black))
                    .foregroundColor(.black)
                    .padding(.top, geometry.size.height * 0.08)
                    .padding(.horizontal, 20)

                Spacer()
                    .frame(height: geometry.size.height * 0.06)

                // MARK: - Order Details Section
                orderDetailsSection(geometry: geometry)

                Spacer()
                    .frame(height: geometry.size.height * 0.08)

                // MARK: - Total Price
                if let totalPrice = order.totalPrice {
                    Text("After \(order.platform ?? "delivery"): $\(String(format: "%.2f", totalPrice))")
                        .font(.system(size: min(geometry.size.width * 0.08, 40), weight: .black))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)

                    Spacer()
                        .frame(height: geometry.size.height * 0.08)
                }

                // MARK: - Delivery Information
                VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
                    Text("Delivery updates will be sent over text")
                        .font(.system(size: min(geometry.size.width * 0.06, 30), weight: .medium))
                        .foregroundColor(.black)

                    Text("Order Status: \(order.status.rawValue)")
                        .font(.system(size: min(geometry.size.width * 0.05, 25), weight: .medium))
                        .foregroundColor(.gray)

                    Text("Order placed: \(formattedDate(order.timestamp))")
                        .font(.system(size: min(geometry.size.width * 0.05, 25), weight: .medium))
                        .foregroundColor(.gray)
                }
                .padding(.horizontal, 20)

                Spacer()

                // MARK: - Done Button
                doneButton(geometry: geometry)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .toolbar(.hidden, for: .navigationBar)
        .ignoresSafeArea()
        .background(Color.white)
    }

    // MARK: - View Components

    /**
     Creates the order details section.

     Displays all relevant order information including platform, item name,
     customization options, pricing, and selected cuisines. Each field is
     conditionally rendered based on availability.

     - Parameter geometry: Geometry proxy for responsive sizing

     - Returns: A view containing order details

     ## Displayed Fields
     - Platform name (e.g., "Uber Eats")
     - Item name (e.g., "Pad Thai Noodles")
     - Customization details (e.g., "Extra cheese")
     - Base price
     - Selected cuisines list
     */
    private func orderDetailsSection(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {

            // Platform name
            if let platform = order.platform {
                Text(platform)
                    .font(.system(size: min(geometry.size.width * 0.08, 40), weight: .black))
                    .foregroundColor(.black)
            }

            // Item name
            if let itemName = order.itemName {
                Text(itemName)
                    .font(.system(size: min(geometry.size.width * 0.08, 40), weight: .black))
                    .foregroundColor(.black)
            }

            // Customization details
            if let customization = order.customization {
                Text(customization)
                    .font(.system(size: min(geometry.size.width * 0.06, 30), weight: .medium))
                    .foregroundColor(.black)
            }

            // Base price
            if let price = order.price {
                Text("Price: $\(String(format: "%.2f", price))")
                    .font(.system(size: min(geometry.size.width * 0.06, 30), weight: .medium))
                    .foregroundColor(.black)
            }

            // Selected cuisines
            if !order.cuisines.isEmpty {
                Text("Cuisines: \(order.cuisines.joined(separator: ", "))")
                    .font(.system(size: min(geometry.size.width * 0.05, 25), weight: .medium))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 20)
    }

    /**
     Creates the done button to dismiss the view.

     Generates a full-width button at the bottom of the screen that allows
     users to return to the previous screen. The button has a black background
     with white text for high visibility.

     - Parameter geometry: Geometry proxy for responsive sizing

     - Returns: A configured done button

     - Note: Dismissing this view will return to the CuisineSelectionView.
     */
    private func doneButton(geometry: GeometryProxy) -> some View {
        Button(action: {
            // Dismiss both the confirmation view and the cuisine selection view
            dismiss()
        }) {
            Text("Done")
                .font(.system(size: min(geometry.size.width * 0.08, 40), weight: .black))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: geometry.size.height * 0.08)
                .background(Color.black)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.bottom, geometry.size.height * 0.05)
    }

    // MARK: - Helper Methods

    /**
     Formats a date into a readable string.

     Converts a Date object into a user-friendly string representation
     showing both the date and time in the user's locale.

     - Parameter date: The date to format

     - Returns: A formatted date string (e.g., "Jan 15, 2025 at 2:30 PM")

     - Note: Uses medium date style and short time style.
     */
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Preview

#Preview {
    // Create a sample order for preview
    var sampleOrder = Order(cuisines: ["Thai", "Italian"])
    sampleOrder.platform = "Uber Eats"
    sampleOrder.itemName = "Pad Thai Noodles"
    sampleOrder.customization = "Choice of Protein: Vegetables"
    sampleOrder.price = 13.95
    sampleOrder.totalPrice = 23.80
    sampleOrder.status = .submitted

    return ConfirmationView(order: sampleOrder)
}
