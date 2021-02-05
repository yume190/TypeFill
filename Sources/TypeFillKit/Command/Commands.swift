//
//  Command.swift
//  ArgumentParser
//
//  Created by Yume on 2020/3/10.
//

import Foundation
import ArgumentParser
import SourceKittenFramework

///-workspace SourceKitten.xcworkspace -scheme SourceKittenFramework
struct WorkSpaceCommand: ParsableCommand, CommandBase {
    static var configuration = CommandConfiguration(
        commandName: "xcode",
        abstract: "doc single file"
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
    
    @Argument(help: "Arguments passed to `xcodebuild` or `swift build`. If `-` prefixed argument exists, place ` -- ` before that.")
    var args: [String]
    
    @Argument(help: "")
    var workspace: String
    
    @Argument(help: "")
    var scheme: String
    
    func run() throws {
        let newArgs = [
            "-workspace",
            workspace,
            "-scheme",
            scheme,
        ]
        
        let module: Module? = Module(xcodeBuildArguments: args + newArgs, name: nil)
//        guard let docs = module?.docs else {
//            throw SourceKittenError.docFailed
//        }
        try module?.sourceFiles.forEach{ (filePath) in
            guard let file = File(path: filePath) else {return}
            let url = URL(fileURLWithPath: filePath)
            let cursor: Cursor = .init(filePath: filePath, arguments: module?.compilerArguments ?? [])
            
            if self.print {
                try Rewriter2.parse(source: file.contents, cursor: cursor)
            } else {
                try Rewriter2.parse(url: url, cursor: cursor)
            }
        }
    }
}


//final class SwiftModuleCommand: CommandBase {
//    static var configuration = CommandConfiguration(
//        commandName: "single",
//        abstract: "doc single file"
//    )
//
//    @Argument(help: "")
//    var moduleName: String
//
//    func run() throws {
//        let module: Module? = Module(xcodeBuildArguments: args, name: moduleName)
//        guard let docs = module?.docs else {
//            throw SourceKittenError.docFailed
//        }
//
//        try self.rewrite(rewriter: rewriter, docsList: docs)
//    }
//}
