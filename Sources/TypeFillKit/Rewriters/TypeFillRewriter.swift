//
//  TypeFillRewriter.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/8.
//

import Foundation
import SourceKittenFramework
import SwiftSyntax

extension TypeAnnotationSyntax {
    init(_ type: TypeSyntax) {
        self = TypeAnnotationSyntax { (builder: inout TypeAnnotationSyntaxBuilder) in
            builder.useColon(Symbols.colon)
            builder.useType(type)
        }.withTrailingTrivia(.spaces(1))
    }
}

final class TypeFillRewriter: SyntaxRewriter {
    let path: String
    let cursor: Cursor
    let converter: SourceLocationConverter
    init(_ path: String, _ cursor: Cursor, _ converter: SourceLocationConverter) {
        self.path = path
        self.cursor = cursor
        self.converter = converter
    }
    
    final func found<Syntax: SyntaxProtocol>(syntax: Syntax) -> String {
        return """
        \(path):\(self.converter.location(for: syntax.position))
        \(syntax.description)
        """
    }
    
    // MARK: closure
    
    /// ClosureParamList
    ///     ClosureParam i
    override func visit(_ node: ClosureParamListSyntax) -> Syntax {
        // MARK: skip inout
        guard let arg: ClosureParamSyntax = node.first else {return .init(node)}
        let isHaveInout: Bool = (try? self.cursor(arg.position.utf8Offset).isHaveInout) ?? false
        guard !isHaveInout else {return .init(node)}
        
        let types: [TypeSyntax?] = node.map { (param: ClosureParamListSyntax.Element) -> TypeSyntax? in
            let postion: Int = param.position.utf8Offset
            guard let response: SourceKitResponse = try? cursor(postion) else {return nil}
            return response.typeSyntax
        }
        
        let params: [FunctionParameterSyntax] = zip(types, node).enumerated().map { (index: Int, item: (TypeSyntax?, ClosureParamListSyntax.Element)) in
            let paramNode: ClosureParamListSyntax.Element = item.1
            let newParamNode: FunctionParameterSyntax = FunctionParameterSyntax { builder in
                builder.useFirstName(paramNode.name.withTrailingTrivia(.zero))
                
                if let type: TypeSyntax = item.0 {
                    builder.useColon(Symbols.colon)
                    builder.useType(type)
                }
                
                if index + 1 != node.count {
                    builder.useTrailingComma(Symbols.comma)
                }
            }
            if let _ = item.0 {
                Logger.add(event: .implicitType(origin: found(syntax: paramNode), fixed: newParamNode.description))
            }
            return newParamNode
        }
        
        let clause: ParameterClauseSyntax = ParameterClauseSyntax.build { params }
        
        return .init(clause)
    }
    
    /// ParameterClause
    ///     (
    ///     FunctionParameterList
    ///         FunctionParameter: str,
    ///         FunctionParameter: a: String
    ///     )
    override func visit(_ node: ParameterClauseSyntax) -> Syntax {
        let newParams: [FunctionParameterSyntax] = node.parameterList.map { (parameter: FunctionParameterListSyntax.Element) -> FunctionParameterSyntax in
            guard parameter.colon == nil, parameter.type == nil else { return parameter }
            guard let postion: Int = parameter.firstName?.position.utf8Offset else { return parameter }
            guard let type: SourceKitResponse = try? cursor(postion) else { return parameter }
            guard let typeSyntax: TypeSyntax = type.typeSyntax else { return parameter }
            let newNode: FunctionParameterSyntax = parameter
                .withColon(Symbols.colon)
                .withType(typeSyntax)
            Logger.add(event: .implicitType(origin: found(syntax: parameter), fixed: newNode.description))
            return newNode
        }
        
        let clause: ParameterClauseSyntax = node.withParameterList(SyntaxFactory.makeFunctionParameterList(newParams))
        return .init(clause)
    }
    
    // MARK: Binding Syntax
    
    /// OptionalBindingConditionSyntax
    ///     letOrVarKeyword
    ///     pattern
    ///     typeAnnotation
    ///     initializer
    override func visit(_ node: OptionalBindingConditionSyntax) -> Syntax {
        return .init(
            node.fill(rewriter: self)
                .withInitializer(self.visit(node.initializer).as(InitializerClauseSyntax.self))
        )
    }
    
    /// PatternBindingSyntax
    ///     pattern
    ///     typeAnnotation
    ///     initializer
    ///     accessor
    ///     trailingComma
    override func visit(_ node: PatternBindingSyntax) -> Syntax {
        let newNode: PatternBindingSyntax = node.fill(rewriter: self)
        guard let initializer: InitializerClauseSyntax = node.initializer else {
            return .init(newNode)
        }
        return .init(newNode.withInitializer(self.visit(initializer).as(InitializerClauseSyntax.self)))
    }
}
