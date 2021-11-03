// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mutanus",
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .exact("0.50400.0")),
    ],
    targets: [
        .executableTarget(
            name: "Mutanus",
            dependencies: [
                "SwiftSyntax",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "MutanusTests",
            dependencies: ["Mutanus"]),
    ]
)
