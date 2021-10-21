//
//  EscapeVisitor.swift
//  Cursor
//
//  Created by Yume on 2021/10/19.
//

import Foundation
import SwiftSyntax

/// typealias A = @escaping () -> Void
/// typealias B = (() -> Void)
/// typealias C = (() -> Void)?
/// find `escaping` from it's type
public final class TypeEscapeVisitor: SyntaxVisitor {
    private var isEscape: Bool = false

    public override func visit(_ node: TypeInitializerClauseSyntax) -> SyntaxVisitorContinueKind {
        return self.find(type: node.value) ?? .skipChildren
    }
    
    private final func find(type: TypeSyntax) -> SyntaxVisitorContinueKind? {
        /// X?
        if let wrapped = type.as(OptionalTypeSyntax.self)?.wrappedType {
            return find(type: wrapped)
        }
        
        /// @escaping Closure
        if let attrs = type.as(AttributedTypeSyntax.self)?.attributes {
            self.walk(attrs)
            return .skipChildren
        }
        
        /// (Closure)
        if
            let elements = type.as(TupleTypeSyntax.self)?.elements,
            let _ = elements.first?.type.as(FunctionTypeSyntax.self),
            elements.count == 1 {
            self.isEscape = true
            return .skipChildren
        }
        
        return nil
    }
    
    public override func visit(_ node: AttributeSyntax) -> SyntaxVisitorContinueKind {
        self.isEscape = node.attributeName.text == "escaping"
        return .skipChildren
    }
    
    public static func detect(code: String) -> Bool {
        let target = "typealias A = \(code)"
        do {
            let source = try SyntaxParser.parse(source: target)
            let visitor = TypeEscapeVisitor()
            visitor.walk(source)
            return visitor.isEscape
        } catch {
            return false
        }
    }
}
