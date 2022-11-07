//
//  CodeLocation.swift
//  TypeFillTests
//
//  Created by Yume on 2021/10/21.
//

import Foundation
import SwiftSyntax
import Rainbow

public struct CodeLocation: CustomStringConvertible, Equatable {
    public let path: String
    public let location: SwiftSyntax.SourceLocation
    public let syntax: SyntaxProtocol?
    
    public init(path: String, location: SwiftSyntax.SourceLocation, syntax: SyntaxProtocol? = nil) {
        self.path = path
        self.location = location
        self.syntax = syntax
    }
    
    public var description: String {
        return "\(path):\(location) \(syntax?.withoutTrivia().description ?? "")"
    }
    
    public static func == (lhs: CodeLocation, rhs: CodeLocation) -> Bool {
        return
            lhs.path == rhs.path &&
            lhs.location.offset == rhs.location.offset
    }
}

extension CodeLocation: Reportable {
    /// /path/to/xxx.swift:line:column: warning: desc
    public var reportXCode: String {
        return "\(path):\(location): warning: \(syntax?.withoutTrivia().description ?? "")"
    }
    
    /// /path/to/xxx.swift:line:column desc
    public var reportVSCode: String {
        return self.description.red
    }
}
