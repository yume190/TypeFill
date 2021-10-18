//
//  CommandBase.swift
//  
//
//  Created by Yume on 2021/2/2.
//

import struct SourceKittenFramework.Module

import enum TypeFillKit.Logger
import struct TypeFillKit.Rewrite
import protocol TypeFillKit.Configable
import protocol TypeFillKit.CompilerArgumentsGettable

protocol CommandBase: Configable {}

protocol CommandBuild: CommandBase {
    var skipBuild: Bool { get }
    
    var isIndexStoreExist: Bool { get }
    var buildSetting: CompilerArgumentsGettable? { get }
    
    var buildModule: Module? { get }
    var skipBuildModule: Module? { get }
}

extension CommandBuild {
    var module: Module? {
        let _buildSetting = self.buildSetting
        guard _buildSetting != nil, self.skipBuild && isIndexStoreExist else {
            if !isIndexStoreExist {
                Swift.print("can't find index store db, force build")
                return self.buildModule
            }
            
            if _buildSetting == nil {
                Swift.print("can't get build arguments, force build")
            }
            
            // build
            return self.buildModule
        }
        
        // skip build
        return self.skipBuildModule
    }
    
    func scan() throws {
        guard let module: Module = self.module else {
            Swift.print("module or build setting not found, quit.")
            return
        }
        
        defer { Logger.summery() }
        Logger.set(logEvent: self.verbose)
        
        let all: Int = module.sourceFiles.count
        try module.sourceFiles.sorted().enumerated().forEach{ (index: Int, filePath: String) in
            Logger.add(event: .openFile(path: "[\(index + 1)/\(all)] \(filePath)"))
            // TODO: xcode arguments use `self.buildSetting`
            try Rewrite(path: filePath, arguments: module.compilerArguments, config: self).parse()
        }
    }
}
