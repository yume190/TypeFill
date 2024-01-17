//
//  Symbols.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/9.
//

import SwiftSyntax

enum Symbols {
    /// `: `
    static var colon: TokenSyntax {
        return TokenSyntax.colonToken(leadingTrivia: .spaces(0), trailingTrivia: .space)
    }
    
    /// `, `
    static var comma: TokenSyntax {
        return TokenSyntax.commaToken(leadingTrivia: .spaces(0), trailingTrivia: .space)
    }
    
    /// `(`
    static var leftParen: TokenSyntax {
        return TokenSyntax.leftParenToken()
    }
    
    /// `)`
    static var rightParen: TokenSyntax {
        return TokenSyntax.rightParenToken()
    }
}
