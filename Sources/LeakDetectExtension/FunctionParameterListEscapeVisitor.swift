//
//  FunctionParameterListEscapeVisitor.swift
//  TypeFillTests
//
//  Created by Yume on 2021/10/21.
//

import Foundation
import SwiftSyntax

/// typealias C = (@escaping (@escaping (Int) -> ()) -> (), Int) -> ()
/// typealias C = (((@escaping (Int) -> ()) -> ()), Int) -> ()
/// find `escaping` from `parameter list` by `Index`
public final class FunctionParameterListEscapeVisitor: SyntaxVisitor {
    private var isEscape: Bool = false
    private let index: Int
    
    private init(_ index: Int) {
        self.index = index
    }

    public override func visit(_ node: FunctionTypeSyntax) -> SyntaxVisitorContinueKind {
        let args = node.arguments.map{$0}
        
        guard args.count > index else {return .skipChildren}
        let arg: TupleTypeElementSyntax = args[index]
        
        /// @escaping Closure
        if let attrs = arg.type.as(AttributedTypeSyntax.self)?.attributes {
            self.walk(attrs)
            return .skipChildren
        }
        
        /// (Closure)
        if
            let elements = arg.type.as(TupleTypeSyntax.self)?.elements,
            let _ = elements.first?.type.as(FunctionTypeSyntax.self),
            elements.count == 1 {
            self.isEscape = true
            return .skipChildren
        }
        
        return .skipChildren
    }
    
    public override func visit(_ node: AttributeSyntax) -> SyntaxVisitorContinueKind {
        self.isEscape = node.attributeName.text == "escaping"
        return .skipChildren
    }
    
    public static func detect(code: String, index: Int) -> Bool {
        let target = "typealias A = \(code)"
        do {
            let source = try SyntaxParser.parse(source: target)
            let visitor = FunctionParameterListEscapeVisitor(index)
            visitor.walk(source)
            return visitor.isEscape
        } catch {
            return false
        }
    }
}
