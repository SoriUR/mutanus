// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

var dependencies: [Target.Dependency] = [
    .product(name: "SwiftSyntax", package: "SwiftSyntax"),
    .product(name: "ArgumentParser", package: "ArgumentParser")
]

#if swift(>=5.6)
let swiftSyntaxVersion = Package.Dependency.Requirement.exact("0.50600.1")
dependencies.append(.product(name: "SwiftSyntaxParser", package: "SwiftSyntax"))
#elseif swift(>=5.5)
let swiftSyntaxVersion = Package.Dependency.Requirement.exact("0.50500.0")
#else
let swiftSyntaxVersion = Package.Dependency.Requirement.exact("0.50400.0")
#endif

let package = Package(
    name: "Mutanus",
    platforms: [
        .macOS(.v10_15)
    ],
    products: [
        .executable(name: "mutanus", targets: ["Mutanus"])
    ],
    dependencies: [
        .package(name: "ArgumentParser", url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", swiftSyntaxVersion),
    ],
    targets: [
        .executableTarget(
            name: "Mutanus",
            dependencies: dependencies
        ),
        .testTarget(
            name: "MutanusTests",
            dependencies: ["Mutanus"]),
    ]
)
