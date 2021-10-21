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
        let arguments = sdk.pathArgs + [path]
        try self.init(path: path, arguments: arguments)
    }
    
    public init(path: String, arguments: [String]) throws {
        self.path = path
        self.arguments = arguments
        let url: URL = URL(fileURLWithPath: path)
        self.sourceFile = try SyntaxParser.parse(url)
        self.converter = SourceLocationConverter(file: path, tree: sourceFile)
    }
    
    public func callAsFunction(_ offset: Int) throws -> SourceKitResponse {
        let raw: [String : SourceKitRepresentable] = try Request.cursorInfo(file: path, offset: ByteCount(offset), arguments: arguments).send()
        return SourceKitResponse(raw)
    }
    
    public func callAsFunction<Syntax: SyntaxProtocol>(_ syntax: Syntax) throws -> SourceKitResponse {
        return try self(syntax.positionAfterSkippingLeadingTrivia.utf8Offset)
    }
    
    public func callAsFunction<Syntax: SyntaxProtocol>(offset syntax: Syntax) -> SwiftSyntax.SourceLocation {
        return self.converter.location(for: syntax.positionAfterSkippingLeadingTrivia)
    }
    
    public func callAsFunction<Syntax: SyntaxProtocol>(location syntax: Syntax) -> CodeLocation {
        return CodeLocation(path: path, location: self(offset: syntax))
    }
}
