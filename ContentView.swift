//
//  ContentView.swift
//  eater
//
//  Root view of the application
//

import SwiftUI
import SwiftData

/// The main content view that serves as the entry point for the app
/// Currently displays the WelcomeView as the initial screen
struct ContentView: View {
    // MARK: - Body

    var body: some View {
        WelcomeView()
    }
}

// MARK: - Preview

/// Preview provider for ContentView with SwiftData model container
#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
