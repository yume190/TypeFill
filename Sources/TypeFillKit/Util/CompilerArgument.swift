//
//  CompilerArgument.swift
//  TypeFillKit
//
//  Created by Yume on 2021/4/23.
//

import Foundation
import Cursor

public protocol CompilerArgumentsGettable {
    func callAsFunction(_ path: String) -> [String]
    var `default`: [String] { get }
}

extension Array: CompilerArgumentsGettable where Element == String {
    public func callAsFunction(_ path: String) -> [String] {
        return self
    }
    public var `default`: [String] {
        return self
    }
}

public enum CompilerArguments {
    final class ByFile: CompilerArgumentsGettable {
        let arguments: [String: [String]]
        init(_ arguments: [String: [String]]) {
            self.arguments = arguments
        }
        func callAsFunction(_ path: String) -> [String] {
            return self.arguments[path] ?? []
        }
        var `default`: [String] {
            return arguments.first?.value ?? []
        }
        
        /// arguments: -project TypeFill.xcodeproj/ -scheme TypeFill -showBuildSettingsForIndex
        /**
         {
             "/Users/yume/git/yume/TypeFill/Sources/TypeFill/Command/WorkSpace.swift" : {
                "swiftASTCommandArguments" : [
                    "-module-name",
                    "TypeFill",
                ]
             }
         }
        */
        fileprivate struct BuildSettings: Codable {
            let swiftASTCommandArguments: [String]?
        }
        
        fileprivate static func buildSettings(name: String, arguments: [String]) throws -> [String: [String]] {
            let newArguments: [String] = arguments + ["-showBuildSettingsForIndex", "-json"]
            let data: Data = Exec.run("/usr/bin/xcodebuild", newArguments).data
            let decoder: JSONDecoder = JSONDecoder()
            
            
            let result: [String: [String: CompilerArguments.ByFile.BuildSettings]] = try decoder.decode([String: [String: BuildSettings]].self, from: data)
            return result[name]?.compactMapValues(\.swiftASTCommandArguments) ?? [:]
        }
    }
}

extension CompilerArguments {
//    public static func byModule(compilerArguments: [String]) -> CompilerArgumentsGettable {
//        return CompilerArguments.ByModule(compilerArguments)
//    }
    
    static func byFile(compilerArguments: [String: [String]]) -> CompilerArgumentsGettable {
        return CompilerArguments.ByFile(compilerArguments)
    }
    
    public static func byFile(name: String, arguments: [String]) -> CompilerArgumentsGettable? {
        guard let settings: [String: [String]] = try? CompilerArguments.ByFile.buildSettings(name: name, arguments: arguments) else { return nil }
        guard !settings.isEmpty else { return nil }
        return self.byFile(compilerArguments: settings)
    }
}
