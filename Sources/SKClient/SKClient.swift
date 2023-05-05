//
//  SKClient.swift
//  SKClient
//
//  Created by Yume on 2021/2/5.
//

import Foundation
import SwiftSyntax
import SwiftParser
import SourceKittenFramework

public struct SKClient {
    /// file path or temp path.
    public let path: String
    /// snapshot code by ``path``.
    public let code: String
    public let arguments: [String]
    public let sourceFile: SourceFileSyntax
    public let converter: SourceLocationConverter
    
    public init(path: String, sdk: SDK = .macosx) throws {
        let arguments: [String] = sdk.pathArgs + [path]
        try self.init(path: path, arguments: arguments)
    }
    
    public init(path: String, arguments: [String]) throws {
        let code = try String(contentsOfFile: path, encoding: .utf8)
        self.init(path: path, code: code, arguments: arguments)
    }
    
    private static let codePath = "code: /temp.swift"
    public init(code: String, sdk: SDK = .macosx) {
        let arguments: [String] = sdk.pathArgs
        self.init(path: Self.codePath, code: code, arguments: arguments + [Self.codePath])
    }

    public init(code: String, arguments: [String]) {
        self.init(path: Self.codePath, code: code, arguments: arguments + [Self.codePath])
    }
    
    public init(path: String, code: String, arguments: [String]) {
        self.path = path
        self.code = code
        self.arguments = arguments
        self.sourceFile = Parser.parse(source: code)
        self.converter = SourceLocationConverter(file: path, tree: sourceFile)
    }
    
    // MARK: SK Response
    @discardableResult
    public func callAsFunction(_ offset: Int) throws -> SourceKitResponse {
        return try self.cursorInfo(offset)
    }
    
    @discardableResult
    public func callAsFunction<Syntax: SyntaxProtocol>(_ syntax: Syntax) throws -> SourceKitResponse {
        return try self.cursorInfo(syntax.positionAfterSkippingLeadingTrivia.utf8Offset)
    }
    
    // MARK: code location
    public func callAsFunction(offset syntax: SyntaxProtocol) -> SwiftSyntax.SourceLocation {
        return self.converter.location(for: syntax.positionAfterSkippingLeadingTrivia)
    }
    
    public func callAsFunction(location syntax: SyntaxProtocol) -> CodeLocation {
        return CodeLocation(path: path, location: self(offset: syntax), syntax: syntax)
    }
}

// MARK: SourceKit Command
extension SKClient {
    public func cursorInfo(_ offset: Int) throws -> SourceKitResponse {
        let raw: [String : SourceKitRepresentable] = try Request.customRequest(request: [
            "key.request": UID("source.request.cursorinfo"),
            "key.name": path,
            "key.sourcefile": path,
            "key.sourcetext": code,
            "key.offset": Int64(offset),
            "key.compilerargs": arguments

        ]).send()
        return SourceKitResponse(raw)
    }
    
//    @discardableResult
//    public func cursorInfo(_ offset: Int) throws -> SourceKitResponse {
//        let raw: [String : SourceKitRepresentable] = try Request.cursorInfo(file: path, offset: ByteCount(offset), arguments: arguments).send()
//        return SourceKitResponse(raw)
//    }
    
    @discardableResult
    public func index() throws -> SourceKitResponse {
        let raw: [String : SourceKitRepresentable] = try Request.index(file: path, arguments: arguments).send()
        return SourceKitResponse(raw)
    }
    
    @discardableResult
    public func editorOpen() throws -> SourceKitResponse {
        let raw: [String : SourceKitRepresentable] = try Request.customRequest(request: [
            "key.request": UID("source.request.editor.open"),
            "key.name": path,
            "key.sourcetext": code,
            "keys.compilerargs": arguments
        ]).send()
        return SourceKitResponse(raw)
    }
    
//    public func editorOpen() throws -> SourceKitResponse{
//        let raw: [String : SourceKitRepresentable] = try Request.editorOpen(file: File(path: path)!).send()
//        return SourceKitResponse(raw)
//    }

    @discardableResult
    public func editorClose() throws -> SourceKitResponse {
        let raw: [String : SourceKitRepresentable] = try Request.customRequest(request: [
            "key.request": UID("source.request.editor.close"),
            "key.name": path,
//            "key.sourcefile": path,
//            "keys.compilerargs": arguments
        ]).send()
        return SourceKitResponse(raw)
    }
    
    @discardableResult
    public func docInfo() throws -> SourceKitResponse {
        let text: String = try String(contentsOf: URL(fileURLWithPath: path))
        let raw: [String : SourceKitRepresentable] = try Request.docInfo(text: text, arguments: arguments).send()
        return SourceKitResponse(raw)
    }
}
