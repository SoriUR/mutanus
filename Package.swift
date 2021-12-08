// swift-tools-version:5.4

import PackageDescription

#if swift(<5.5)
let swiftSyntaxVersion = Package.Dependency.Requirement.exact("0.50400.0")
#elseif swift(>=5.5)
let swiftSyntaxVersion = Package.Dependency.Requirement.exactItem("0.50500.0")
#endif

let package = Package(
    name: "Mutanus",
    platforms: [
        .macOS(.v10_15)
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", swiftSyntaxVersion),
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
