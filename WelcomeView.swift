//
//  WelcomeView.swift
//  eater
//
//  Welcome screen displaying the app branding
//

import SwiftUI

/**
 Initial welcome view with app branding and navigation to cuisine selection.

 `WelcomeView` serves as the landing screen of the application, displaying
 a creative pattern of "Eater" text with a central carrot icon that acts as
 the navigation button to begin the ordering flow.

 ## Visual Design
 The view creates a unique vertical layout with:
 - Five instances of "Eater" text in bold typography
 - Three "Eater" texts at the top
 - Central carrot icon navigation button
 - Two "Eater" texts at the bottom

 ## Navigation
 Tapping the carrot icon checks authentication status:
 - If not authenticated: Shows AuthenticationView
 - If authenticated: Shows CuisineSelectionView

 ## Authentication Flow
 1. User taps carrot icon
 2. Check if user is authenticated (via AuthService)
 3. If not authenticated, show login screen
 4. After successful login, proceed to cuisine selection
 5. If already authenticated, go directly to cuisine selection

 ## Accessibility
 The carrot button includes proper accessibility labels and hints to ensure
 the app is usable by all users, including those using assistive technologies.

 - Note: This view uses NavigationStack for proper navigation hierarchy.
 - Important: Authentication is required before placing orders.
 */
struct WelcomeView: View {
    // MARK: - State Properties

    /// Controls whether to show the authentication view
    @State private var showAuthentication = false

    /// Controls whether to show the cuisine selection view
    @State private var showCuisineSelection = false

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - Top Eater Text Group
                topEaterGroup

                Spacer()

                // MARK: - Central Navigation Button
                carrotButton

                Spacer()

                // MARK: - Bottom Eater Text Group
                bottomEaterGroup
            }
            .toolbar(.hidden, for: .navigationBar)
            .fullScreenCover(isPresented: $showAuthentication) {
                AuthenticationView { success in
                    if success {
                        // User successfully authenticated, show cuisine selection
                        showCuisineSelection = true
                    }
                }
            }
            .fullScreenCover(isPresented: $showCuisineSelection) {
                CuisineSelectionView()
            }
        }
    }

    // MARK: - View Components

    /**
     Top group of "Eater" text displays.

     Creates a vertical stack containing three "Eater" text elements
     positioned at the top of the screen. The first element includes
     additional top padding to position the group appropriately.

     - Returns: A VStack containing three "Eater" text views
     */
    private var topEaterGroup: some View {
        VStack(spacing: 20) {
            // First Eater
            eaterText
                .padding(.top, 100)

            // Second Eater
            eaterText

            // Third Eater
            eaterText
        }
    }

    /**
     Bottom group of "Eater" text displays.

     Creates a vertical stack containing two "Eater" text elements
     positioned at the bottom of the screen. The second element includes
     additional bottom padding for proper screen positioning.

     - Returns: A VStack containing two "Eater" text views
     */
    private var bottomEaterGroup: some View {
        VStack(spacing: 20) {
            // Fourth Eater
            eaterText

            // Fifth Eater
            eaterText
                .padding(.bottom, 100)
        }
    }

    /**
     Reusable "Eater" text component with consistent styling.

     Provides a standardized text view for the "Eater" branding throughout
     the welcome screen. Uses system font with heavy weight for impact.

     - Returns: A styled Text view displaying "Eater"

     ## Styling
     - Font: System, 80pt, black weight
     - Color: Black
     */
    private var eaterText: some View {
        Text("Eater")
            .font(.system(size: 80, weight: .black))
            .foregroundColor(.black)
    }

    /**
     Central carrot icon button that navigates to cuisine selection.

     The primary navigation element that initiates the food ordering flow.
     Uses SF Symbols carrot icon for playful, food-related imagery.

     - Returns: A button with carrot icon

     ## Interaction
     Tapping this button checks authentication:
     - If authenticated: Shows CuisineSelectionView
     - If not authenticated: Shows AuthenticationView first

     ## Accessibility
     - Label: "Start ordering"
     - Hint: "Tap to select cuisines and place an order"
     */
    private var carrotButton: some View {
        Button(action: handleCarrotButtonTap) {
            Image(systemName: "carrot.fill")
                .font(.system(size: 30))
                .foregroundColor(.black)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Start ordering")
        .accessibilityHint("Tap to select cuisines and place an order")
    }

    // MARK: - Actions

    /**
     Handles carrot button tap with authentication check.

     Checks if user is authenticated:
     - If yes: Proceeds to cuisine selection
     - If no: Shows authentication screen first

     This ensures users are logged in before they can place orders.
     */
    private func handleCarrotButtonTap() {
        // Check if user is already authenticated
        if AuthService.shared.isAuthenticated() {
            // User is authenticated, go directly to cuisine selection
            print("✅ User is authenticated, showing cuisine selection")
            showCuisineSelection = true
        } else {
            // User is not authenticated, show login screen first
            print("⚠️ User not authenticated, showing authentication screen")
            showAuthentication = true
        }
    }
}

// MARK: - Preview

#Preview {
    WelcomeView()
}
