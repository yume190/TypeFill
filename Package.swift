// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

//https://github.com/apple/indexstore-db/tree/
//let appleDependencies: [Package.Dependency] = [
//    // .package(name: "IndexStoreDB", url: "https://github.com/apple/indexstore-db.git", .branch(branch)),
//    .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .branch(branch)),
//]

let package = Package(
    name: "TypeFill",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "typefill", targets: ["TypeFill"]),
        .executable(name: "derivedPath", targets: ["DerivedPath"]),
        
        .library(name: "TypeFillKit", targets: ["TypeFillKit"]),
        .library(name: "SKClient", targets: ["SKClient"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(
            name: "SwiftSyntax",
            url: "https://github.com/apple/swift-syntax.git",
            revision: "508.0.0"
        ),
        
        .package(url: "https://github.com/jpsim/SourceKitten", from: "0.34.1"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.2"),
        
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", from: "1.7.1"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        
        // MARK: Executable
        .executableTarget(
            name: "TypeFill",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SourceKittenFramework", package: "SourceKitten"),
                "TypeFillKit",
                "SKClient",
            ]
        ),

        .executableTarget(
            name: "DerivedPath",
            dependencies: [
                "Derived"
            ]
        ),
        
        // MARK: Frameworks
        .target(
            name: "TypeFillKit",
            dependencies: [
                .product(name: "SwiftSyntax", package: "SwiftSyntax"),
                .product(name: "SwiftSyntaxBuilder", package: "SwiftSyntax"),
                
                "Rainbow",
                // .product(name: "IndexStoreDB", package: "IndexStoreDB"),
                "SKClient",
            ]
        ),
        
        // MARK: Common Frameworks
        .target(
            name: "Derived",
            dependencies: [
                "CryptoSwift",
            ]),
        
        .target(
            name: "SKClient",
            dependencies: [
                .product(name: "SwiftSyntax", package: "SwiftSyntax"),
                .product(name: "SwiftParser", package: "SwiftSyntax"),
//                .product(name: "SwiftSyntaxParser", package: "SwiftSyntax"),
//                .product(name: "IndexStoreDB", package: "IndexStoreDB"),
                "Rainbow",
                .product(name: "SourceKittenFramework", package: "SourceKitten"),
                "Derived",
            ]
        ),
        
        // MARK: Tests
        .testTarget(
            name: "TypeFillTests",
            dependencies: [
                .product(name: "SwiftSyntax", package: "SwiftSyntax"),
                "TypeFillKit",
                "SKClient",
            ],
            resources: [
                .copy("Resource")
            ]
        ),
        
        .testTarget(
            name: "SKClientTests",
            dependencies: [
                "SKClient",
            ],
            resources: [
                .copy("Resource")
            ]
        ),
    ]
)
