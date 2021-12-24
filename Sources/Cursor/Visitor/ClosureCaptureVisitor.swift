//
//  ClosureCaptureVisitor.swift
//  Cursor
//
//  Created by Yume on 2021/10/25.
//

import Foundation
import SwiftSyntax
import Rainbow

/*
 Level
 
 ## New
 
 ### Function
 
 Parameter: Argument list
 
 Effect: body
 
 ### Closure
 
 Parameter:
 - Argument list
 - Capture list
 
 Effect: body
 
 ## Next Level
 
 ### Guard
 
 Parameter:
 - guard let
 - guard case let
 
 Effect:
 - After guard
 - else body
 
 ### If
 
 Parameter:
 - if let
 - if case let
 
 Effect:
 - if body
 
 ### Switch
 
 Parameter:
 - case let
 
 Effect:
 - case body?
 
 ### For
 
 Parameter:
 - in?
 
 Effect:
 - body
 
 ### while
 
 Parameter:
 - while let
 - while case let
 
 Effect:
 - body
 
 ### Do
 
 Parameter: None
 
 Effect:
 - body
 
 ### Catch
 
 Parameter:
 - error?
 
 Effect:
 - body
 
 ## Not Sure?
 
 List:
 - subscript
 - init
 - Optional chain
 - setter
 
 */

public indirect enum Declaration<T>: CustomStringConvertible {
    public typealias List = [String: T]
    
    case level0(list: List)
    case levelN(level: Int, list: List, parent: Declaration)
    
    public var description: String {
        return self.list.keys.joined(separator: "\n")
    }
    
    var list: List {
        switch self {
        case .level0(let list):
            return list
        case .levelN(_, let list, let parent):
            return list.merging(parent.list) { (new, _ /*old*/) in
                return new
            }
        }
    }
    
    var nextLevel: Declaration {
        switch self {
        case .level0:
            return .levelN(level: 1, list: [:], parent: self)
        case .levelN(let level, _, _):
            return .levelN(level: level + 1, list: [:], parent: self)
        }
    }
    
    subscript(name: String) -> T? {
        return self.list[name]
    }
    
    func append(key: String, value: T) -> Declaration {
        switch self {
        case let .level0(list):
            let newList = list.merging([key: value]) { _, new in
                return new
            }
            return .level0(list: newList)
        case let .levelN(level, list, parent):
            let newList = list.merging([key: value]) { _, new in
                return new
            }
            
            return .levelN(level: level, list: newList, parent: parent)
        }
    }
}

/// Unit: CodeBlockItemSyntax
/// Unit: PatternSyntax
/// case .unknownPattern, .enumCasePattern, .isTypePattern, .optionalPattern, .identifierPattern, .asTypePattern, .tuplePattern, .wildcardPattern, .expressionPattern, .valueBindingPattern:
public final class ClosureCaptureVisitor: SyntaxVisitor {
    
    private(set) var results: [CodeLocation] = []
    private let cursor: Cursor
    private let verbose: Bool
//    private
    var decls: Declaration<SourceKitResponse> = .level0(list: [:])
    
    public init(_ cursor: Cursor, _ verbose: Bool = false) {
        self.cursor = cursor
        self.verbose = verbose
    }

//    public final override func visit(_ node: PatternBindingSyntax) -> SyntaxVisitorContinueKind {
//        node.pattern
//        node.initializer
//    }
    

    // MARK: New Level
    
    /// case attributes
    /// case modifiers
    /// case funcKeyword
    /// case identifier
    /// case genericParameterClause
    /// case signature
    ///     case input
    ///         case leftParen
    ///         case parameterList
    ///         case rightParen
    ///     case asyncOrReasyncKeyword
    ///     case throwsOrRethrowsKeyword
    ///     case output
    /// case genericWhereClause
    /// case body
    ///
    /// ### Function
    ///
    /// Parameter: Argument list
    ///
    /// Effect: body
    public final override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        
        self.decls = .level0(list: [:])
        
        try! node.signature.input.parameterList.compactMap { syntax in
            guard let name = syntax.secondName else {return nil}
            return try (name.text, cursor(name))
        }.forEach { (key, response) in
            self.decls = self.decls.append(key: key, value: response)
        }
        
