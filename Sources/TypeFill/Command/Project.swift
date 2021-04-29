//
//  Project.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/9.
//

import Foundation
import ArgumentParser
import SourceKittenFramework
import TypeFillKit

///-workspace SourceKitten.xcworkspace -scheme SourceKittenFramework
struct Project: ParsableCommand, CommandBuild {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "project",
        abstract: "Fill type to XCode project."
    )
    
    @Flag(name: [.customLong("print", withSingleDash: false)], help: "print fixed code, if false it will overwrite source file")
    var print: Bool = false
    
    @Flag(name: [.customLong("verbose", withSingleDash: false), .short], help: "print fix item")
    var verbose: Bool = false
    
    @Option(name: [.customLong("project", withSingleDash: false)], help: "absolute path of project")
    var project: String
    
    @Option(name: [.customLong("scheme", withSingleDash: false)], help: "xcode scheme")
    var scheme: String
    
    @Flag(name: [.customLong("skipBuild", withSingleDash: false)], help: "skip build")
    var skipBuild: Bool = false
    
    @Argument(help: "Arguments passed to `xcodebuild` or `swift build`. If `-` prefixed argument exists, place ` -- ` before that.")
    var args: [String] = []
    
    private var xcodeBuildArguments: [String] {
        let newArgs: [String] = [
            "-project",
            project,
            "-scheme",
            scheme,
        ]
        return args + newArgs
    }
    
    func run() throws {
        try self.scan()
    }
    
    var isIndexStoreExist: Bool {
        let path = URL(fileURLWithPath: project).path
        return DerivedPath(path)?.indexStorePath != nil
    }
    
    var buildSetting: CompilerArgumentsGettable? {
        return CompilerArguments.byFile(name: scheme, arguments: self.xcodeBuildArguments)
    }
    
    var buildModule: Module? {
        return Module(xcodeBuildArguments: xcodeBuildArguments, name: nil)
    }
    
    var skipBuildModule: Module? {
        guard let _compilerArguments = buildSetting else { return nil }
        return Module(name: self.scheme, compilerArguments: _compilerArguments.default)
    }
}
