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
import Derived

/// --file SourceKitten.xcworkspace --module SourceKittenFramework
struct Project: ParsableCommand, CommandBuild {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "project",
        abstract: "Fill type to XCode project."
    )
    
    @OptionGroup()
    var _config: ConfigOptions
    var config: Config {
        _config
    }
    
    @OptionGroup()
    var module: ModuleOptions
    
    @OptionGroup()
    var targetFile: TargetFileOptions
    
    private var xcodeBuildArguments: [String] {
        let newArgs: [String] = [
            "-project",
            targetFile.path,
            "-scheme",
            module.name,
        ]
        return _config.args + newArgs
    }
    
    func run() throws {
        try self.scan()
    }
    
    var isIndexStoreExist: Bool {
        return DerivedPath(targetFile.path)?.indexStorePath != nil
    }
    
    var buildSetting: CompilerArgumentsGettable? {
        return CompilerArguments.byFile(name: module.name, arguments: self.xcodeBuildArguments)
    }
    
    var buildModule: Module? {
        return Module(xcodeBuildArguments: xcodeBuildArguments, name: nil)
    }
    
    var skipBuildModule: Module? {
        guard let _compilerArguments = buildSetting else { return nil }
        return Module(name: module.name, compilerArguments: _compilerArguments.default)
    }
}
