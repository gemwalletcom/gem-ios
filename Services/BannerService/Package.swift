// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BannerService",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "BannerService",
            targets: ["BannerService"]
        ),
        .library(
            name: "BannerServiceTestKit",
            targets: ["BannerServiceTestKit"]
        )
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
        .target(
            name: "BannerServiceTestKit",
            dependencies: [
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "NotificationServiceTestKit", package: "NotificationService"),
                "BannerService"
            ],
            path: "TestKit"
        )
    ]
)
