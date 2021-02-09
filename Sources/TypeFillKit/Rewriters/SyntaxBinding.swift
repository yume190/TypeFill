//
//  SyntaxBinding.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/9.
//

import SwiftSyntax

protocol SyntaxBinding: SyntaxProtocol {
    var typeAnnotation: TypeAnnotationSyntax? {get}
    var pattern: PatternSyntax {get}
    func withPattern(_ newChild: PatternSyntax?) -> Self
    func withTypeAnnotation(_ newChild: TypeAnnotationSyntax?) -> Self
}

extension OptionalBindingConditionSyntax: SyntaxBinding {}
extension PatternBindingSyntax: SyntaxBinding {}


extension SyntaxBinding {
    private func fillIdentifier(rewriter: TypeFillRewriter) -> Self {
        let offset: Int = self.pattern.position.utf8Offset
        guard let type: TypeSyntax = try? rewriter.cursor(offset) else { return self }
        
        let typeAnnotation: TypeAnnotationSyntax = TypeAnnotationSyntax(type)
        
        return self.replace(typeAnnotation: typeAnnotation, rewriter: rewriter)
    }
    
    private func fillTuple(pattern: TuplePatternSyntax, rewriter: TypeFillRewriter) -> Self {
        let types = pattern.elements.compactMap {
            return try? rewriter.cursor($0.position.utf8Offset)
        }
        
        guard types.count == pattern.elements.count else { return self }
        
        let tupleTypeElements = types.enumerated().map { (index, type) -> TupleTypeElementSyntax in
            return TupleTypeElementSyntax { (builder) in
                builder.useType(type)
                if (index + 1) != types.count {
                    builder.useTrailingComma(Symbols.comma)
                }
            }
        }
        
        let type = TupleTypeSyntax(tupleTypeElements)
        let typeAnnotation: TypeAnnotationSyntax = TypeAnnotationSyntax(.init(type))
        return self.replace(typeAnnotation: typeAnnotation, rewriter: rewriter)
    }
    
    private func replace(typeAnnotation: TypeAnnotationSyntax, rewriter: TypeFillRewriter) -> Self {
        let newNode: Self = self
            .withPattern(self.pattern.withTrailingTrivia(.zero))
            .withTypeAnnotation(typeAnnotation)
        logger.add(event: .implictType(origin: rewriter.found(syntax: self), fixed: newNode.description))
        return newNode
    }
    
    func fill(rewriter: TypeFillRewriter) -> Self {
        guard self.typeAnnotation == nil else { return self }
        
        if self.pattern.syntaxNodeType == IdentifierPatternSyntax.self {
            return self.fillIdentifier(rewriter: rewriter)
        } else if let pattern = self.pattern.as(TuplePatternSyntax.self) {
            return self.fillTuple(pattern: pattern, rewriter: rewriter)
        } else {
            return self
        }
    }
}
