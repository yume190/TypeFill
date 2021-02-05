// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TypeFill",
    platforms: [
        .macOS(SupportedPlatform.MacOSVersion.v10_10)
    ],
    products: [
        .executable(name: "typefill", targets: ["TypeFill"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/jpsim/SourceKitten", .upToNextMinor(from: "0.31.0")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.3.2")),
        
        .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50300.0")),

//        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "TypeFill",
            dependencies: [
                "TypeFillKit"
                ]
        ),
        .target(
            name: "TypeFillKit",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "SourceKittenFramework",
                "Rainbow",
                "SwiftSyntax",
                "SwiftSyntaxBuilder"
//                "Yams"
        ]),
//        .target(
//            name: "TestingData",
//            exclude: [
//                "cursor.yml",
//                "open.yml",
//                "requests.txt",
//            ]
//        ),
        .testTarget(
            name: "TypeFillTests",
            dependencies: ["TypeFillKit"])
    ]
)
