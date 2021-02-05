//
//  File.swift
//  
//
//  Created by Yume on 2021/2/4.
//

import Foundation
import ArgumentParser
import SourceKittenFramework

//final class
struct SingleFile: ParsableCommand, CommandBase {
    static var configuration = CommandConfiguration(
        commandName: "single",
        abstract: "single file"
    )
    
    @Flag(name: [.customLong("typefill", withSingleDash: false)], help: "add type to variable and constant")
    var typeFill: Bool = false
    @Flag(name: [.customLong("ibaction", withSingleDash: false)], help: "add private final attributes to IBAction")
    var ibaction: Bool = false
    @Flag(name: [.customLong("iboutlet", withSingleDash: false)], help: "add private final attributes to IBOutlet")
    var iboutlet: Bool = false
    @Flag(name: [.customLong("objc", withSingleDash: false)], help: "add private final attributes to objc")
    var objc: Bool = false
    
    @Flag(name: [.customLong("print", withSingleDash: false)], help: "print fixed code")
    var print: Bool = false
    
    @Option(name: [.customLong("filePath", withSingleDash: false)], help: "絕對路徑")
    var filePath: String
    
    @Argument(help: "Arguments passed to `xcodebuild` or `swift build`. If `-` prefixed argument exists, place ` -- ` before that.")
    var args: [String] = []
    
    func run() throws {
        let arguments = args + [filePath]
        guard
            let file = File(path: filePath),
            let _ = SwiftDocs(file: file, arguments: [filePath])
        else {
            throw SourceKittenError.readFailed(path: filePath)
        }
        
        defer { logger.log() }
        let url = URL(fileURLWithPath: filePath)
        let cursor: Cursor = .init(filePath: filePath, arguments: arguments)
        
        if self.print {
            try Rewriter2.parse(source: file.contents, cursor: cursor)
        } else {
            try Rewriter2.parse(url: url, cursor: cursor)
        }
    }
}
