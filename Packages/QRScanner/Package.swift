// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QRScanner",
    platforms: [.iOS(.v17), .macOS(.v12)],
    products: [
        .library(
            name: "QRScanner",
            targets: ["QRScanner"]),
    ],
    dependencies: [
        .package(url: "https://github.com/gemwalletcom/CodeScanner", exact: Version(2, 3, 2)),
    ],
    targets: [
        .target(
            name: "QRScanner",
            dependencies: [
                .product(name: "CodeScanner", package: "CodeScanner"),
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "QRScannerTests",
            dependencies: ["QRScanner"]),
    ]
)
