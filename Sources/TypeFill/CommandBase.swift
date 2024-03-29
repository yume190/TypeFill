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
import SKClient

protocol BuildConfigable {
    var skipBuild: Bool { get }
}

typealias Config = BuildConfigable & Configable
protocol CommandBuild {
    var config: Config { get }
    
    var isIndexStoreExist: Bool { get }
    var buildSetting: CompilerArgumentsGettable? { get }
    
    var buildModule: Module? { get }
    var skipBuildModule: Module? { get }
}

extension CommandBuild {
    var module: Module? {
        let _buildSetting = self.buildSetting
        guard _buildSetting != nil, self.config.skipBuild && isIndexStoreExist else {
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
        Logger.set(logEvent: self.config.verbose)
        
        let all: Int = module.sourceFiles.count
        try module.sourceFiles.sorted().enumerated().forEach{ (index: Int, filePath: String) in
            Logger.add(event: .openFile(path: "[\(index + 1)/\(all)] \(filePath)"))
            
            let cursor: SKClient = try SKClient(path: filePath, arguments: module.compilerArguments)
            
            try cursor.editorOpen()
            defer {
                _ = try? cursor.editorClose()
            }
            
            // TODO: xcode arguments use `self.buildSetting`
            try Rewrite(path: filePath, cursor: cursor, config: config).parse()
        }
    }
}
