// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Localization",
    defaultLocalization: "en",
    products: [
        .library(
            name: "Localization",
            targets: ["Localization"]
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
    ]
)
