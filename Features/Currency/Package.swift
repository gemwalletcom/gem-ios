// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Currency",
    platforms: [
        .iOS(.v17),
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "Currency",
            targets: ["Currency"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Localization", path: "../../Packages/Localization"),
        .package(name: "PriceService", path: "../../Services/PriceService"),
    ],
    targets: [
        .target(
            name: "Currency",
            dependencies: [
                "Primitives",
                "Components",
                "Localization",
                "PriceService",
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "CurrencyTests",
            dependencies: [
                "Currency",
                .product(name: "PriceServiceTestKit", package: "PriceService"),
            ]
        ),
    ]
)
