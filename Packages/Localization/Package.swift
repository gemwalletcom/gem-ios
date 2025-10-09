// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Localization",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v15)
    ],
    products: [
        .library(
            name: "Localization",
            targets: ["Localization"]
        ),
        .library(
            name: "WidgetLocalization",
            targets: ["WidgetLocalization"]
        )
    ],
    targets: [
        .target(
            name: "Localization",
            path: "Sources",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "WidgetLocalization",
            path: "WidgetSources",
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
