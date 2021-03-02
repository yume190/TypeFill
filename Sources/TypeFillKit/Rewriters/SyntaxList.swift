//
//  SyntaxList.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/9.
//

import SwiftSyntax

protocol SyntaxList: SyntaxProtocol {
    associatedtype Parameter
    associatedtype Builder: SyntaxListBuilder where Builder.Parameter == Self.Parameter
    init(_ build: (inout Builder) -> Void)
}

protocol SyntaxListBuilder {
    associatedtype Parameter
    mutating func useLeftParen(_ node: TokenSyntax)
    mutating func addParameter(_ elt: Parameter)
    mutating func useRightParen(_ node: TokenSyntax)
}

extension SyntaxList {
    static func build(@ArrayBuilder<Parameter> builder: () -> [Parameter]) -> Self {
        let parameters = builder()
        return Self { (builder) in
            builder.useLeftParen(Symbols.leftParen)
            parameters.forEach { param in
                builder.addParameter(param)
            }
            builder.useRightParen(Symbols.rightParen)
        }.withTrailingTrivia(.spaces(1))
    }
}

extension ParameterClauseSyntax: SyntaxList {
    typealias Parameter = FunctionParameterSyntax
    typealias Builder = ParameterClauseSyntaxBuilder
}
extension ParameterClauseSyntaxBuilder: SyntaxListBuilder {}

extension TupleTypeSyntax: SyntaxList {
    typealias Parameter = TupleTypeElementSyntax
    typealias Builder = TupleTypeSyntaxBuilder
}
extension TupleTypeSyntaxBuilder: SyntaxListBuilder {
    typealias Parameter = TupleTypeElementSyntax
    mutating func addParameter(_ elt: TupleTypeElementSyntax) {
        self.addElement(elt)
    }
}
