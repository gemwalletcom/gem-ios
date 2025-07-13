// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PriceWidget",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "PriceWidget",
            targets: ["PriceWidget"]
        ),
        .library(
            name: "PriceWidgetTestKit",
            targets: ["PriceWidgetTestKit"]
        ),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../../Packages/Primitives"),
        .package(name: "Components", path: "../../Packages/Components"),
        .package(name: "Style", path: "../../Packages/Style"),
        .package(name: "Store", path: "../../Packages/Store"),
        .package(name: "PriceService", path: "../../Services/PriceService"),
        .package(name: "Localization", path: "../../Packages/Localization"),
    ],
    targets: [
        .target(
            name: "PriceWidget",
            dependencies: [
                "Primitives",
                "Components",
                "Style",
                "Store",
                "PriceService",
                "Localization",
            ],
            path: "Sources"
        ),
        .target(
            name: "PriceWidgetTestKit",
            dependencies: [
                "PriceWidget",
                .product(name: "PrimitivesTestKit", package: "Primitives"),
                .product(name: "PriceServiceTestKit", package: "PriceService"),
                .product(name: "StoreTestKit", package: "Store"),
            ],
            path: "TestKit"
        ),
        .testTarget(
            name: "PriceWidgetTests",
            dependencies: [
                "PriceWidget",
                "PriceWidgetTestKit",
                .product(name: "Testing", package: "swift-testing"),
            ],
            path: "Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)