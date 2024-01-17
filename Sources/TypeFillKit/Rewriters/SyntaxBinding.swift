//
//  SyntaxBinding.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/9.
//

import SwiftSyntax
import SwiftSyntaxBuilder

protocol SyntaxBinding: SyntaxProtocol {
  var typeAnnotation: TypeAnnotationSyntax? {get}
  var pattern: PatternSyntax {get}
  var _initializer: InitializerClauseSyntax? { get }
  func withPattern(_ newChild: PatternSyntax?) -> Self
  func withTypeAnnotation(_ newChild: TypeAnnotationSyntax?) -> Self
}

extension OptionalBindingConditionSyntax: SyntaxBinding {
  func withPattern(_ newChild: SwiftSyntax.PatternSyntax?) -> SwiftSyntax.OptionalBindingConditionSyntax {
    guard let newChild else {
      return self
    }
    return with(\.pattern, newChild)
  }
  
  func withTypeAnnotation(_ newChild: SwiftSyntax.TypeAnnotationSyntax?) -> SwiftSyntax.OptionalBindingConditionSyntax {
    guard let newChild else {
      return self
    }
    return with(\.typeAnnotation, newChild)
  }
  
  var _initializer: InitializerClauseSyntax? {
    initializer
  }
}
extension PatternBindingSyntax: SyntaxBinding {
  func withPattern(_ newChild: SwiftSyntax.PatternSyntax?) -> SwiftSyntax.PatternBindingSyntax {
    guard let newChild else {
      return self
    }
    return with(\.pattern, newChild)
  }
  
  func withTypeAnnotation(_ newChild: SwiftSyntax.TypeAnnotationSyntax?) -> SwiftSyntax.PatternBindingSyntax {
    guard let newChild else {
      return self
    }
    return with(\.typeAnnotation, newChild)
  }
  
  var _initializer: InitializerClauseSyntax? {
    initializer
  }
}


extension SyntaxBinding {
  private func fillIdentifier(rewriter: TypeFillRewriter) -> Self {
    guard let type: TypeSyntax = try? rewriter.cursor(pattern).typeSyntax else { return self }
    
    let typeAnnotation: TypeAnnotationSyntax
    if self._initializer == nil {
      typeAnnotation = TypeAnnotationSyntax(type).with(\.trailingTrivia, .spaces(0))
    } else {
      typeAnnotation = TypeAnnotationSyntax(type)
    }
    
    return self.replace(typeAnnotation: typeAnnotation, rewriter: rewriter)
  }
  
  private func fillTuple(pattern: TuplePatternSyntax, rewriter: TypeFillRewriter) -> Self {
    let types: [TypeSyntax] = pattern.elements.compactMap {
      return try? rewriter.cursor($0).typeSyntax
    }
    
    guard types.count == pattern.elements.count else { return self }
    
    let tupleTypeElements: [TupleTypeElementSyntax] = types.enumerated().map { (index: Int, type: TypeSyntax) -> TupleTypeElementSyntax in
      var syntax = TupleTypeElementSyntax(type: type)
      if (index + 1) != types.count {
        syntax = syntax.with(\.trailingComma, Symbols.comma)
      }
      return syntax
    }
    
    let type: TupleTypeSyntax = TupleTypeSyntax(elements: TupleTypeElementListSyntax(tupleTypeElements))
    
    let typeAnnotation: TypeAnnotationSyntax = TypeAnnotationSyntax(.init(type))
    return self.replace(typeAnnotation: typeAnnotation, rewriter: rewriter)
  }
  
  private func replace(typeAnnotation: TypeAnnotationSyntax, rewriter: TypeFillRewriter) -> Self {
    let newNode: Self = self
      .withPattern(self.pattern.with(\.trailingTrivia, .spaces(0)))
      .withTypeAnnotation(typeAnnotation)
    Logger.add(event: .implicitType(origin: rewriter.found(syntax: self), fixed: newNode.description))
    return newNode
  }
  
  func fill(rewriter: TypeFillRewriter) -> Self {
    guard self.typeAnnotation == nil else { return self }
    
    if self.pattern.syntaxNodeType == IdentifierPatternSyntax.self {
      return self.fillIdentifier(rewriter: rewriter)
    } else if let pattern: TuplePatternSyntax = self.pattern.as(TuplePatternSyntax.self) {
      return self.fillTuple(pattern: pattern, rewriter: rewriter)
    } else {
      return self
    }
  }
}
