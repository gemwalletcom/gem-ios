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
        .package(name: "Preferences", path: "../Preferences"),
    ],
    targets: [
        .target(
            name: "NotificationService",
            dependencies: [
                "Preferences"
            ],
            path: "Sources"
        ),
    ]
)
