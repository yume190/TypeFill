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
        let (_module, _arguments): (Module?, CompilerArgumentsGettable?) = self.moduleArguments
        guard let module: Module = _module, let arguments: CompilerArgumentsGettable = _arguments else {return}
        
        defer { Logger.summery() }
        Logger.set(logEvent: self.verbose)
        
        let all: Int = module.sourceFiles.count
        try module.sourceFiles.sorted().enumerated().forEach{ (index: Int, filePath: String) in
            Logger.add(event: .openFile(path: "[\(index + 1)/\(all)] \(filePath)"))
            try Rewrite(path: filePath, arguments: arguments, config: self).parse()
        }
    }
    
    private var moduleArguments: (Module?, CompilerArgumentsGettable?) {
        let path = URL(fileURLWithPath: workspace).path
        let isIndexStoreExist = DerivedPath(path)?.indexStorePath != nil
        let compilerArguments = CompilerArguments.byFile(name: scheme, arguments: self.xcodeBuildArguments)
        
        guard let _compilerArguments = compilerArguments, self.skipBuild && isIndexStoreExist else {
            if !isIndexStoreExist {
                Swift.print("can't find index bstore db, force build")
            }
            
            if compilerArguments == nil {
                Swift.print("can't get build arguments, force build")
            }
            
            // build
            let module = Module(xcodeBuildArguments: xcodeBuildArguments, name: nil)
            return (module, module?.compilerArgumentsGettable)
        }
        
        // skip build
        let module = Module(name: self.scheme, compilerArguments: _compilerArguments.default)
        return (module, _compilerArguments)
    }
}
