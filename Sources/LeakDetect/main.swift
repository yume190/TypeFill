//
//  XCode.swift
//  TypeFill
//
//  Created by Yume on 2021/10/18.
//

import Foundation
import ArgumentParser
import SourceKittenFramework
//import SwiftLeakCheck
import Cursor

/// PRODUCT_NAME=TypeFillKit
/// TARGET_NAME=TypeFillKit
/// TARGETNAME=TypeFillKit
/// PRODUCT_BUNDLE_IDENTIFIER=TypeFillKit
/// EXECUTABLE_NAME=TypeFillKit
/// PRODUCT_MODULE_NAME=TypeFillKit
fileprivate enum Env: String {
    case projectTempRoot = "PROJECT_TEMP_ROOT"
    case targetName = "TARGET_NAME"
    
    private static let processInfo: ProcessInfo = ProcessInfo()
    
    var value: String? {
        return Self.processInfo.environment[self.rawValue]
    }
}

struct Command: ParsableCommand {
    static var configuration: CommandConfiguration = CommandConfiguration(
        // commandName: "xcode",
        abstract: "A Tool to Detect Potential Leaks",
        discussion: """
        Needed Environment Variable:
         * `PROJECT_TEMP_ROOT`
         * `TARGET_NAME`
        
        Example:
        `PROJECT_TEMP_ROOT`="/PATH_TO/DerivedData/TypeFill-abpidkqveyuylveyttvzvsspldln/Build/Intermediates.noindex"
        `TARGET_NAME`="Typefill"
        """,
        version: "0.2.0"
    )
    
    func run() throws {
        guard let projectTempRoot: String = Env.projectTempRoot.value else {
            Swift.print("Env `PROJECT_TEMP_ROOT` not found, quit.");return
        }

        guard let moduleName: String = Env.targetName.value else {
            Swift.print("Env `TARGET_NAME` not found, quit.");return
        }
        
        guard let args: [String] = XCodeSetting.checkNewBuildSystem(in: projectTempRoot, moduleName: moduleName) else {
            Swift.print("Build Setting not found, quit.");return
        }
        
        let module: Module = Module(name: moduleName, compilerArguments: args)
        
        let all: Int = module.sourceFiles.count
        try module.sourceFiles.sorted().enumerated().forEach{ (index: Int, filePath: String) in
            Swift.print("scan file[\(index + 1)/\(all)]: \(filePath)")
            
            let cursor = try Cursor(path: filePath, arguments: module.compilerArguments)
            let visitor = AssignClosureVisitor(cursor)
            
            visitor.detect().forEach { location in
                Swift.print(location)
            }
            
//            let detector = GraphLeakDetector()
//            let cursor = try Cursor(path: filePath, arguments: module.compilerArguments)
//            let leaks = detector.detect(cursor)
//            leaks.forEach { leak in
//                Swift.print("\(filePath):\(leak.description)")
//            }
        }
    }
}

Command.main()
