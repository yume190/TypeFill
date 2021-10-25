//
//  XCode.swift
//  TypeFill
//
//  Created by Yume on 2021/10/18.
//

import Foundation
import ArgumentParser
import SourceKittenFramework
import TypeFillKit
import Cursor

struct XCode: ParsableCommand, Configable {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "xcode",
        abstract: "Fill type to XCode",
        discussion: Env.discussion
    )
    
    @Flag(name: [.customLong("print", withSingleDash: false)], help: "print fixed code, if false it will overwrite source file")
    var print: Bool = false
    
    @Flag(name: [.customLong("verbose", withSingleDash: false), .short], help: "print fix item")
    var verbose: Bool = false
    
    func run() throws {
        try Env.prepare { projectRoot, moduleName, args in
            let module: Module = Module(name: moduleName, compilerArguments: args)
            
            defer { Logger.summery() }
            Logger.set(logEvent: self.verbose)
            
            let all: Int = module.sourceFiles.count
            try module.sourceFiles.sorted().enumerated().forEach{ (index: Int, filePath: String) in
                Logger.add(event: .openFile(path: "[\(index + 1)/\(all)] \(filePath)"))
                try Rewrite(path: filePath, arguments: module.compilerArguments, config: self).parse()
            }
        }
    }
}
