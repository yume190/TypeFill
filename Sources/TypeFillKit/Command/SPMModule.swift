//
//  SPM.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/5.
//

import Foundation
import ArgumentParser
import SourceKittenFramework

struct SPMModule: ParsableCommand, CommandBase {
    static var configuration = CommandConfiguration(
        commandName: "spm",
        abstract: "SPM Project"
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
    var moduleName: String
    
    func run() throws {
        let module = Module(spmArguments: args, spmName: moduleName)
//        guard let docs = Module(spmArguments: args, spmName: moduleName)?.docs else {
//            throw SourceKittenError.docFailed
//        }
//        try self.rewrite(rewriter: rewriter, docsList: docs)
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
