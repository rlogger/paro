// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "eater",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "eater",
            targets: ["eater"]),
    ],
    dependencies: [
        // Add Firebase dependencies when ready
        // .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0"),
    ],
    targets: [
        .target(
            name: "eater",
            dependencies: [
                // .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                // .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
            ],
            path: ".",
            exclude: [
                "Assets.xcassets",
                "docs",
                "img",
                "Tests",
                "README.md",
                "LICENSE",
                "CONTRIBUTING.md",
                "DEPLOYMENT.md",
                "TESTING.md",
                "XCODE_FIX.md",
                ".gitignore",
                ".gitattributes",
                ".swiftlint.yml",
                ".swiftformat",
                "Info.plist",
                "Makefile",
                "Package.swift",
                "eater.xcconfig",
                "project.yml"
            ],
            sources: [
                "eaterApp.swift",
                "ContentView.swift",
                "WelcomeView.swift",
                "AuthenticationView.swift",
                "CuisineSelectionView.swift",
                "ConfirmationView.swift",
                "AuthService.swift",
                "OrderService.swift",
                "NotificationService.swift",
                "KeychainHelper.swift",
                "Item.swift"
            ]
        ),
        .testTarget(
            name: "eaterTests",
            dependencies: ["eater"],
            path: "Tests/eaterTests"
        ),
    ]
)
