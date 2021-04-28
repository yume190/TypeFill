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

struct SPMModule: ParsableCommand, CommandBuild {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "spm",
        abstract: "Fill type to SPM Project."
    )
    
    @Flag(name: [.customLong("print", withSingleDash: false)], help: "print fixed code, if false it will overwrite source file")
    var print: Bool = false
    
    @Flag(name: [.customLong("verbose", withSingleDash: false), .short], help: "print fix item")
    var verbose: Bool = false
    
    @Option(name: [.customLong("moduleName", withSingleDash: false)], help: "spm target name")
    var moduleName: String
    
    @Option(name: [.customLong("path", withSingleDash: false)], help: "path to spm dir")
    var path: String = "."
    
    @Flag(name: [.customLong("skipBuild", withSingleDash: false)], help: "skip build")
    var skipBuild: Bool = false
    
    @Argument(help: "Arguments passed to `xcodebuild` or `swift build`. If `-` prefixed argument exists, place ` -- ` before that.")
    var args: [String] = []
    
    func run() throws {
        guard let module: Module = self.module else {
            Swift.print("module or build setting not found, quit.")
            return
        }
        
        defer { Logger.summery() }
        Logger.set(logEvent: self.verbose)
        
        let all: Int = module.sourceFiles.count
        try module.sourceFiles.sorted().enumerated().forEach{ (index: Int, filePath: String) in
            Logger.add(event: .openFile(path: "[\(index + 1)/\(all)] \(filePath)"))
            try Rewrite(path: filePath, arguments: module.compilerArgumentsGettable, config: self).parse()
        }
    }
    
    private var module: Module? {
        let isIndexStoreExist = DerivedPath.SPM(URL(fileURLWithPath: path).path)?.indexStorePath != nil
        
        guard self.skipBuild && isIndexStoreExist else {
            if !isIndexStoreExist {
                Swift.print("can't find index store db, force build")
            }
            
            // build
            return Module(spmArguments: args, spmName: moduleName, inPath: path)
        }
        
        // skip build
        return Module(spmName: moduleName, inPath: path)
    }
}
