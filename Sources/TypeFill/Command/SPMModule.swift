//
//  SPM.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/5.
//

import Foundation
import ArgumentParser
import SourceKittenFramework
import TypeFillKit
import Derived

struct SPMModule: ParsableCommand, CommandBuild {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "spm",
        abstract: "Fill type to SPM Project."
    )
    
    @OptionGroup()
    var _config: ConfigOptions
    var config: Config {
        _config
    }
    
    @OptionGroup()
    var module: ModuleOptions
    
    @OptionGroup()
    var package: PackageOptions
    
    func run() throws {
        try self.scan()
    }
    
    var isIndexStoreExist: Bool {
        DerivedPath.SPM(package.path)?.indexStorePath != nil
    }
    
    var buildSetting: CompilerArgumentsGettable? {
        return []
    }
    
    var buildModule: Module? {
        return Module(spmArguments: _config.args, spmName: module.name, inPath: package.path)
    }
    
    var skipBuildModule: Module? {
        return Module(spmName: module.name, inPath: package.path)
    }
}

