//
//  Cursor.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/5.
//

import Foundation
import SwiftSyntax
import SourceKittenFramework

public struct Cursor {
    public let path: String
    public let arguments: [String]
    public let sourceFile: SourceFileSyntax
    public let converter: SourceLocationConverter
    
    
    public init(path: String, sdk: SDK = .macosx) throws {
        let arguments: [String] = sdk.pathArgs + [path]
        try self.init(path: path, arguments: arguments)
    }
    
    public init(path: String, arguments: [String]) throws {
        self.path = path
        self.arguments = arguments
        let url: URL = URL(fileURLWithPath: path)
        self.sourceFile = try SyntaxParser.parse(url)
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
    public func callAsFunction<Syntax: SyntaxProtocol>(offset syntax: Syntax) -> SwiftSyntax.SourceLocation {
        return self.converter.location(for: syntax.positionAfterSkippingLeadingTrivia)
    }
    
    public func callAsFunction<Syntax: SyntaxProtocol>(location syntax: Syntax) -> CodeLocation {
        return CodeLocation(path: path, location: self(offset: syntax))
    }
    
    // MARK: SourceKit Command
    @discardableResult
    public func cursorInfo(_ offset: Int) throws -> SourceKitResponse {
        let raw: [String : SourceKitRepresentable] = try Request.cursorInfo(file: path, offset: ByteCount(offset), arguments: arguments).send()
        return SourceKitResponse(raw)
    }
    
    @discardableResult
    public func index() throws -> SourceKitResponse {
        let raw: [String : SourceKitRepresentable] = try Request.index(file: path, arguments: arguments).send()
        return SourceKitResponse(raw)
    }
    
    @discardableResult
    public func editorOpen() throws -> SourceKitResponse{
        let raw: [String : SourceKitRepresentable] = try Request.editorOpen(file: File(path: path)!).send()
        return SourceKitResponse(raw)
    }

    @discardableResult
    public func editorClose() throws -> SourceKitResponse {
        let raw: [String : SourceKitRepresentable] = try Request.customRequest(request: [
            "key.request": UID("source.request.editor.close"),
            "key.name": path,
            "key.sourcefile": path
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
