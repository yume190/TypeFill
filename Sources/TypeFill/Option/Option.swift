//
//  Option.swift
//  TypeFill
//
//  Created by Yume on 2022/2/10.
//

import Foundation
import ArgumentParser
import TypeFillKit

struct ConfigOptions: ParsableArguments, Configable, BuildConfigable {
    @Flag(name: [.customLong("print", withSingleDash: false)], help: "print fixed code, if false it will overwrite source file")
    var print: Bool = false
    
    @Flag(name: [.customLong("verbose", withSingleDash: false), .short], help: "print fix item")
    var verbose: Bool = false
    
    @Flag(name: [.customLong("skipBuild", withSingleDash: false)], help: "skip build")
    var skipBuild: Bool = false
    
    @Argument(help: "Arguments passed to `xcodebuild` or `swift build`. If `-` prefixed argument exists, place ` -- ` before that.")
    var args: [String] = []
}

struct ModuleOptions: ParsableArguments {
    @Option(name: [.customLong("module", withSingleDash: false)], help: "spm target name or xcode scheme")
    var name: String
}

struct TargetFileOptions: ParsableArguments {
    @Option(name: [.customLong("file", withSingleDash: false)], help: "xcworkspace/xcproject/xxx.swift")
    var file: String
    
    var path: String {
        URL(fileURLWithPath: file).path
    }
}

struct PackageOptions: ParsableArguments {
    @Option(name: [.customLong("file", withSingleDash: false)], help: "path to spm dir")
    var file: String = "."
    
    var path: String {
        URL(fileURLWithPath: file).path
    }
}
