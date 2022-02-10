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
import Derived

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
            "-workspace",
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
