//
//  File.swift
//
//
//  Created by Tangram Yume on 2024/1/17.
//

import SwiftSyntax
import SwiftParser

public final class SourceConverter {
  public let path: String
  public let sourceFile: SourceFileSyntax
  public let converter: SourceLocationConverter
  
  public init(path: String, code: String) {
    self.path = path
    self.sourceFile = Parser.parse(source: code)
    self.converter = SourceLocationConverter(fileName: path, tree: sourceFile)
  }
  
  public init(path: String, sourceFile: SourceFileSyntax) {
    self.path = path
    self.sourceFile = sourceFile
    self.converter = SourceLocationConverter(fileName: path, tree: sourceFile)
  }
  
  public convenience init(path: String) throws {
    let code = try String(contentsOfFile: path, encoding: .utf8)
    self.init(path: path, code: code)
  }
  
  public func sourceLocation(_ syntax: SyntaxProtocol) -> SwiftSyntax.SourceLocation {
    return self.converter.location(for: syntax.positionAfterSkippingLeadingTrivia)
  }
  
  public func codeLocation(_ syntax: SyntaxProtocol) -> CodeLocation {
    return CodeLocation(path: path, location: sourceLocation(syntax), syntax: syntax)
  }
}
