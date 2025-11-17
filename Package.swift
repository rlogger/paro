// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "paro",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "paro",
            targets: ["paro"]),
    ],
    targets: [
        .target(
            name: "paro",
            path: ".",
            exclude: [
                "Assets.xcassets",
                "docs",
                "img",
                "Tests",
                ".git",
                ".github",
                "README.md",
                "LICENSE",
                "CONTRIBUTING.md",
                ".gitignore",
                ".gitattributes",
                ".swiftlint.yml",
                ".swiftformat",
                "Info.plist",
                "Makefile",
                "Package.swift",
                "paro.xcconfig",
                "project.yml"
            ],
            sources: [
                "ParoApp.swift",
                "ContentView.swift",
                "WelcomeView.swift",
                "AuthenticationView.swift",
                "CuisineSelectionView.swift",
                "ConfirmationView.swift",
                "AuthService.swift",
                "OrderService.swift",
                "NotificationService.swift",
                "KeychainHelper.swift",
                "Item.swift",
                "DemoConfig.swift"
            ]
        ),
        .testTarget(
            name: "paroTests",
            dependencies: ["paro"],
            path: "Tests/paroTests"
        ),
    ]
)
