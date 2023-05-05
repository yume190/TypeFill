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
        \(self.cursor(location: syntax))
        \(syntax.description)
        """
    }
    
    // MARK: closure
    /// ClosureSignatureSyntax
    ///     input ClosureParamListSyntax / ParameterClauseSyntax
    override func visit(_ node: ClosureSignatureSyntax) -> ClosureSignatureSyntax {
        if let syntax = node.input?.as(ClosureParamListSyntax.self) {
            if let newSyntax = replace(syntax) {
                return node.withInput(.init(newSyntax).withTrailingTrivia(.space))
            }
        }
        
        if let syntax = node.input?.as(ParameterClauseSyntax.self) {
            let newSyntax = replace(syntax)
            return node.withInput(.init(newSyntax))
        }
        return node
    }
    
    /// ClosureParamList
    ///     ClosureParam i
    private func replace(_ node: ClosureParamListSyntax) -> ParameterClauseSyntax? {
        // MARK: skip inout
        guard let arg: ClosureParamSyntax = node.first else {return nil}
        let isHaveInout: Bool = (try? self.cursor(arg).isHaveInout) ?? false
        guard !isHaveInout else {return nil}

        let types: [TypeSyntax?] = node.map { (param: ClosureParamListSyntax.Element) -> TypeSyntax? in
            guard let response: SourceKitResponse = try? cursor(param) else { return nil }
            return response.typeSyntax
        }

        let params: [FunctionParameterSyntax] = zip(types, node).enumerated().map { (index: Int, item: (TypeSyntax?, ClosureParamListSyntax.Element)) in
            let paramNode = item.1
            var newParamNode = FunctionParameterSyntax(
                firstName: paramNode.name.withTrailingTrivia(.zero)
            )
            
            if let type: TypeSyntax = item.0 {
                newParamNode = newParamNode
                    .withColon(Symbols.colon)
                    .withType(type)
            }
            if index + 1 != node.count {
                newParamNode = newParamNode.withTrailingComma(Symbols.comma)
            }
            
            if let _ = item.0 {
                Logger.add(event: .implicitType(origin: found(syntax: paramNode), fixed: newParamNode.description))
            }
            return newParamNode
        }
        
        let result = ParameterClauseSyntax(parameterList: .init(params))
        return result
    }
    
    /// ParameterClause
    ///     (
    ///     FunctionParameterList
    ///         FunctionParameter: str,
    ///         FunctionParameter: a: String
    ///     )
    private func replace(_ node: ParameterClauseSyntax) -> ParameterClauseSyntax {
        let newParams: [FunctionParameterSyntax] = node.parameterList.map { (parameter: FunctionParameterListSyntax.Element) -> FunctionParameterSyntax in
            guard parameter.colon == nil, parameter.type == nil else { return parameter }
            guard let firstName: TokenSyntax = parameter.firstName else { return parameter }
            guard let type: SourceKitResponse = try? cursor(firstName) else { return parameter }
            guard let typeSyntax: TypeSyntax = type.typeSyntax else { return parameter }
            let newNode: FunctionParameterSyntax = parameter
                .withColon(Symbols.colon)
                .withType(typeSyntax)
            Logger.add(event: .implicitType(origin: found(syntax: parameter), fixed: newNode.description))
            return newNode
        }
        
        return node
            .withParameterList(FunctionParameterListSyntax(newParams))
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
            .withInitializer(self.visit(initializer).as(InitializerClauseSyntax.self))
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
            .withInitializer(self.visit(initializer).as(InitializerClauseSyntax.self))
    }
}
