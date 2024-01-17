//
//  TypeFillRewriter.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/8.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SKClient

extension TypeAnnotationSyntax {
  init(_ type: TypeSyntax) {
    self = TypeAnnotationSyntax(
      colon: Symbols.colon,
      type: type,
      trailingTrivia: .space)
  }
}

final class TypeFillRewriter: SyntaxRewriter {
  let cursor: SKClient
  init(_ cursor: SKClient) {
    self.cursor = cursor
  }
  
  final func found<Syntax: SyntaxProtocol>(syntax: Syntax) -> String {
    return """
        \(self.cursor.sourceConvert.codeLocation(syntax))
        \(syntax.description)
        """
  }
  
  // MARK: closure
  /// ClosureSignatureSyntax
  ///     input ClosureParamListSyntax / ParameterClauseSyntax
  override func visit(_ node: ClosureSignatureSyntax) -> ClosureSignatureSyntax {
    if let syntax = node.parameterClause?.as(ClosureShorthandParameterListSyntax.self) {
      if let newSyntax = replace(syntax) {
        let clause = ClosureParameterClauseSyntax(
          leftParen: Symbols.leftParen,
          parameters: newSyntax,
          rightParen: Symbols.rightParen
        )
        
        return node
          .with(\.parameterClause, .init(clause)?.with(\.trailingTrivia, .space))
      }
    }
    
    if let syntax = node.parameterClause?.as(ClosureParameterClauseSyntax.self) {
      let newSyntax = replace(syntax)
      return node.with(\.parameterClause, .init(newSyntax))
    }
    
    if let syntax = node.parameterClause?.as(FunctionParameterClauseSyntax.self) {
      let newSyntax = replace(syntax)
      return node.with(\.parameterClause, .init(newSyntax))
    }
    return node
  }
  
  /// ClosureParamList
  ///     ClosureParam i
  private func replace(_ node: ClosureShorthandParameterListSyntax) -> ClosureParameterListSyntax? {
    
    // MARK: skip inout
    guard let arg: ClosureShorthandParameterSyntax = node.first else {return nil}
    let isHaveInout: Bool = (try? self.cursor(arg).isHaveInout) ?? false
    guard !isHaveInout else {return nil}
    
    let types: [TypeSyntax?] = node.map { (param: ClosureShorthandParameterListSyntax.Element) -> TypeSyntax? in
      guard let response: SourceKitResponse = try? cursor(param) else { return nil }
      return response.typeSyntax
    }
    
    let params: [ClosureParameterSyntax] = zip(types, node).enumerated().map { (index: Int, item: (TypeSyntax?, ClosureShorthandParameterListSyntax.Element)) in
      let paramNode = item.1
      var newParamNode = ClosureParameterSyntax(
        firstName: paramNode.name.with(\.trailingTrivia, .spaces(0))
      )
      
      if let type: TypeSyntax = item.0 {
        newParamNode = newParamNode
          .with(\.colon, Symbols.colon)
          .with(\.type, type)
      }
      if index + 1 != node.count {
        newParamNode = newParamNode.with(\.trailingComma, Symbols.comma)
      }
      
      if let _ = item.0 {
        Logger.add(event: .implicitType(origin: found(syntax: paramNode), fixed: newParamNode.description))
      }
      return newParamNode
    }
    
    let result = ClosureParameterListSyntax(params)
    return result
  }
  
  private func replace(_ node: ClosureParameterClauseSyntax) -> ClosureParameterClauseSyntax {
    let newParams: [ClosureParameterSyntax] = node.parameters.map { (parameter) -> ClosureParameterSyntax in
      //      guard parameter.colon == nil, parameter.type == nil else { return parameter }
      //      guard let firstName: TokenSyntax = parameter.firstName else { return parameter }
      guard let type: SourceKitResponse = try? cursor(parameter.firstName) else { return parameter }
      guard let typeSyntax: TypeSyntax = type.typeSyntax else { return parameter }
      let newNode: ClosureParameterSyntax = parameter
        .with(\.colon, Symbols.colon)
        .with(\.type, typeSyntax)
      Logger.add(event: .implicitType(origin: found(syntax: parameter), fixed: newNode.description))
      return newNode
    }
    
    
    return node
      .with(\.parameters, ClosureParameterListSyntax(newParams))
  }
  
  /// ParameterClause
  ///     (
  ///     FunctionParameterList
  ///         FunctionParameter: str,
  ///         FunctionParameter: a: String
  ///     )
  private func replace(_ node: FunctionParameterClauseSyntax) -> FunctionParameterClauseSyntax {
    let newParams: [FunctionParameterSyntax] = node.parameters.map { (parameter: FunctionParameterListSyntax.Element) -> FunctionParameterSyntax in
      //      guard parameter.colon == nil, parameter.type == nil else { return parameter }
      //      guard let firstName: TokenSyntax = parameter.firstName else { return parameter }
      guard let type: SourceKitResponse = try? cursor(parameter.firstName) else { return parameter }
      guard let typeSyntax: TypeSyntax = type.typeSyntax else { return parameter }
      let newNode: FunctionParameterSyntax = parameter
        .with(\.colon, Symbols.colon)
        .with(\.type, typeSyntax)
      Logger.add(event: .implicitType(origin: found(syntax: parameter), fixed: newNode.description))
      return newNode
    }
    
    return node
      .with(\.parameters, FunctionParameterListSyntax(newParams))
  }
  
  // MARK: Binding Syntax
  
  /// OptionalBindingConditionSyntax
  ///     letOrVarKeyword
  ///     pattern
  ///     typeAnnotation
  ///     initializer
  override func visit(_ node: OptionalBindingConditionSyntax) -> OptionalBindingConditionSyntax {
    let newNode = node.fill(rewriter: self)
    guard let initializer: InitializerClauseSyntax = node.initializer else {
      return newNode
    }
    return newNode
      .with(\.initializer, self.visit(initializer).as(InitializerClauseSyntax.self))
  }
  
  /// PatternBindingSyntax
  ///     pattern
  ///     typeAnnotation
  ///     initializer
  ///     accessor
  ///     trailingComma
  override func visit(_ node: PatternBindingSyntax) -> PatternBindingSyntax {
    let newNode: PatternBindingSyntax = node.fill(rewriter: self)
    guard let initializer: InitializerClauseSyntax = node.initializer else {
      return newNode
    }
    return newNode
      .with(\.initializer, self.visit(initializer).as(InitializerClauseSyntax.self))
  }
}
