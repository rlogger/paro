//
//  DemoConfig.swift
//  eater
//
//  Demo mode configuration for the app
//

import Foundation

/**
 Configuration for demo mode.

 This file contains all settings and mock data for demo mode,
 making it easy to show the app without real backend services.
 */
struct DemoConfig {
    /// Enable demo mode (always true for demo builds)
    static let isDemoMode = true

    /// Demo user credentials (any email/password works)
    static let demoEmail = "demo@eater.app"
    static let demoPassword = "demo123"

    /// Demo user information
    static let demoUser = User(
        uid: "demo_user_abc123",
        email: "demo@eater.app",
        displayName: "Demo User",
        phoneNumber: "+14155551234"
    )

    /// Simulated network delay (in seconds) for realistic feel
    static let networkDelay: Double = 0.8

    /// Demo mode banner settings
    static let showDemoBanner = false // Set to true to show "DEMO MODE" banner

    /// Available cuisines for demo
    static let demoCuisines = ["Water", "Italian", "Thai", "Fries", "Indian", "Panda"]

    /// Sample orders for different cuisine combinations
    static let sampleOrders: [String: (platform: String, item: String, customization: String, price: Double, total: Double)] = [
        "Italian": (
            platform: "Uber Eats",
            item: "Margherita Pizza",
            customization: "Extra cheese, thin crust",
            price: 14.95,
            total: 22.45
        ),
        "Thai": (
            platform: "Uber Eats",
            item: "Pad Thai Noodles",
            customization: "Choice of Protein: Vegetables",
            price: 13.95,
            total: 23.80
        ),
        "Indian": (
            platform: "DoorDash",
            item: "Chicken Tikka Masala",
            customization: "Mild spice, extra naan",
            price: 16.95,
            total: 25.60
        ),
        "Fries": (
            platform: "Uber Eats",
            item: "Loaded Fries",
            customization: "Extra bacon, cheese sauce",
            price: 8.95,
            total: 15.20
        ),
        "Panda": (
            platform: "Grubhub",
            item: "Orange Chicken Bowl",
            customization: "Fried rice, extra sauce",
            price: 11.95,
            total: 18.75
        ),
        "Water": (
            platform: "Uber Eats",
            item: "Premium Water Bottle",
            customization: "Sparkling",
            price: 2.99,
            total: 8.50
        )
    ]

    /// Tips for demonstrating the app
    static let demoTips = """
    🎯 DEMO TIPS:

    1. Authentication works with ANY email/password
    2. Select multiple cuisines to see different order options
    3. Order placement is instant (simulated)
    4. All data is mock - no real charges!
    5. Perfect for showing the user flow
    """
}
