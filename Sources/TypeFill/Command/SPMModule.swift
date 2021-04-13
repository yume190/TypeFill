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

//print(FileManager.default.currentDirectoryPath)
//let path = URL(fileURLWithPath: "/Users/yume/git/yume/TypeFill")
//let p2 = path
//    .appendingPathComponent(".build")
//    .appendingPathComponent("debug")
//    .appendingPathComponent("index")
//    .appendingPathComponent("store")
//    .path

struct SPMModule: ParsableCommand, CommandBase {
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
    
    @Argument(help: "Arguments passed to `xcodebuild` or `swift build`. If `-` prefixed argument exists, place ` -- ` before that.")
    var args: [String] = []
    
    func run() throws {
        guard let module: Module = Module(spmArguments: args, spmName: moduleName) else {return}
        
        defer { Logger.summery() }
        Logger.set(logEvent: self.verbose)
        
        let all: Int = module.sourceFiles.count
        try module.sourceFiles.sorted().enumerated().forEach{ (index: Int, filePath: String) in
            Logger.add(event: .openFile(path: "[\(index + 1)/\(all)] \(filePath)"))
            try Rewrite(path: filePath, arguments: module.compilerArguments, config: self).parse()
        }
    }
}
