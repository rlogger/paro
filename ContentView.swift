//
//  ContentView.swift
//  eater
//
//  Created by rajdeep singh on 9/20/25.
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
