// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "DataValidation",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "DataValidation",
            targets: ["DataValidation"]),
    ],
    dependencies: [
        .package(name: "Primitives", path: "../Primitives"),
        .package(name: "Keystore", path: "../Keystore")
        ],
    targets: [
        .target(
            name: "DataValidation",
            dependencies: [
                "Primitives",
                "Keystore"
            ]),
        .testTarget(
            name: "DataValidationTests",
            dependencies: ["DataValidation"]
        ),
    ]
)
