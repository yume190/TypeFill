// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TypeFill",
    platforms: [
        .macOS(SupportedPlatform.MacOSVersion.v10_13)
    ],
    products: [
        .executable(name: "typefill", targets: ["TypeFill"]),
        .library(name: "TypeFillKit", targets: ["TypeFillKit"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/jpsim/SourceKitten", .upToNextMinor(from: "0.31.0")),
        .package(url: "https://github.com/apple/swift-argument-parser.git", .upToNextMinor(from: "0.3.2")),
        
        .package(name: "SwiftSyntax", url: "https://github.com/apple/swift-syntax.git", .exact("0.50300.0")),
        
        //        .package(url: "https://github.com/jpsim/Yams.git", from: "2.0.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.2.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "TypeFill",
            dependencies: [
                "TypeFillKit",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SourceKittenFramework", package: "SourceKitten"),
            ]
        ),
        .target(
            name: "TypeFillKit",
            dependencies: [
                "Rainbow",
                .product(name: "SourceKittenFramework", package: "SourceKitten"),
                .product(name: "SwiftSyntax", package: "SwiftSyntax"),
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
            dependencies: ["TypeFillKit"],
            resources: [
                .copy("Resource")
            ]
        )
    ]
)


//Target.testTarget(name: <#T##String#>, dependencies: <#T##[Target.Dependency]#>, path: <#T##String?#>, exclude: <#T##[String]#>, sources: <#T##[String]?#>, resources: <#T##[Resource]?#>, cSettings: <#T##[CSetting]?#>, cxxSettings: <#T##[CXXSetting]?#>, swiftSettings: <#T##[SwiftSetting]?#>, linkerSettings: <#T##[LinkerSetting]?#>)
