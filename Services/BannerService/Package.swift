// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BannerService",
    platforms: [
        .iOS(.v17),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "BannerService",
            targets: ["BannerService"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "NotificationService", path: "../NotificationService"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
    ],
    targets: [
        .target(
            name: "BannerService",
            dependencies: [
                "Primitives",
                "Store",
                "NotificationService",
                "Preferences"
            ],
            path: "Sources"
        ),
    ]
)
