//
//  ContentView.swift
//  eater
//
//  Root view of the application
//

import SwiftUI
import SwiftData

/**
 The main content view that serves as the entry point for the app.

 `ContentView` acts as the root view controller, currently displaying the
 WelcomeView as the initial screen. This view is configured as the main
 view in the app's window group and has access to the SwiftData model
 container for data persistence.

 ## Architecture
 This view follows a simple architectural pattern where it delegates to
 child views for actual content display. This makes it easy to modify
 the app's entry point or add navigation logic in the future.

 ## Data Access
 The view has access to the shared SwiftData model container, which is
 injected through the environment by the main app structure.

 - Note: Currently displays WelcomeView as the initial screen.
 - SeeAlso: `WelcomeView` for the welcome screen implementation.
 - SeeAlso: `eaterApp` for the app-level configuration.
 */
struct ContentView: View {
    // MARK: - Body

    var body: some View {
        WelcomeView()
    }
}

// MARK: - Preview

/**
 Preview provider for ContentView with SwiftData model container.

 Configures the preview with an in-memory model container to ensure
 the preview works correctly without affecting persistent data.
 */
#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
