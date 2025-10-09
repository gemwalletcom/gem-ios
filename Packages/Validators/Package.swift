// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Validators",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
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
        .package(name: "WalletCore", path: "../WalletCore"),
        .package(name: "Formatters", path: "../Formatters"),
    ],
    targets: [
        .target(
            name: "Validators",
            dependencies: [
                "Primitives",
                "Localization",
                .product(name: "WalletCorePrimitives", package: "WalletCore"),
                "Formatters",
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
