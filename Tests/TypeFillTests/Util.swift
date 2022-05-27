//
//  Util.swift
//  TypeFillTests
//
//  Created by Yume on 2021/10/21.
//

import Foundation
import TypeFillKit
import SKClient

private let sourceFile: URL = URL(fileURLWithPath: #file)
    .deletingLastPathComponent()
    .appendingPathComponent("Resource")

func resource(file: String) -> String {
    return sourceFile.appendingPathComponent(file).path
}


struct Config: Configable {
    let print: Bool = true
    let verbose: Bool = false
}

@inline(__always)
func client(code: String, action: (SKClient) throws -> ()) throws {
    let client = try SKClient(code: code)
    _ = try client.editorOpen()
    try action(client)
    _ = try client.editorClose()
}

@inline(__always)
func rewriter(code: String, action: (String) throws -> ()) throws {
    try client(code: code) { client in
        let rewriter = try Rewrite(path: "", cursor: client, config: Config())
        try action(rewriter.dump())
    }
}
