// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QRScanner",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "QRScanner",
            targets: ["QRScanner"]),
    ],
    targets: [
        .target(
            name: "QRScanner",
            path: "Sources"
        ),
        .testTarget(
            name: "QRScannerTests",
            dependencies: ["QRScanner"]),
    ]
)