        if let body = node.body {
            body.statements.forEach { (syntax: CodeBlockItemSyntax) in
                self.walk(syntax)
            }
        }
//        node.body

        
        return .skipChildren
    }
    
    /// case leftBrace
    /// case signature
    ///     case attributes
    ///     case capture
    ///     case input
    ///     case asyncKeyword
    ///     case throwsTok
    ///     case output
    ///     case inTok
    /// case statements
    /// case rightBrace
    ///
    /// Parameter:
    ///  - Argument list
    ///  - Capture list
    ///
    ///  Effect: body
    public final override func visit(_ node: ClosureExprSyntax) -> SyntaxVisitorContinueKind {
//        node.signature?.capture
//        node.signature?.input
//
//        node.statements
        return .skipChildren
    }
    
    
    // MARK: Next Level
    
    /// case labelName
    /// case labelColon
    /// case ifKeyword
    /// case conditions
    ///     case condition
    ///         let / case
    ///         OptionalBindingConditionSyntax/MatchingPatternConditionSyntax
    ///     case trailingComma
    /// case body
    /// case elseKeyword
    /// case elseBody
    ///
    /// Parameter:
    ///  - if let
    ///  - if case let
    ///
    ///  Effect:
    ///  - if body
    public final override func visit(_ node: IfStmtSyntax) -> SyntaxVisitorContinueKind {
//        node.conditions.map{$0}[0].condition
        
//        node.body
//        node.elseBody
        return .skipChildren
    }
    
    /// case guardKeyword
    /// case conditions
    /// case elseKeyword
    /// case body
    ///
    /// Parameter:
    /// - guard let
    /// - guard case let
    ///
    /// Effect:
    /// - After guard
    /// - else body
    public final override func visit(_ node: GuardStmtSyntax) -> SyntaxVisitorContinueKind {
//        node.conditions.map{$0}[0].condition
//
//        node.body
        return .skipChildren
    }
    
    /// case labelName
    /// case labelColon
    /// case doKeyword
    /// case body
    /// case catchClauses
    ///     case catchKeyword
    ///     case catchItems
    ///         case pattern
    ///         case whereClause
    ///         case trailingComma
    ///     case body
    ///
    /// Parameter: None
    ///
    /// Effect: body
    public final override func visit(_ node: DoStmtSyntax) -> SyntaxVisitorContinueKind {
        /// do
        node.body
        
        /// catch
        // CatchClauseSyntax
        //  CatchItemSyntax
//        node.catchClauses!.map{$0}[0].catchItems!.map{$0}[0].pattern
//        node.catchClauses!.map{$0}[0].body
        return .skipChildren
    }
    
    /// case labelName
    /// case labelColon
    /// case forKeyword
    /// case tryKeyword
    /// case awaitKeyword
    /// case caseKeyword
    /// case pattern
    /// case typeAnnotation
    /// case inKeyword
    /// case sequenceExpr
    /// case whereClause
    /// case body
    ///
    /// Parameter: in?
    ///
    /// Effect: body
    public final override func visit(_ node: ForInStmtSyntax) -> SyntaxVisitorContinueKind {
        node.pattern
        
        node.body
        return .skipChildren
    }

    /// case labelName
    /// case labelColon
    /// case switchKeyword
    /// case expression
    /// case leftBrace
    /// case cases
    ///     case unknownAttr
    ///     case label
    ///         case caseKeyword
    ///         case caseItems
    ///             case pattern
    ///             case whereClause
    ///             case trailingComma
    ///         case colon
    ///     case statements
    /// case rightBrace
    ///
    /// Parameter: case item
    ///
    /// Effect: case statement
    public final override func visit(_ node: SwitchStmtSyntax) -> SyntaxVisitorContinueKind {
        // node.expression switch `xxx`
        
        node
            .cases
            .map{$0.as(SwitchCaseSyntax.self)}[0]?
            .label.as(SwitchCaseLabelSyntax.self)?
            .caseItems.map{$0}[0]
            .pattern
        node.cases.map{$0.as(SwitchCaseSyntax.self)}[0]?.statements
        
        return .skipChildren
    }
    
    /// case labelName
    /// case labelColon
    /// case whileKeyword
    /// case conditions
    /// case body
    ///
    /// Parameter:
    ///  - while let
    ///  - while case let
    ///
    /// Effect: body
    public final override func visit(_ node: WhileStmtSyntax) -> SyntaxVisitorContinueKind {
        node.conditions
        
        node.body
        return .skipChildren
    }
}
