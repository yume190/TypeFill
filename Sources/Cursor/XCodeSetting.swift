//
//  XCodeSetting.swift
//  TypeFillTests
//
//  Created by Yume on 2021/10/21.
//

import Foundation
import SourceKittenFramework
import Yams

public enum XCodeSetting {}

// https://github.com/jpsim/SourceKitten/blob/master/Source/SourceKittenFramework/Xcode.swift
extension XCodeSetting {
    public static func checkNewBuildSystem(in projectTempRoot: String, moduleName: String? = nil) -> [String]? {
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
    
    private static func partiallyFilter(arguments args: [String]) -> ([String], Bool) {
        guard let indexOfFlagToRemove: Int = args.firstIndex(of: "-output-file-map") else {
            return (args, false)
        }
        var args: [String] = args
        args.remove(at: args.index(after: indexOfFlagToRemove))
        args.remove(at: indexOfFlagToRemove)
        return (args, true)
    }

    private static func filter(arguments args: [String]) -> [String] {
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
