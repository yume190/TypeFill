//
//  CompilerArgument.swift
//  TypeFillKit
//
//  Created by Yume on 2021/4/23.
//

import Foundation
import SourceKittenFramework

public protocol CompilerArgumentsGettable: AnyObject {
    func callAsFunction(_ path: String) -> [String]
}

public enum CompilerArguments {
    final class ByModule: CompilerArgumentsGettable {
        let arguments: [String]
        init(_ arguments: [String]) {
            self.arguments = arguments
        }
        func callAsFunction(_ path: String) -> [String] {
            return arguments
        }
    }
    
    final class ByFile: CompilerArgumentsGettable {
        let arguments: [String: [String]]
        init(_ arguments: [String: [String]]) {
            self.arguments = arguments
        }
        func callAsFunction(_ path: String) -> [String] {
            return self.arguments[path] ?? []
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
            let newArguments = arguments + ["-showBuildSettingsForIndex", "-json"]
            let data = Exec.run("/usr/bin/xcodebuild", newArguments).data
            let decoder = JSONDecoder()
            
            
            let result = try decoder.decode([String: [String: BuildSettings]].self, from: data)
            return result[name]?.compactMapValues(\.swiftASTCommandArguments) ?? [:]
        }
    }
}

extension CompilerArguments {
    public static func byModule(compilerArguments: [String]) -> CompilerArgumentsGettable {
        return CompilerArguments.ByModule(compilerArguments)
    }
    
    static func byFile(compilerArguments: [String: [String]]) -> CompilerArgumentsGettable {
        return CompilerArguments.ByFile(compilerArguments)
    }
    
    public static func byFile(name: String, arguments: [String]) -> CompilerArgumentsGettable? {
        guard let settings = try? CompilerArguments.ByFile.buildSettings(name: name, arguments: arguments) else {return nil}
        guard !settings.isEmpty else {return nil}
        return self.byFile(compilerArguments: settings)
    }
}

extension Module {
    public var compilerArgumentsGettable: CompilerArgumentsGettable {
        return CompilerArguments.ByModule(self.compilerArguments)
    }
}
