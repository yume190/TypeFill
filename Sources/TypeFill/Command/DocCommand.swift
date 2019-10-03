//
//  DocCommand.swift
//  SourceKitten
//
//  Created by JP Simard on 2015-01-07.
//  Copyright (c) 2015 SourceKitten. All rights reserved.
//

import Commandant
import Result
import SourceKittenFramework
import Foundation

struct DocCommand: CommandProtocol {
    let verb: String = "doc"
    let function: String = "Print Swift or Objective-C docs as JSON"

    struct Options: OptionsProtocol {
        let singleFile: Bool
        let moduleName: String
        let spm: Bool
        let isFixIBAction: Bool
        let isFixIBOutlet: Bool
        let arguments: [String]

        static func create(singleFile: Bool) ->
            (_ moduleName: String) ->
            (_ spm: Bool) ->
            (_ spmModule: String) ->
            (_ isFixIBAction: Bool) ->
            (_ isFixIBOutlet: Bool) ->
            (_ arguments: [String]) -> Options {
                return { moduleName in { spm in { spmModule in { isFixIBAction in { isFixIBOutlet in { arguments in
                self.init(singleFile: singleFile,
                          moduleName: moduleName.isEmpty ? spmModule : moduleName,
                          spm: spm || !spmModule.isEmpty,
                          isFixIBAction: isFixIBAction,
                          isFixIBOutlet: isFixIBOutlet,
                          arguments: arguments
                )
                }}}}}}
        }

        static func evaluate(_ mode: CommandMode) -> Result<Options, CommandantError<SourceKittenError>> {
            return create
                <*> mode <| Option(key: "single-file", defaultValue: false,
                                   usage: "only document one file")
                <*> mode <| Option(key: "module-name", defaultValue: "",
                                   usage: "name of Swift module to document (can't be used with `--single-file`)")
                <*> mode <| Option(key: "spm", defaultValue: false,
                                   usage: "document a Swift Package Manager module")
                <*> mode <| Option(key: "spm-module", defaultValue: "",
                                   usage: "equivalent to --spm --module-name (string)")
                <*> mode <| Option(key: "ibaction", defaultValue: false,
                                   usage: "add private final attributes to IBAction")
                <*> mode <| Option(key: "iboutlet", defaultValue: false,
                                   usage: "add private final attributes to IBOutlet")
                <*> mode <| Argument(defaultValue: [],
                                     usage: "Arguments passed to `xcodebuild` or `swift build`. If `-` prefixed argument exists, place ` -- ` before that.")
        }
    }

    func run(_ options: Options) -> Result<(), SourceKittenError> {
        let args: [String] = options.arguments
        let moduleName: String? = options.moduleName.isEmpty ? nil : options.moduleName
        let builder = RewriterFactory.Builder.new.add(item: .typeFill)
        if options.isFixIBAction { builder.add(item: .ibAction) }
        if options.isFixIBOutlet { builder.add(item: .ibOutlet) }
        let rewriter: Rewriter = builder.build()
        if options.spm {
            return runSPMModule(rewriter: rewriter, moduleName: moduleName, args: args)
        } else if options.singleFile {
            return runSwiftSingleFile(rewriter: rewriter, args: args)
        }
        return runSwiftModule(rewriter: rewriter, moduleName: moduleName, args: args)
    }

    func runSPMModule(rewriter: Rewriter, moduleName: String?, args: [String]) -> Result<(), SourceKittenError> {
        if let docs = Module(spmArguments: args, spmName: moduleName)?.docs {
            return self.rewrite(rewriter: rewriter, docsList: docs)
        }
        return .failure(.docFailed)
    }

    func runSwiftModule(rewriter: Rewriter, moduleName: String?, args: [String]) -> Result<(), SourceKittenError> {
        let module: Module? = Module(xcodeBuildArguments: args, name: moduleName)

        if let docs = module?.docs {
            return self.rewrite(rewriter: rewriter, docsList: docs)
        }
        return .failure(.docFailed)
    }

    func runSwiftSingleFile(rewriter: Rewriter, args: [String]) -> Result<(), SourceKittenError> {
        if args.isEmpty {
            return .failure(.invalidArgument(description: "at least 5 arguments are required when using `--single-file`"))
        }
        let sourcekitdArguments: [String] = Array(args.dropFirst(1))
        if let file = File(path: args[0]),
            let docs = SwiftDocs(file: file, arguments: sourcekitdArguments) {
            defer { logger.log() }
            return self.rewrite(rewriter: rewriter, docs: docs)
        }
        return .failure(.readFailed(path: args[0]))
    }
}

extension DocCommand {
    func rewrite(rewriter: Rewriter, docsList: [SwiftDocs]) -> Result<(), SourceKittenError> {
        defer { logger.log() }
        return docsList.reduce(Result<(), SourceKittenError>.success(())) { (result: Result<(), SourceKittenError>, docs: SwiftDocs) -> Result<(), SourceKittenError> in
            if case .failure(_) = result {
                return result
            }
            return self.rewrite(rewriter: rewriter, docs: docs)
        }
    }

    func rewrite(rewriter: Rewriter, docs: SwiftDocs) -> Result<(), SourceKittenError> {
        do {
            guard let docsData = docs.description.utf8 else {
                return .failure(.utf8)
            }
            let decoder = JSONDecoder()

            let docsInfo = try decoder.decode(
                [String: SwiftDocInfo].self,
                from: docsData
            )
            return self.rewrite(rewriter: rewriter, docsInfo: docsInfo)
        } catch {
            return .failure(.jsonDecode(error))
        }
    }

    func rewrite(rewriter: Rewriter, docsInfo: [String: SwiftDocInfo]) -> Result<(), SourceKittenError> {
        return docsInfo.reduce(Result<(), SourceKittenError>.success(())) { (result: Result<(), SourceKittenError>, next: (path: String, doc: SwiftDocInfo)) -> Result<(), SourceKittenError> in
            if case .failure(_) = result { return result }
            do {
                logger.add(event: .openFile(path: next.path))
                let raw = try Data(contentsOf: URL(fileURLWithPath: next.path))
                guard let data = rewriter.rewrite(description: next.doc, raw: raw).string else {
                    return .failure(.utf8)
                }
                try data.write(toFile: next.path, atomically: true, encoding: .utf8)
                return .success(())
            } catch {
                print("[OPEN Error]: \(next.path)")
                print("[OPEN Error]: \(error)")
                return .failure(.failed(error))
            }
        }
    }
}
