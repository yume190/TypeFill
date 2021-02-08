//
//  TypeFillRewriter.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/8.
//

import Foundation
import SourceKittenFramework
import SwiftSyntax
import SwiftSyntaxBuilder

class TypeFillRewriter: SyntaxRewriter {
    let cursor: Cursor
    let converter: SourceLocationConverter
    init(_ cursor: Cursor, _ converter: SourceLocationConverter) {
        self.cursor = cursor
        self.converter = converter
    }
    
    /// ClosureParamList
    ///     ClosureParam i

    /// ParameterClase
    ///     (
    ///     FunctionParameterList
    ///         FunctionParameter
    ///             str
    ///             ,
    ///         FunctionParameter
    ///             a
    ///             :
    ///             SimpleTypeIndentifier
    ///                 String
    ///     )
    override func visit(_ node: ClosureExprSyntax) -> ExprSyntax {
        if let params = node.signature?.input?.as(ClosureParamListSyntax.self) {
            
            let types = params.compactMap { param -> TypeSyntax? in
                let postion = param.position.utf8Offset
                guard let type = try? cursor(postion) else {return nil}
                return type
            }
            
            guard types.count == params.count else { return .init(node) }
            
            let fParams: [FunctionParameterSyntax] = zip(types, params).map { (type, param) in
                return FunctionParameterSyntax { (builder) in
                    builder.useFirstName(param.name.withTrailingTrivia(.zero))
                    builder.useColon(SyntaxFactory.makeColonToken())
                    builder.useType(type)
                }
            }

            let clause = ParameterClauseSyntax { (builder) in
                builder.useLeftParen(SyntaxFactory.makeLeftParenToken())
                fParams.enumerated().forEach { index, param in
                    let _param: FunctionParameterSyntax
                    if (fParams.count - 1) == index {
                        _param = param
                    } else {
                        _param = param.withTrailingComma(SyntaxFactory.makeCommaToken().withTrailingTrivia(.spaces(1)))
                    }
                    builder.addParameter(_param)
                }
                builder.useRightParen(SyntaxFactory.makeRightParenToken())
            }.withTrailingTrivia(.spaces(1))
            let signature = node.signature?.withInput(.init(clause))
            let newNode = node.withSignature(signature)
            return .init(newNode)
        } else if let params = node.signature?.input?.as(ParameterClauseSyntax.self) {
            let newParams = params.parameterList.map { (parameter) -> FunctionParameterSyntax in
                guard parameter.colon == nil, parameter.type == nil else { return parameter }
                guard let postion = parameter.firstName?.position.utf8Offset else { return parameter }
                guard let type = try? cursor(postion) else { return parameter }
                return parameter
                    .withColon(SyntaxFactory.makeColonToken())
                    .withType(type)
            }
            
            let clause = params.withParameterList(SyntaxFactory.makeFunctionParameterList(newParams))
            let signature = node.signature?.withInput(.init(clause))
            let newNode = node.withSignature(signature)
            return .init(newNode)
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
        return .init(node.fill(cursor: self.cursor))
    }
    
    /// PatternBindingSyntax: a = 1
    /// pattern `a`
    /// typeAnnotation `(nil / : Int)`
    /// initializer `= 1`
    /// accessor `nil`
    /// trailingComma
    override func visit(_ node: VariableDeclSyntax) -> DeclSyntax {
//        node.bindings.first?.initializer?.value.syntaxNodeType ClosureExprSyntax
        
        let newBindings = node.bindings.map { binding -> PatternBindingSyntax in
            guard let newBinding = binding.initializer?.value.as(ClosureExprSyntax.self) else {return binding}
            let initializer = binding.initializer?.withValue(self.visit(newBinding))
            return binding.withInitializer(initializer)
        }
        
        let node = node.withBindings(SyntaxFactory.makePatternBindingList(newBindings))
        
        let bindings = node.bindings.map { (patternBindingSyntax: PatternBindingSyntax) -> PatternBindingSyntax in
            patternBindingSyntax.fill(cursor: self.cursor)
        }
        let bindingList = SyntaxFactory.makePatternBindingList(bindings)
        let result = node.withBindings(bindingList)
        return .init(result)
    }
}

protocol Binding {
    var typeAnnotation: TypeAnnotationSyntax? {get}
    var pattern: PatternSyntax {get}
    func withPattern(_ newChild: PatternSyntax?) -> Self
    func withTypeAnnotation(_ newChild: TypeAnnotationSyntax?) -> Self
}

extension OptionalBindingConditionSyntax: Binding {}
extension PatternBindingSyntax: Binding {}


extension Binding {
    func fill(cursor: Cursor) -> Self {
        guard self.typeAnnotation == nil else { return self }
        
        if self.pattern.syntaxNodeType == IdentifierPatternSyntax.self {
            let offset = self.pattern.position.utf8Offset
            guard let type = try? cursor(offset) else { return self }
            
            let typeAnnotation = TypeAnnotationSyntax { (builder) in
                builder.useColon(SyntaxFactory.makeColonToken())
                builder.useType(
                    type.withTrailingTrivia(.spaces(1))
                )
            }
            return self
                .withPattern(self.pattern.withTrailingTrivia(.zero))
                .withTypeAnnotation(typeAnnotation)
                
        } else if self.pattern.syntaxNodeType == TuplePatternSyntax.self {
            return self
        } else {
            return self
        }
    }
}
