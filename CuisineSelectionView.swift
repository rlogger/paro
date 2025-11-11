//
//  CuisineSelectionView.swift
//  eater
//
//  View for selecting cuisine types and placing orders
//

import SwiftUI

/**
 View that displays cuisine options and allows users to place orders.

 `CuisineSelectionView` presents a list of available cuisine types that users
 can select from. Users can choose multiple cuisines, and then place an order
 by tapping the Order button. The view handles the complete order flow including
 loading states, error handling, and navigation to the confirmation screen.

 ## Features
 - Multi-selection of cuisine types
 - Loading indicator during order placement
 - Error alerts with user-friendly messages
 - Smooth animations and transitions
 - Responsive design using GeometryReader

 ## User Flow
 1. User selects one or more cuisines
 2. User taps the Order button
 3. Loading overlay appears while processing
 4. On success: Navigate to ConfirmationView
 5. On error: Display error alert

 - Note: "Water" is auto-selected by default on view appearance.
 */
struct CuisineSelectionView: View {
    // MARK: - State Properties

    /// Set of currently selected cuisines
    @State private var selectedCuisines: Set<String> = ["Water"]

    /// Indicates whether the Order button has been pressed
    @State private var isOrderPressed = false

    /// Controls navigation to the confirmation view
    @State private var showConfirmation = false

    /// Stores the completed order
    @State private var completedOrder: Order?

    /// Indicates whether an order is currently being processed
    @State private var isLoading = false

    /// Stores error message if order fails
    @State private var errorMessage: String?

    /// Controls display of error alert
    @State private var showError = false

    /// Environment property to dismiss the view
    @Environment(\.dismiss) private var dismiss

    // MARK: - Constants

    /// Available cuisine options
    let cuisines = ["Water", "Italian", "Thai", "Fries", "Indian", "Panda"]

    // MARK: - Body

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main content
                VStack(spacing: 0) {
                    // MARK: - Cuisine Options
                    VStack(spacing: 0) {
                        ForEach(cuisines, id: \.self) { cuisine in
                            cuisineButton(for: cuisine, geometry: geometry)
                        }
                    }

                    // MARK: - Order Button
                    orderButton(geometry: geometry)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // MARK: - Loading Overlay
                if isLoading {
                    LoadingView()
                }
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea()
        .alert("Order Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
        .fullScreenCover(isPresented: $showConfirmation) {
            if let order = completedOrder {
                ConfirmationView(order: order)
            }
        }
    }

    // MARK: - View Components

    /**
     Creates a cuisine selection button.

     Generates a button for a specific cuisine type with appropriate styling
     based on selection state. Selected cuisines are displayed with white text
     on black background, while unselected ones use black text on clear background.

     - Parameters:
       - cuisine: The cuisine name
       - geometry: Geometry proxy for responsive sizing

     - Returns: A configured button view
     */
    private func cuisineButton(for cuisine: String, geometry: GeometryProxy) -> some View {
        Button(action: {
            toggleCuisineSelection(cuisine)
        }) {
            Text(cuisine)
                .font(.system(size: min(geometry.size.width * 0.12, 60), weight: .black))
                .foregroundColor(selectedCuisines.contains(cuisine) ? .white : .black)
                .frame(maxWidth: .infinity)
                .frame(height: geometry.size.height / 8)
                .background(
                    selectedCuisines.contains(cuisine) ? Color.black : Color.clear
                )
        }
        .buttonStyle(PlainButtonStyle())
    }

    /**
     Creates the order submission button.

     Generates the Order button with responsive sizing and dynamic styling
     based on the loading and pressed states. The button is disabled during
     loading or when no cuisines are selected.

     - Parameter geometry: Geometry proxy for responsive sizing

     - Returns: A configured order button
     */
    private func orderButton(geometry: GeometryProxy) -> some View {
        Button(action: {
            handleOrderButtonPress()
        }) {
            Text(isLoading ? "Ordering..." : "Order")
                .font(.system(size: min(geometry.size.width * 0.12, 60), weight: .black))
                .foregroundColor(isOrderPressed ? .white : .black)
                .frame(maxWidth: .infinity)
                .frame(height: geometry.size.height / 8)
                .background(isOrderPressed ? Color.green : Color.clear)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading || selectedCuisines.isEmpty)
    }

    // MARK: - Actions

    /**
     Toggles the selection state of a cuisine.

     Adds or removes the cuisine from the selected cuisines set based on
     its current selection state.

     - Parameter cuisine: The cuisine to toggle
     */
    private func toggleCuisineSelection(_ cuisine: String) {
        if selectedCuisines.contains(cuisine) {
            selectedCuisines.remove(cuisine)
        } else {
            selectedCuisines.insert(cuisine)
        }
    }

    /**
     Handles the order button press with animation and API call.

     Orchestrates the complete order flow:
     1. Validates that at least one cuisine is selected
     2. Triggers button press animation
     3. Enables loading state
     4. Initiates the order placement

     This method provides visual feedback and ensures proper state management
     throughout the order process.
     */
    private func handleOrderButtonPress() {
        // Validate selection
        guard !selectedCuisines.isEmpty else {
            return
        }

        // Trigger button press animation
        withAnimation(.easeInOut(duration: 0.15)) {
            isOrderPressed = true
        }

        // Reset animation after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.15)) {
                isOrderPressed = false
            }
        }

        // Start loading state
        isLoading = true

        // Place the order
        placeOrder()
    }

    /**
     Places the order using the OrderService.

     Communicates with the backend API through OrderService to place the order.
     Handles both success and failure scenarios, updating the UI accordingly.

     - On Success: Stores the order and navigates to ConfirmationView
     - On Failure: Displays an error alert with the error description

     - Important: All UI updates are performed on the main queue.
     */
    private func placeOrder() {
        let cuisineArray = Array(selectedCuisines)

        print("📱 Placing order for cuisines: \(cuisineArray)")

        OrderService.shared.placeOrder(cuisines: cuisineArray) { result in
            DispatchQueue.main.async {
                // End loading state
                isLoading = false

                switch result {
                case .success(let order):
                    print("✅ Order placed successfully: \(order.confirmationCode)")
                    // Store the order and show confirmation
                    completedOrder = order
                    showConfirmation = true

                case .failure(let error):
                    print("❌ Order failed: \(error.localizedDescription)")
                    // Show error to user
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// MARK: - Loading View

/**
 Displays a loading indicator overlay.

 A semi-transparent overlay that appears during order processing. Shows a
 spinner and informative text to indicate that the order is being placed.

 ## Visual Design
 - Semi-transparent black background
 - Centered loading spinner
 - "Placing your order..." text
 - Rounded corners for modern appearance
 */
private struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))

                Text("Placing your order...")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(Color.black.opacity(0.8))
            .cornerRadius(20)
        }
    }
}

// MARK: - Preview

#Preview {
    CuisineSelectionView()
}
