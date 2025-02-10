// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Onboarding",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "Onboarding",
            targets: ["Onboarding"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Components", path: "../Components"),
        .package(name: "Style", path: "../Style"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "Keystore", path: "../Keystore"),
        .package(name: "PrimitivesComponents", path: "../PrimitivesComponents"),
        .package(name: "NameResolver", path: "../NameResolver"),
        .package(name: "QRScanner", path: "../QRScanner"),
    ],
    targets: [
        .target(
            name: "Onboarding",
            dependencies: [
                "Primitives",
                "Components",
                "Style",
                "Localization",
                "Keystore",
                "PrimitivesComponents",
                "NameResolver",
                "QRScanner"
            ],
            path: "Sources"
        ),
    ]
)
