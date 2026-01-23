// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Onboarding",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "Onboarding",
            targets: ["Onboarding"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
        .package(name: "Formatters", path: "../../Packages/Formatters"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "QRScanner", path: "../QRScanner"),
        .package(name: "Keystore", path: "../../Packages/Keystore"),
        .package(name: "FeatureServices", path: "../../Packages/FeatureServices"),
        .package(name: "ChainServices", path: "../../Packages/ChainServices"),
        .package(name: "Store", path: "../../Packages/Store")
    ],
    targets: [
        .target(
            name: "Onboarding",
            dependencies: [
                "Primitives",
                "GemstonePrimitives",
                "Components",
                "Style",
                "Localization",
                "PrimitivesComponents",
                .product(name: "NameService", package: "ChainServices"),
                "QRScanner",
                "Keystore",
                .product(name: "WalletService", package: "FeatureServices"),
                .product(name: "WalletsService", package: "FeatureServices"),
                .product(name: "BannerService", package: "FeatureServices"),
                .product(name: "AvatarService", package: "FeatureServices"),
                "Formatters",
                "Store"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "OnboardingTest",
            dependencies: [
                "Onboarding",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "WalletServiceTestKit", package: "FeatureServices"),
                .product(name: "KeystoreTestKit", package: "Keystore"),
                .product(name: "NameServiceTestKit", package: "ChainServices"),
                .product(name: "StoreTestKit", package: "Store"),
            ],
            path: "Tests"
        )
    ]
)
