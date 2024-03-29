//
//  Env.swift
//  Cursor
//
//  Created by Yume on 2021/10/22.
//

import Foundation
import Derived

/// PRODUCT_NAME=TypeFillKit
/// TARGET_NAME=TypeFillKit
/// TARGETNAME=TypeFillKit
/// PRODUCT_BUNDLE_IDENTIFIER=TypeFillKit
/// EXECUTABLE_NAME=TypeFillKit
/// PRODUCT_MODULE_NAME=TypeFillKit
public enum Env: String {
    case projectTempRoot = "PROJECT_TEMP_ROOT"
    case targetName = "TARGET_NAME"
    case projectPath = "PROJECT_PATH"
    
    private static let processInfo: ProcessInfo = ProcessInfo()
    
    public var value: String? {
        return Self.processInfo.environment[self.rawValue]
    }
    
    public static func prepare(_ completion: (String, String, [String]) throws -> ()) rethrows -> Void {
        let projectRoot: String
        if let projectTempRoot: String = Env.projectTempRoot.value {
            projectRoot = projectTempRoot
        } else if let path: String = Env.projectPath.value {
            guard let derived: DerivedPath = DerivedPath(path) else {
                Swift.print("Env `\(Env.projectPath.rawValue)` not found, quit.");exit(0)
            }
            guard derived.isExist() else {
                Swift.print("\(derived.path()) not found, quit.");exit(0)
            }
            
            projectRoot = derived.path() + "/Build/Intermediates.noindex"
        } else {
            Swift.print("Env `\(Env.projectTempRoot.rawValue)` not found, quit.");exit(0)
        }

        guard let moduleName: String = Env.targetName.value else {
            Swift.print("Env `\(Env.targetName.rawValue)` not found, quit.");exit(0)
        }
        
        guard let args: [String] = XCodeSetting.checkNewBuildSystem(in: projectRoot, moduleName: moduleName) else {
            Swift.print("Build Setting not found, quit.");exit(0)
        }
        
        try completion(projectRoot, moduleName, args)
    }
    
    public static let discussion: String = """
    Needed Environment Variable:
     * `\(Env.projectTempRoot.rawValue)`/`\(Env.projectPath.rawValue)`
     * `\(Env.targetName.rawValue)`
    
    Example:
    `\(Env.projectTempRoot.rawValue)`="/PATH_TO/DerivedData/TypeFill-abpidkqveyuylveyttvzvsspldln/Build/Intermediates.noindex"
    `\(Env.projectPath.rawValue)`="PATH_TO/xxx.xcodeproj" or "/PATH_TO/xxx.xcworkspace"
    `\(Env.targetName.rawValue)`="Typefill"
    """
}
