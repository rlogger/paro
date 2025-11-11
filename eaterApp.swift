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

/**
 The main app structure for the Eater food delivery application.

 `eaterApp` is the entry point for the entire application, marked with the
 `@main` attribute. It configures SwiftData for persistent storage and sets
 up the initial view hierarchy.

 ## Responsibilities
 - Configure SwiftData model container
 - Define the data schema
 - Set up the main window group
 - Inject dependencies into the view hierarchy

 ## Data Persistence
 The app uses SwiftData for automatic data persistence. The model container
 is configured to store data persistently on disk, allowing order history
 and user data to persist across app launches.

 ## Error Handling
 If the model container fails to initialize, the app will terminate with a
 fatal error. This should only occur in exceptional circumstances such as
 insufficient disk space or corrupted data files.

 - Important: Uses SwiftData for data persistence.
 - Note: The model container is shared across the entire app.
 - SeeAlso: `Item` for the data model definition.
 */
@main
struct eaterApp: App {
    // MARK: - Properties

    /**
     Shared model container for SwiftData persistence.

     Configured to store order history and user data. The container is
     initialized with the Item schema and uses persistent storage.

     ## Configuration
     - Schema: Item.self
     - Storage: Persistent (not in-memory)
     - Shared across all views via environment

     - Warning: Fatal error if container creation fails.
     */
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

    /**
     The main scene configuration.

     Defines the app's window group with ContentView as the root view.
     The model container is injected into the environment, making it
     accessible to all child views.

     - Returns: A configured WindowGroup scene
     */
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
