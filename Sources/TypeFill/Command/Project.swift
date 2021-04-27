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

///-workspace SourceKitten.xcworkspace -scheme SourceKittenFramework
struct Project: ParsableCommand, CommandBuild {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "project",
        abstract: "Fill type to XCode project."
    )
    
    @Flag(name: [.customLong("print", withSingleDash: false)], help: "print fixed code, if false it will overwrite source file")
    var print: Bool = false
    
    @Flag(name: [.customLong("verbose", withSingleDash: false), .short], help: "print fix item")
    var verbose: Bool = false
    
    @Option(name: [.customLong("project", withSingleDash: false)], help: "absolute path of project")
    var project: String
    
    @Option(name: [.customLong("scheme", withSingleDash: false)], help: "xcode scheme")
    var scheme: String
    
    @Flag(name: [.customLong("skipBuild", withSingleDash: false)], help: "skip build")
    var skipBuild: Bool = false
    
    @Argument(help: "Arguments passed to `xcodebuild` or `swift build`. If `-` prefixed argument exists, place ` -- ` before that.")
    var args: [String] = []
    
    private var xcodeBuildArguments: [String] {
        let newArgs: [String] = [
            "-project",
            project,
            "-scheme",
            scheme,
        ]
        return args + newArgs
    }
    
    func run() throws {
        let (_module, _arguments) = self.moduleArguments
        guard let module: Module = _module, let arguments = _arguments else {return}

        defer { Logger.summery() }
        Logger.set(logEvent: self.verbose)

        let all: Int = module.sourceFiles.count
        try module.sourceFiles.sorted().enumerated().forEach { (index: Int, filePath: String) in
            Logger.add(event: .openFile(path: "[\(index + 1)/\(all)] \(filePath)"))
            try Rewrite(path: filePath, arguments: arguments, config: self).parse()
        }
    }
    
    private var moduleArguments: (Module?, CompilerArgumentsGettable?) {
        let path = URL(fileURLWithPath: project).path
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
        let module = Module(name: self.scheme, compilerArguments: [])
        return (module, _compilerArguments)
    }
}
