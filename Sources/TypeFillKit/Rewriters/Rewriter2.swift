//
//  File.swift
//  
//
//  Created by Yume on 2021/2/4.
//

import Foundation
import SourceKittenFramework
import SwiftSyntax
import SwiftSyntaxBuilder

public struct Rewriter2 {
    
    public static func parse(source: String, cursor: Cursor) throws {
        let sourceFile: SourceFileSyntax = try SyntaxParser.parse(source: source)
        self.parse(file: sourceFile, cursor: cursor, fileHandle: .standardOutput)
    }
    
    public static func parse(url: URL, cursor: Cursor) throws {
        let sourceFile: SourceFileSyntax = try SyntaxParser.parse(url)
        let fileHandle = try FileHandle(forWritingTo: url)
        self.parse(file: sourceFile, cursor: cursor, fileHandle: fileHandle)
    }
    
    private static func parse(file: SourceFileSyntax, cursor: Cursor, fileHandle: FileHandle) {
        let rw = YRewriter(cursor)
//        let rx = YRewriter2()
        let r = rw.visit(file)
        
        var result = ""
        r.write(to: &result)
//        print(result)
        fileHandle.write(result.data(using: .utf8)!)
    }
}


//class YRewriter2: SyntaxAnyVisitor {
//    override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
//        print(node)
//        return .visitChildren
//    }
//}
class YRewriter: SyntaxRewriter {
    let cursor: Cursor
    init(_ cursor: Cursor) {
        self.cursor = cursor
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
                    builder.useFirstName(param.name)
                    builder.useColon(SyntaxFactory.makeColonToken())
                    builder.useType(type)
                }
            }

            let clause = ParameterClauseSyntax { (builder) in
                builder.useLeftParen(SyntaxFactory.makeLeftParenToken())
                fParams.forEach { builder.addParameter($0) }
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
