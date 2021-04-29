//
//  Command.swift
//  ArgumentParser
//
//  Created by Yume on 2020/3/10.
//

import Foundation
import ArgumentParser
import SourceKittenFramework
import TypeFillKit

// /Users/yume/Library/Developer/Xcode/DerivedData/
// derivedPath("/Users/yume/git/work/05_Tangram/Tangran-iOS/Tangran-iOS/Tangran-iOS.xcworkspace")
// Tangran-iOS-dypjjsfgpgnwevbnyblbgyscmmcg
// Index/DataStore

///-workspace SourceKitten.xcworkspace -scheme SourceKittenFramework
struct WorkSpace: ParsableCommand, CommandBuild {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "workspace",
        abstract: "Fill type to XCode workspace"
    )
    
    @Flag(name: [.customLong("print", withSingleDash: false)], help: "print fixed code, if false it will overwrite source file")
    var print: Bool = false
    
    @Flag(name: [.customLong("verbose", withSingleDash: false), .short], help: "print fix item")
    var verbose: Bool = false
    
    @Option(name: [.customLong("workspace", withSingleDash: false)], help: "absolute path of workspace")
    var workspace: String
    
    @Option(name: [.customLong("scheme", withSingleDash: false)], help: "scheme")
    var scheme: String
    
    @Flag(name: [.customLong("skipBuild", withSingleDash: false)], help: "skip build")
    var skipBuild: Bool = false
    
    @Argument(help: "Arguments passed to `xcodebuild` or `swift build`. If `-` prefixed argument exists, place ` -- ` before that.")
    var args: [String] = []
    
    private var xcodeBuildArguments: [String] {
        let newArgs: [String] = [
            "-workspace",
            workspace,
            "-scheme",
            scheme,
        ]
        return args + newArgs
    }
    
    func run() throws {
        try self.scan()
    }
    
    var isIndexStoreExist: Bool {
        let path = URL(fileURLWithPath: workspace).path
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
