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
        .package(name: "Formatters", path: "../../Packages/Formatters"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "NameResolver", path: "../NameResolver"),
        .package(name: "QRScanner", path: "../QRScanner"),
        .package(name: "Keystore", path: "../../Packages/Keystore"),
        .package(name: "WalletService", path: "../../Services/WalletService")
    ],
    targets: [
        .target(
            name: "Onboarding",
            dependencies: [
                "Primitives",
                "Components",
                "Style",
                "Localization",
                "PrimitivesComponents",
                "NameResolver",
                "QRScanner",
                "Keystore",
                "WalletService",
                "Formatters"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "OnboardingTest",
            dependencies: ["Onboarding"],
            path: "Tests"
        )
    ]
)
