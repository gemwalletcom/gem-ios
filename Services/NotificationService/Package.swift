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
            targets: ["NotificationService"]
        ),
        .library(
            name: "NotificationServiceTestKit",
            targets: ["NotificationServiceTestKit"]
        )
    ],
    dependencies: [
        .package(name: "Preferences", path: "../../Packages/Preferences"),
    ],
    targets: [
        .target(
            name: "NotificationService",
            dependencies: [
                "Preferences"
            ],
            path: "Sources"
        ),
        .target(
            name: "NotificationServiceTestKit",
            dependencies: [
                .product(name: "PreferencesTestKit", package: "Preferences"),
                "NotificationService"
            ],
            path: "TestKit"
        )
    ]
)
