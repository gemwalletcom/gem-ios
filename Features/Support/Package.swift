// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Support",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Support",
            targets: ["Support"]
        )
    ],
    dependencies: [
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "GemstonePrimitives", path: "../../Packages/GemstonePrimitives"),
        .package(name: "PrimitivesComponents", path: "../../Packages/PrimitivesComponents"),
        .package(name: "Preferences", path: "../../Packages/Preferences"),
        .package(name: "SystemServices", path: "../../Packages/SystemServices"),
    ],
    targets: [
        .target(
            name: "Support",
            dependencies: [
                "Style",
                "Components",
                "Primitives",
                "Localization",
                "GemstonePrimitives",
                "PrimitivesComponents",
                "Preferences",
                .product(name: "NotificationService", package: "SystemServices")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "SupportTests",
            dependencies: [

            ]
        ),
    ]
)
