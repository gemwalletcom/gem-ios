// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "NotificationService",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "NotificationService",
            targets: ["NotificationService"]),
    ],
    dependencies: [
        .package(name: "Store", path: "../Store"),
        .package(name: "Preferences", path: "../Preferences"),
    ],
    targets: [
        .target(
            name: "NotificationService",
            dependencies: [
                "Store",
                "Preferences"
            ],
            path: "Sources"
        ),
    ]
)
