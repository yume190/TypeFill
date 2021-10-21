//
//  File.swift
//  
//
//  Created by Yume on 2021/2/4.
//

import Foundation
import ArgumentParser
import SourceKittenFramework
import TypeFillKit
import Cursor

extension SDK: ExpressibleByArgument {}

struct SingleFile: ParsableCommand, CommandBase {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "single",
        abstract: "Fill type to single file"
    )
    
    @Flag(name: [.customLong("print", withSingleDash: false)], help: "print fixed code, if false it will overwrite source file")
    var print: Bool = false
    
    @Flag(name: [.customLong("verbose", withSingleDash: false), .short], help: "print fix item")
    var verbose: Bool = false
    
    @Option(name: [.customLong("filePath", withSingleDash: false)], help: "absolute path")
    var filePath: String
    
    @Option(name: [.customLong("sdk", withSingleDash: false)], help: "[\(SDK.all)]")
    var sdk: SDK
    
    @Argument(help: "Arguments passed to `xcodebuild` or `swift build`. If `-` prefixed argument exists, place ` -- ` before that.")
    var args: [String] = []
    
    func run() throws {
        let arguments: [String] = args + [filePath] + sdk.pathArgs

        defer { Logger.summery() }
        Logger.set(logEvent: self.verbose)
        
        Logger.add(event: .openFile(path: "\(filePath)"))
        try Rewrite(
            path: filePath,
            arguments: arguments,
            config: self
        ).parse()
    }
}
