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
    
    func found<Syntax: SyntaxProtocol>(syntax: Syntax) -> String {
        return """
        \(path):\(self.converter.location(for: syntax.position))
        \(syntax.description)
        """
    }
    
    /// ClosureParamList
    ///     ClosureParam i
    private func fillClosureParam(node: ClosureExprSyntax, params: ClosureParamListSyntax) -> ExprSyntax {
        let types: [TypeSyntax] = params.compactMap { param -> TypeSyntax? in
            let postion = param.position.utf8Offset
            guard let response = try? cursor(postion) else {return nil}
            return response.typeSyntax
        }
        
        guard types.count == params.count else { return .init(node) }
        let fParams: [FunctionParameterSyntax] = zip(types, params).enumerated().map { (index, item) in
            return FunctionParameterSyntax { (builder) in
                builder.useFirstName(item.1.name.withTrailingTrivia(.zero))
                builder.useColon(Symbols.colon)
                builder.useType(item.0)
                if index + 1 != params.count {
                    builder.useTrailingComma(Symbols.comma)
                }
            }
        }

        let clause: ParameterClauseSyntax = ParameterClauseSyntax.build { fParams }
        return self.replace(node: node, clause: clause)
    }
    
    /// ParameterClase
    ///     (
    ///     FunctionParameterList
    ///         FunctionParameter: str,
    ///         FunctionParameter: a: String
    ///     )
    private func fillParameterClause(node: ClosureExprSyntax, params: ParameterClauseSyntax) -> ExprSyntax {
        let newParams: [FunctionParameterSyntax] = params.parameterList.map { (parameter) -> FunctionParameterSyntax in
            guard parameter.colon == nil, parameter.type == nil else { return parameter }
            guard let postion = parameter.firstName?.position.utf8Offset else { return parameter }
            guard let type = try? cursor(postion) else { return parameter }
            guard let typeSyntax = type.typeSyntax else { return parameter }
            return parameter
                .withColon(Symbols.colon)
                .withType(parameter.type ?? typeSyntax)
        }
        
        let clause: ParameterClauseSyntax = params.withParameterList(SyntaxFactory.makeFunctionParameterList(newParams))
        
        return self.replace(node: node, clause: clause)
    }
    
    private func replace(node: ClosureExprSyntax, clause: ParameterClauseSyntax) -> ExprSyntax{
        let signature: ClosureSignatureSyntax? = node.signature?.withInput(.init(clause))
        let newNode: ClosureExprSyntax = node.withSignature(signature)
        Logger.shared.add(event: .implictType(origin: found(syntax: node), fixed: newNode.description))
        return .init(newNode)
    }
    
    override func visit(_ node: ClosureExprSyntax) -> ExprSyntax {
        if let params: ClosureParamListSyntax = node.signature?.input?.as(ClosureParamListSyntax.self) {
            // MARK: skip inout
            if let arg: ClosureParamSyntax = params.first {
                let isHaveInout: Bool = (try? self.cursor(arg.position.utf8Offset).isHaveInout) ?? false
                if isHaveInout {return .init(node)}
            }
            return self.fillClosureParam(node: node, params: params)
        } else if let params: ParameterClauseSyntax = node.signature?.input?.as(ParameterClauseSyntax.self) {
            return self.fillParameterClause(node: node, params: params)
        }
        return .init(node)
    }
//    #warning("not work")
//    override func visit(_ node: FunctionParameterSyntax) -> Syntax {
//        guard node.colon == nil, node.type == nil else {return .init(node)}
//        guard let name = node.secondName else {return .init(node)}
//        let offset = name.position.utf8Offset
//        guard let type = try? cursor(offset) else {return .init(node)}
//
//        return .init(
//            node
//                .withColon(SyntaxFactory.makeColonToken())
//                .withType(SyntaxFactory.makeTypeIdentifier(type).withLeadingTrivia(.spaces(1)))
//        )
//    }
    
    /// ConditionElementListSyntax
    ///     ConditionElementSyntax
    ///         OptionalBindingConditionSyntax
    ///             Pattern
    override func visit(_ node: OptionalBindingConditionSyntax) -> Syntax {
        return .init(node.fill(rewriter: self))
    }
    
    /// PatternBindingSyntax: a = 1
    /// pattern `a`
    /// typeAnnotation `(nil / : Int)`
    /// initializer `= 1`
    /// accessor `nil`
    /// trailingComma
    override func visit(_ node: VariableDeclSyntax) -> DeclSyntax {
//        node.bindings.first?.initializer?.value.syntaxNodeType ClosureExprSyntax
        let newBindings: [PatternBindingSyntax] = node.bindings.map { binding -> PatternBindingSyntax in
            guard let newBinding = binding.initializer?.value.as(ClosureExprSyntax.self) else {return binding}
            let initializer = binding.initializer?.withValue(self.visit(newBinding))
            return binding.withInitializer(initializer)
        }
        
        let node: VariableDeclSyntax = node.withBindings(SyntaxFactory.makePatternBindingList(newBindings))
        
        let bindings: [PatternBindingSyntax] = node.bindings.map { (patternBindingSyntax: PatternBindingSyntax) -> PatternBindingSyntax in
            patternBindingSyntax.fill(rewriter: self)
        }
        let bindingList: PatternBindingListSyntax = SyntaxFactory.makePatternBindingList(bindings)
        let result: VariableDeclSyntax = node.withBindings(bindingList)
        return .init(result)
    }
}
