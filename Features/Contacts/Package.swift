// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Contacts",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Contacts",
            targets: ["Contacts"]),
    ],
    dependencies: [
        .package(name: "ContactService", path: "../ContactService"),
        .package(name: "DataValidation", path: "../DataValidation")
    ],
    targets: [
        .target(
            name: "Contacts",
            dependencies: [
                "ContactService",
                "DataValidation"
            ]
        ),
    ]
)
