// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "WalletSessionService",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "WalletSessionService",
            targets: ["WalletSessionService"]
        ),
        .library(
            name: "WalletSessionServiceTeskKit",
            targets: ["WalletSessionServiceTeskKit"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
    ],
    targets: [
        .target(
            name: "WalletSessionService",
            dependencies: [
                "Primitives",
                "Store",
                "Preferences"
            ],
            path: "Sources"
        ),
        .target(
            name: "WalletSessionServiceTeskKit",
            dependencies: [
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "StoreTestKit", package: "Store"),
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "WalletSessionServiceTests",
            dependencies: [
                "WalletSessionService",
                "WalletSessionServiceTeskKit",
                .product(name: "PreferencesTestKit", package: "Preferences"),
                .product(name: "StoreTestKit", package: "Store"),
                .product(name: "PrimitivesTestKit", package: "Primitives"),
            ],
            path: "Tests"
        ),
    ]
)
