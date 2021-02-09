//
//  Symbols.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/9.
//

import SwiftSyntax

enum Symbols {
    static var colon: TokenSyntax {
        return SyntaxFactory.makeColonToken().withTrailingTrivia(.spaces(1))
    }
    static var comma: TokenSyntax {
        return SyntaxFactory.makeCommaToken().withTrailingTrivia(.spaces(1))
    }
    
    static var leftParen: TokenSyntax {
        return SyntaxFactory.makeLeftParenToken()
    }
    
    static var rightParen: TokenSyntax {
        return SyntaxFactory.makeRightParenToken()
    }
}
