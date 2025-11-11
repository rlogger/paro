//
//  eaterApp.swift
//  eater
//
//  Main application entry point
//  Created by rajdeep singh on 9/20/25.
//

import SwiftUI
import SwiftData

// MARK: - Main App

/// The main app structure for the Eater food delivery application
/// Configures SwiftData for persistent storage and sets up the initial view hierarchy
@main
struct eaterApp: App {
    // MARK: - Properties

    /// Shared model container for SwiftData persistence
    /// Configured to store order history and user data
    var sharedModelContainer: ModelContainer = {
        // Define the data schema
        let schema = Schema([
            Item.self,
        ])

        // Configure storage settings
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        // Create and return the container
        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            // Fatal error if container creation fails
            // This should only occur in exceptional circumstances
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    // MARK: - Scene

    /// The main scene configuration
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
