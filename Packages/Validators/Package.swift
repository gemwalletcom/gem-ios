// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Validators",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "Validators",
            targets: ["Validators"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Localization", path: "../Localization"),
        .package(name: "WalletCorePrimitives", path: "../WalletCorePrimitives")
    ],
    targets: [
        .target(
            name: "Validators",
            dependencies: [
                "Primitives",
                "Localization",
                "WalletCorePrimitives"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "ValidatorsTests",
            dependencies: [
                "Validators",
                .product(name: "PrimitivesTestKit", package: "Primitives")
            ]
        )
    ]
)
