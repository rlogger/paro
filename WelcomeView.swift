//
//  WelcomeView.swift
//  eater
//
//  Welcome screen displaying the app branding
//

import SwiftUI

/// Initial welcome view with app branding and navigation to cuisine selection
/// Displays a creative "Eater" text pattern with a carrot icon navigation button
struct WelcomeView: View {
    // MARK: - State Properties

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
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showCuisineSelection) {
                CuisineSelectionView()
            }
        }
    }

    // MARK: - View Components

    /// Top group of "Eater" text displays
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

    /// Bottom group of "Eater" text displays
    private var bottomEaterGroup: some View {
        VStack(spacing: 20) {
            // Fourth Eater
            eaterText

            // Fifth Eater
            eaterText
                .padding(.bottom, 100)
        }
    }

    /// Reusable "Eater" text component with consistent styling
    private var eaterText: some View {
        Text("Eater")
            .font(.system(size: 80, weight: .black))
            .foregroundColor(.black)
    }

    /// Central carrot icon button that navigates to cuisine selection
    private var carrotButton: some View {
        Button(action: {
            showCuisineSelection = true
        }) {
            Image(systemName: "carrot.fill")
                .font(.system(size: 30))
                .foregroundColor(.black)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Start ordering")
        .accessibilityHint("Tap to select cuisines and place an order")
    }
}

// MARK: - Preview

#Preview {
    WelcomeView()
}
