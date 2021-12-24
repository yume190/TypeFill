// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

#if swift(>=5.5)
let branch = "release/5.5"
#elseif swift(>=5.4)
let branch = "release/5.4"
#else
let branch = "release/5.3"
#endif

let appleDependencies: [Package.Dependency] = [
    // .package(name: "IndexStoreDB", url: "https://github.com/apple/indexstore-db.git", .branch(branch)),
    .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .branch(branch)),
]

let package = Package(
    name: "TypeFill",
    platforms: [
        .macOS(SupportedPlatform.MacOSVersion.v10_12)
    ],
    products: [
        .executable(name: "typefill", targets: ["TypeFill"]),
        .executable(name: "leakDetect", targets: ["LeakDetect"]),
        .executable(name: "derivedPath", targets: ["DerivedPath"]),
        
        .library(name: "TypeFillKit", targets: ["TypeFillKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/jpsim/SourceKitten", .upToNextMinor(from: "0.31.0")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.3.2")),
        
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", .upToNextMinor(from: "1.4.2")),
        .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.1"),
    ] + appleDependencies,
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        
        // MARK: Executable
        .target(
            name: "TypeFill",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SourceKittenFramework", package: "SourceKitten"),
                "TypeFillKit",
                "Cursor",
            ]
        ),

        .target(
            name: "DerivedPath",
            dependencies: [
                "Derived"
            ]
        ),
        
        .target(
            name: "LeakDetect",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SourceKittenFramework", package: "SourceKitten"),
                "SwiftLeakCheck",
                "Cursor",
                "Derived",
                "LeakDetectExtension",
            ]
        ),
        
        // MARK: Frameworks
        .target(
            name: "TypeFillKit",
            dependencies: [
                "Rainbow",
                .product(name: "SwiftSyntax", package: "SwiftSyntax"),
                // .product(name: "IndexStoreDB", package: "IndexStoreDB"),
                "Cursor",
            ]),
        
        .target(
            name: "SwiftLeakCheck",
            dependencies: [
                "Rainbow",
                .product(name: "SwiftSyntax", package: "SwiftSyntax"),
                "Cursor",
                "LeakDetectExtension",
            ]),
        
        .target(
            name: "LeakDetectExtension",
            dependencies: [
                "Rainbow",
                .product(name: "SwiftSyntax", package: "SwiftSyntax"),
                "Cursor",
            ]),
        
        // MARK: Common Frameworks
        .target(
            name: "Derived",
            dependencies: [
                "CryptoSwift",
            ]),
        
        .target(
            name: "Cursor",
            dependencies: [
                "Rainbow",
                .product(name: "SourceKittenFramework", package: "SourceKitten"),
                .product(name: "SwiftSyntax", package: "SwiftSyntax"),
                "Derived",
            ]),
        
        // MARK: Tests
        .testTarget(
            name: "TypeFillTests",
            dependencies: [
                .product(name: "SwiftSyntax", package: "SwiftSyntax"),
                "TypeFillKit",
                "Cursor",
            ],
            resources: [
                .copy("Resource")
            ]
        ),
        
        .testTarget(
            name: "LeakDetectTests",
            dependencies: [
                .product(name: "SwiftSyntax", package: "SwiftSyntax"),
                "LeakDetectExtension",
                "SwiftLeakCheck",
                "Cursor",
            ],
            resources: [
                .copy("Resource")
            ]
        ),
        
        .testTarget(
            name: "CursorTests",
            dependencies: [
                "Cursor",
            ],
            resources: [
                .copy("Resource")
            ]
        ),
    ]
)
