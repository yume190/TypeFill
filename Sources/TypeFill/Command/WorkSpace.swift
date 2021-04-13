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
struct WorkSpace: ParsableCommand, CommandBase {
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
    
    @Argument(help: "Arguments passed to `xcodebuild` or `swift build`. If `-` prefixed argument exists, place ` -- ` before that.")
    var args: [String] = []
    
    func run() throws {
        let newArgs: [String] = [
            "-workspace",
            workspace,
            "-scheme",
            scheme,
        ]
        
        guard let module: Module = Module(xcodeBuildArguments: args + newArgs, name: nil) else {return}
        
        defer { Logger.summery() }
        Logger.set(logEvent: self.verbose)
        
        let all: Int = module.sourceFiles.count
        try module.sourceFiles.sorted().enumerated().forEach{ (index: Int, filePath: String) in
            Logger.add(event: .openFile(path: "[\(index + 1)/\(all)] \(filePath)"))
            try Rewrite(path: filePath, arguments: module.compilerArguments, config: self).parse()
        }
    }
}
