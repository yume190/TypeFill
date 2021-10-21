//
//  Assign.swift
//  TypeFillTests
//
//  Created by Yume on 2021/10/21.
//

import Foundation
import SwiftSyntax

extension ExprSyntax {
    var tokenSyntax: TokenSyntax? {
        return
            self.as(MemberAccessExprSyntax.self)?.tokenSyntax ??
            self.as(IdentifierExprSyntax.self)?.tokenSyntax
    }
}

extension MemberAccessExprSyntax {
    var tokenSyntax: TokenSyntax {
        self.name
    }
}

extension IdentifierExprSyntax {
    var tokenSyntax: TokenSyntax {
        self.identifier
    }
}

public final class AssignClosureVisitor: SyntaxVisitor {
    
    private(set) var results: [CodeLocation] = []
    private let cursor: Cursor
    public init(_ cursor: Cursor) {
        self.cursor = cursor
    }
    
    /// self.a = self.abc
    ///
    /// expr self.a/a
    ///     MemberAccessExpr/IdentifierExpr
    /// expr =
    ///     AssigmentExpr
    /// expr self.abc/abc
    ///     MemberAccessExpr/IdentifierExpr
    public final override func visit(_ node: ExprListSyntax) -> SyntaxVisitorContinueKind {
        self.find(node)
        return .visitChildren
    }
    
    @inline(__always)
    private final func find(_ node: ExprListSyntax) {
        guard node.count == 3 else {return}
        let exprs = node.map {$0}
        
        guard exprs[1].is(AssignmentExprSyntax.self) else {return}
        guard let _ = exprs[0].tokenSyntax else {return}
        guard let identifier = exprs[2].tokenSyntax else {return}

        do {
            guard try cursor(identifier).isRefInstanceFunction else {return}
            self.results.append(cursor(location: identifier))
        } catch {
            
        }
    }
    
    /// self.def(self.abc)
    ///
    /// calledExpression self.def/def
    ///     MemberAccessExpr/IdentifierExpr
    /// argumentList
    ///     TupleExprElementSyntax expression
    ///     TupleExprElementSyntax
    public final override func visit(_ node: FunctionCallExprSyntax) -> SyntaxVisitorContinueKind {
        self.find(node)
        return .visitChildren
    }
    
    /// TODO: check decl param is nonescaping
    @inline(__always)
    private final func find(_ node: FunctionCallExprSyntax) {
        for param in node.argumentList {
            do {
                guard let identifier = param.expression.tokenSyntax else {continue}
                guard try cursor(identifier).isRefInstanceFunction else {continue}
                self.results.append(cursor(location: identifier))
            } catch {
                
            }
        }
    }
    
    public final func detect() -> [CodeLocation] {
        defer { self.results = [] }
        self.walk(cursor.sourceFile)
        return results
    }
}
