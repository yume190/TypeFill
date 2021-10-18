//
//  XCode.swift
//  TypeFill
//
//  Created by Yume on 2021/10/18.
//

import Foundation
import ArgumentParser
import SourceKittenFramework
import TypeFillKit
import Yams

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

struct XCode: ParsableCommand, Configable {
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "xcode",
        abstract: "Fill type to XCode",
        discussion: """
        Needed Environment Variable:
         * `PROJECT_TEMP_ROOT`
         * `TARGET_NAME`
        
        Example:
        `PROJECT_TEMP_ROOT`="/PATH_TO/DerivedData/TypeFill-abpidkqveyuylveyttvzvsspldln/Build/Intermediates.noindex"
        `TARGET_NAME`="Typefill"
        """
    )
    
    @Flag(name: [.customLong("print", withSingleDash: false)], help: "print fixed code, if false it will overwrite source file")
    var print: Bool = false
    
    @Flag(name: [.customLong("verbose", withSingleDash: false), .short], help: "print fix item")
    var verbose: Bool = false
    
    func run() throws {
        guard let projectTempRoot: String = Env.projectTempRoot.value else {
            Swift.print("Env `PROJECT_TEMP_ROOT` not found, quit.");return
        }
        
        guard let moduleName: String = Env.targetName.value else {
            Swift.print("Env `TARGET_NAME` not found, quit.");return
        }
        
        guard let args: [String] = checkNewBuildSystem(in: projectTempRoot, moduleName: moduleName) else {
            Swift.print("Build Setting not found, quit.");return
        }
        
        let module: Module = Module(name: moduleName, compilerArguments: args)
        
        defer { Logger.summery() }
        Logger.set(logEvent: self.verbose)
        
        let all: Int = module.sourceFiles.count
        try module.sourceFiles.sorted().enumerated().forEach{ (index: Int, filePath: String) in
            Logger.add(event: .openFile(path: "[\(index + 1)/\(all)] \(filePath)"))
            try Rewrite(path: filePath, arguments: module.compilerArguments, config: self).parse()
        }
    }
}

// https://github.com/jpsim/SourceKitten/blob/master/Source/SourceKittenFramework/Xcode.swift
extension XCode {
    private func checkNewBuildSystem(in projectTempRoot: String, moduleName: String? = nil) -> [String]? {
        let xcbuildDataURL: URL = URL(fileURLWithPath: projectTempRoot).appendingPathComponent("XCBuildData")

        do {
            // Find manifests in `PROJECT_TEMP_ROOT`
            let fileURLs: [URL] = try FileManager.default.contentsOfDirectory(at: xcbuildDataURL, includingPropertiesForKeys: [.fileSizeKey])
            let manifestURLs: [URL] = try fileURLs.filter { $0.path.hasSuffix("-manifest.xcbuild") }
                .map { (url: $0, size: try $0.resourceValues(forKeys: [.fileSizeKey]).fileSize ?? 0) }
                .sorted { $0.size < $1.size }
                .map { $0.url }
            let result: [String]? = manifestURLs.lazy.compactMap { (manifestURL: URL) -> [String]? in
                guard let contents: String = try? String(contentsOf: manifestURL),
                    let yaml: Node = try? Yams.compose(yaml: contents),
                    let commands: LazyMapCollection<Node.Mapping, Node> = (yaml as Node?)?["commands"]?.mapping?.values else {
                        return nil
                }
                for command in commands where command["description"]?.string?.hasSuffix("com.apple.xcode.tools.swift.compiler") ?? false {
                    if let args: Node.Sequence = command["args"]?.sequence,
                        let index: Node.Sequence.Index = args.firstIndex(of: "-module-name"),
                        moduleName != nil ? args[args.index(after: index)].string == moduleName : true {
                        let fullArgs: [String] = args.compactMap { $0.string }
                        let swiftCIndex: Int = fullArgs.firstIndex(of: "--").flatMap(fullArgs.index(after:)) ?? fullArgs.startIndex
                        return Array(fullArgs.suffix(from: fullArgs.index(after: swiftCIndex)))
                    }
                }
                return nil
            }.first.map { filter(arguments: $0) }

            if result != nil {
                fputs("Assuming New Build System is used.\n", stderr)
            }
            return result
        } catch {
            return nil
        }
    }
    
    private func partiallyFilter(arguments args: [String]) -> ([String], Bool) {
        guard let indexOfFlagToRemove: Array<String>.Index = args.firstIndex(of: "-output-file-map") else {
            return (args, false)
        }
        var args: [String] = args
        args.remove(at: args.index(after: indexOfFlagToRemove))
        args.remove(at: indexOfFlagToRemove)
        return (args, true)
    }

    private func filter(arguments args: [String]) -> [String] {
        var args: [String] = args
        args.append(contentsOf: ["-D", "DEBUG"])
        var shouldContinueToFilterArguments: Bool = true
        while shouldContinueToFilterArguments {
            (args, shouldContinueToFilterArguments) = partiallyFilter(arguments: args)
        }
        return args.filter {
            ![
                "-parseable-output",
                "-incremental",
                "-serialize-diagnostics",
                "-emit-dependencies"
            ].contains($0)
        }.map {
            if $0 == "-O" {
                return "-Onone"
            } else if $0 == "-DNDEBUG=1" {
                return "-DDEBUG=1"
            }
            return $0
        }
    }
}
