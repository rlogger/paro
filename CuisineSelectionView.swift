//
//  CuisineSelectionView.swift
//  eater
//
//  View for selecting cuisine types and placing orders
//

import SwiftUI

/// View that displays cuisine options and allows users to place orders
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

    /// Creates a cuisine selection button
    /// - Parameters:
    ///   - cuisine: The cuisine name
    ///   - geometry: Geometry proxy for responsive sizing
    /// - Returns: A configured button view
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

    /// Creates the order submission button
    /// - Parameter geometry: Geometry proxy for responsive sizing
    /// - Returns: A configured order button
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

    /// Toggles the selection state of a cuisine
    /// - Parameter cuisine: The cuisine to toggle
    private func toggleCuisineSelection(_ cuisine: String) {
        if selectedCuisines.contains(cuisine) {
            selectedCuisines.remove(cuisine)
        } else {
            selectedCuisines.insert(cuisine)
        }
    }

    /// Handles the order button press with animation and API call
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

    /// Places the order using the OrderService
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

/// Displays a loading indicator overlay
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
