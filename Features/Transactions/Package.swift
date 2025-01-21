// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Transactions",
    products: [
        .library(
            name: "Transactions",
            targets: ["Transactions"]),
    ],
    targets: [
        .target(
            name: "Transactions"),
        .testTarget(
            name: "TransactionsTests",
            dependencies: ["Transactions"]
        ),
    ]
)
