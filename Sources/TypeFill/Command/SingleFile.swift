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
import SKClient

extension SDK: ExpressibleByArgument {}

struct SingleFile: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "single",
        abstract: "Fill type to single file"
    )
    
    @OptionGroup()
    var _config: ConfigOptions
    var config: Config {
        _config
    }
    
    @OptionGroup()
    var targetFile: TargetFileOptions
    
    @Option(name: [.customLong("sdk", withSingleDash: false)], help: "[\(SDK.all)]")
    var sdk: SDK
    
    func run() throws {
        let arguments: [String] = _config.args + [targetFile.path] + sdk.pathArgs

        defer { Logger.summery() }
        Logger.set(logEvent: config.verbose)
        
        
        Logger.add(event: .openFile(path: "\(targetFile.path)"))
        try Rewrite(
            path: targetFile.path,
            arguments: arguments,
            config: config
        ).parse()
    }
}
