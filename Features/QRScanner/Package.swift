// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "QRScanner",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "QRScanner",
            targets: ["QRScanner"]),
    ],
    dependencies: [
        .package(name: "Components", path: "../Components"),
        .package(name: "Localization", path: "../Localization"),
    ],
    targets: [
        .target(
            name: "QRScanner",
            dependencies: [
                "Components",
                "Localization"
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "QRScannerTests",
            dependencies: ["QRScanner"]),
    ]
)
