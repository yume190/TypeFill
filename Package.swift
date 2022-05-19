// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import Foundation

//#if swift(>=5.5)
//let branch = "release/5.5"
//#elseif swift(>=5.4)
//let branch = "release/5.4"
//#else
//let branch = "release/5.3"
//#endif
//
//let appleDependencies: [Package.Dependency] = [
//    // .package(name: "IndexStoreDB", url: "https://github.com/apple/indexstore-db.git", .branch(branch)),
//    .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .branch(branch)),
//]

let package = Package(
    name: "TypeFill",
    platforms: [
        .macOS(SupportedPlatform.MacOSVersion.v10_12)
    ],
    products: [
        .executable(name: "typefill", targets: ["TypeFill"]),
//        .executable(name: "leakDetect", targets: ["LeakDetect"]),
        .executable(name: "derivedPath", targets: ["DerivedPath"]),
        
        .library(name: "TypeFillKit", targets: ["TypeFillKit"]),
        .library(name: "Cursor", targets: ["Cursor"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .exact("0.50600.1")),
        
        .package(url: "https://github.com/jpsim/SourceKitten", .upToNextMinor(from: "0.31.1")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "1.0.3")),
        
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", .upToNextMinor(from: "1.4.3")),
        .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.1"),
    ],
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
        
//        .target(
//            name: "LeakDetect",
//            dependencies: [
//                .product(name: "ArgumentParser", package: "swift-argument-parser"),
//                .product(name: "SourceKittenFramework", package: "SourceKitten"),
//                "SwiftLeakCheck",
//                "Cursor",
//                "Derived",
//                "LeakDetectExtension",
//            ]
//        ),
        
        // MARK: Frameworks
        .target(
            name: "TypeFillKit",
            dependencies: [
                "Rainbow",
                .product(name: "SwiftSyntax", package: "SwiftSyntax"),
//                "lib_InternalSwiftSyntaxParser",
                // .product(name: "IndexStoreDB", package: "IndexStoreDB"),
                "Cursor",
            ]
//            linkerSettings: [
//                .unsafeFlags(["-Xlinker", "-dead_strip_dylibs"])
//            ]
        ),
        
//        .target(
//            name: "SwiftLeakCheck",
//            dependencies: [
//                "Rainbow",
//                "_SwiftSyntax",
//                "_SwiftSyntaxParser",
//                "Cursor",
//                "LeakDetectExtension",
//            ]
//        ),
        
//        .target(
//            name: "LeakDetectExtension",
//            dependencies: [
//                "Rainbow",
//                "_SwiftSyntax",
//                "_SwiftSyntaxParser",
//                "Cursor",
//            ]
//        ),
        
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
                .product(name: "SwiftSyntaxParser", package: "SwiftSyntax"),
//                "lib_InternalSwiftSyntaxParser",
                "Derived",
            ]
//            linkerSettings: [
//                .unsafeFlags(["-Xlinker", "-dead_strip_dylibs"])
//            ]
        ),
        
        // MARK: Tests
        .testTarget(
            name: "TypeFillTests",
            dependencies: [
                .product(name: "SwiftSyntax", package: "SwiftSyntax"),
//                "lib_InternalSwiftSyntaxParser",
                "TypeFillKit",
                "Cursor",
            ],
            resources: [
                .copy("Resource")
            ]
//            linkerSettings: [
//                .unsafeFlags(["-Xlinker", "-dead_strip_dylibs"])
//            ]
        ),
        
//        .testTarget(
//            name: "LeakDetectTests",
//            dependencies: [
//                "_SwiftSyntax",
//                "LeakDetectExtension",
//                "SwiftLeakCheck",
//                "Cursor",
//            ],
//            resources: [
//                .copy("Resource")
//            ]
//        ),
        
        .testTarget(
            name: "CursorTests",
            dependencies: [
                "Cursor",
            ],
            resources: [
                .copy("Resource")
            ]
        ),
    
        // MARK: Swift Syntax
        // from https://github.com/krzysztofzablocki/Sourcery/blob/master/Package.swift
        // Pass `-dead_strip_dylibs` to ignore the dynamic version of `lib_InternalSwiftSyntaxParser`
        // that ships with SwiftSyntax because we want the static version from
        // `StaticInternalSwiftSyntaxParser`.
        .target(
            name: "_SwiftSyntax",
            dependencies: [
                .product(name: "SwiftSyntax", package: "SwiftSyntax"),
                "lib_InternalSwiftSyntaxParser",
                
            ],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-dead_strip_dylibs"])
            ]
        ),
        
        .target(
            name: "_SwiftSyntaxParser",
            dependencies: [
                .product(name: "SwiftSyntaxParser", package: "SwiftSyntax"),
                "lib_InternalSwiftSyntaxParser",
                
            ],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-dead_strip_dylibs"])
            ]
        ),
        
        .binaryTarget(
            name: "lib_InternalSwiftSyntaxParser",
            url: "https://github.com/keith/StaticInternalSwiftSyntaxParser/releases/download/5.6/lib_InternalSwiftSyntaxParser.xcframework.zip",
            checksum: "88d748f76ec45880a8250438bd68e5d6ba716c8042f520998a438db87083ae9d"
        )
    ]
)
