// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AutoFill",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(path: "../sourcekit-lsp"),
        // .package(url: "https://github.com/apple/indexstore-db.git", .branch("swift-5.1-branch")),
        // .package(url: "https://github.com/apple/swift-package-manager.git", .branch("swift-5.1-branch")),
        // .package(url: "https://github.com/apple/sourcekit-lsp", .branch("swift-5.1-branch")),
        // .package(url: "https://github.com/apple/sourcekit-lsp", .exact("swift-5.1-RELEASE")),
        // .package(url: "https://github.com/apple/swift-syntax", .branch("swift-5.1-branch")),
        
            
        .package(url: "https://github.com/jpsim/SourceKitten", .branch("swift-5.1")),
        
        .package(url: "https://github.com/Carthage/Commandant.git", .upToNextMinor(from: "0.16.0")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "AutoFill",
            dependencies: [
                "Commandant", 
                // "SourceKit",
                "SourceKittenFramework",
                ]),
        .testTarget(
            name: "AutoFillTests",
            dependencies: ["AutoFill"]),
    ]
)
