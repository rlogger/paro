//
//  ContentView.swift
//  paro
//
//  Root view of the application
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        WelcomeView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
