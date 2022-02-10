//
//  XCode.swift
//  TypeFill
//
//  Created by Yume on 2021/10/18.
//

import Foundation
import ArgumentParser
import SourceKittenFramework
import SwiftLeakCheck
import LeakDetectExtension
import Cursor
import Derived
import Rainbow

struct Command: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        // commandName: "xcode",
        abstract: "A Tool to Detect Potential Leaks",
        discussion: """
        \(Env.discussion)
        
        Mode:
         * assign: detect assign instance function `x = self.func` or `y(self.func)`.
         * capture: detect `self` capture in closure.
        """,
        version: "0.2.6"
    )
    
    @Flag(name: [.customLong("verbose", withSingleDash: false), .short], help: "print inpect time")
    var verbose: Bool = false
    
    @Option(name: [.customLong("mode", withSingleDash: false)], help: "[\(Mode.all)]")
    var mode: Mode = .assign
    
    @Option(name: [.customLong("reporter", withSingleDash: false)], help: "[\(Mode.all)]")
    var reporter: Reporter = .vscode
    
    typealias LeakCount = Int
    private func assignMode(module: Module, filePath: String) throws -> LeakCount {
        let cursor = try Cursor(path: filePath, arguments: module.compilerArguments)
        let visitor = AssignClosureVisitor(cursor, verbose)
        
        try cursor.editorOpen()
        let leaks = visitor.detect()
        leaks.forEach(reporter.report)
        try cursor.editorClose()
        return leaks.count
    }
    
    private func captureMode(module: Module, filePath: String) throws -> LeakCount {
        let cursor = try Cursor(path: filePath, arguments: module.compilerArguments)
        let detector = GraphLeakDetector()
        let leaks = detector.detect(cursor)
        leaks.forEach(reporter.report)
        return leaks.count
    }
    
    func run() throws {
        try Env.prepare { projectRoot, moduleName, args in
            let module: Module = Module(name: moduleName, compilerArguments: args)
            
            var leakCount: LeakCount = 0
            defer {
                if leakCount == 0 {
                    print("Congratulation no leak found".green)
                } else {
                    print("Found \(leakCount) leaks".red)
                }
            }
            
            let all: Int = module.sourceFiles.count
            try module.sourceFiles.sorted().enumerated().forEach{ (index: Int, filePath: String) in
                print("\("[SCAN FILE]:".applyingCodes(Color.yellow, Style.bold)) [\(index + 1)/\(all)] \(filePath)")
                switch mode {
                case .assign:
                    leakCount += try assignMode(module: module, filePath: filePath)
                case .capture:
                    leakCount += try captureMode(module: module, filePath: filePath)
                }
            }
        }
    }
}

extension Command {
    enum Mode: String, CaseIterable, ExpressibleByArgument {
        case assign
        case capture
        
        static let all = Mode
            .allCases
            .map(\.rawValue)
            .joined(separator: "|")
    }
}

extension Reporter:  ExpressibleByArgument {
    static let all = Reporter
        .allCases
        .map(\.rawValue)
        .joined(separator: "|")
}

Command.main()
