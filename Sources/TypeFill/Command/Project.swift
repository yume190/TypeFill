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

//sourcekitten doc --module-name Alamofire -- -project Alamofire.xcodeproj
///-workspace SourceKitten.xcworkspace -scheme SourceKittenFramework
struct Project: ParsableCommand, CommandBase {
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
    
    @Option(name: [.customLong("scheme", withSingleDash: false)], help: "scheme")
    var scheme: String
    
    @Argument(help: "Arguments passed to `xcodebuild` or `swift build`. If `-` prefixed argument exists, place ` -- ` before that.")
    var args: [String] = []
    
    func run() throws {
        let newArgs: [String] = [
            "-project",
            project,
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
