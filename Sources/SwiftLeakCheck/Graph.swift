//
//  Graph.swift
//  SwiftLeakCheck
//
//  Copyright 2020 Grabtaxi Holdings PTE LTE (GRAB), All rights reserved.
//  Use of this source code is governed by an MIT-style license that can be found in the LICENSE file
//
//  Created by Hoang Le Pham on 11/11/2019.
//

import SwiftSyntax
import Cursor
import LeakDetectExtension

public protocol Graph {
  var sourceFileScope: SourceFileScope { get }
  
  /// Return the corresponding scope of a node if the node is of scope-type (class, func, closure,...)
  /// or return the enclosing scope if the node is not scope-type
  /// - Parameter node: The node
  func scope(for node: Syntax) -> Scope
  
  /// Get the scope that encloses a given node
  /// Eg, Scopes that enclose a func could be class, enum,...
  /// Or scopes that enclose a statement could be func, closure,...
  /// If the node is not enclosed by a scope (eg, sourcefile node), return the scope of the node itself
  /// - Parameter node: A node
  /// - Returns: The scope that encloses the node
  func enclosingScope(for node: Syntax) -> Scope
  
  /// Return the TypeDecl that encloses a given node
  /// - Parameter node: given node
  func enclosingTypeDecl(for node: Syntax) -> TypeDecl?
  
  /// Find the nearest scope to a symbol, that can resolve the definition of that symbol
  /// Usually it is the enclosing scope of the symbol
  func closetScopeThatCanResolveSymbol(_ symbol: Symbol) -> Scope?
  
  func resolveExprType(_ expr: ExprSyntax) -> TypeResolve
  func resolveVariableType(_ variable: Variable) -> TypeResolve
  func resolveType(_ type: TypeSyntax) -> TypeResolve
  func getAllRelatedTypeDecls(from typeDecl: TypeDecl) -> [TypeDecl]
  func getAllRelatedTypeDecls(from typeResolve: TypeResolve) -> [TypeDecl]
  
  func resolveVariable(_ identifier: IdentifierExprSyntax) -> Variable?
  func getVariableReferences(variable: Variable) -> [IdentifierExprSyntax]
  
  func resolveFunction(_ funcCallExpr: FunctionCallExprSyntax) -> (Function, Function.MatchResult.MappingInfo)?
  
  func isClosureEscape(_ closure: ClosureExprSyntax) -> Bool
  func isCollection(_ node: ExprSyntax) -> Bool
}

final class GraphImpl: Graph {
  enum SymbolResolve {
    case variable(Variable)
    case function(Function)
    case typeDecl(TypeDecl)
    
    var variable: Variable? {
      switch self {
      case .variable(let variable): return variable
      default:
        return nil
      }
    }
  }
  
  private var mapScopeNodeToScope: [ScopeNode : Scope] = [ScopeNode: Scope]()
  private var cachedSymbolResolved: [Symbol : GraphImpl.SymbolResolve] = [Symbol: SymbolResolve]()
  private var cachedReferencesToVariable: [Variable : [IdentifierExprSyntax]] = [Variable: [IdentifierExprSyntax]]()
  private var cachedVariableType: [Variable : TypeResolve] = [Variable: TypeResolve]()
  private var cachedFunCallExprType: [FunctionCallExprSyntax : TypeResolve] = [FunctionCallExprSyntax: TypeResolve]()
  private var cachedClosureEscapeCheck: [ClosureExprSyntax : Bool] = [ClosureExprSyntax: Bool]()
  
  private let cursor: Cursor
  let sourceFileScope: SourceFileScope
  init(cursor: Cursor, sourceFileScope: SourceFileScope) {
    self.cursor = cursor
    self.sourceFileScope = sourceFileScope
    buildScopeNodeToScopeMapping(root: sourceFileScope)
  }
  
  private func buildScopeNodeToScopeMapping(root: Scope) {
    mapScopeNodeToScope[root.scopeNode] = root
    root.childScopes.forEach { (child: Scope) in
      buildScopeNodeToScopeMapping(root: child)
    }
  }
}

// MARK: - Scope
extension GraphImpl {
  func scope(for node: Syntax) -> Scope {
    guard let scopeNode: ScopeNode = ScopeNode.from(node: node) else {
      return enclosingScope(for: node)
    }
    
    return scope(for: scopeNode)
  }
  
  func enclosingScope(for node: Syntax) -> Scope {
    guard let scopeNode: ScopeNode = node.enclosingScopeNode else {
      let result: Scope = scope(for: node)
      assert(result == sourceFileScope)
      return result
    }
    
    return scope(for: scopeNode)
  }
  
  func enclosingTypeDecl(for node: Syntax) -> TypeDecl? {
    var scopeNode: ScopeNode! = node.enclosingScopeNode
    while scopeNode != nil  {
      if scopeNode.type.isTypeDecl {
        return scope(for: scopeNode).typeDecl
      }
      scopeNode = scopeNode.enclosingScopeNode
    }
    
    return nil
  }
  
  func scope(for scopeNode: ScopeNode) -> Scope {
    guard let result: Scope = mapScopeNodeToScope[scopeNode] else {
      fatalError("Can't find the scope of node \(scopeNode)")
    }
    return result
  }
  
  func closetScopeThatCanResolveSymbol(_ symbol: Symbol) -> Scope? {
    let scope: Scope = enclosingScope(for: symbol.node)
    // Special case when node is a closure capture item, ie `{ [weak self] in`
    // We need to examine node wrt closure's parent
    if symbol.node.parent?.is(ClosureCaptureItemSyntax.self) == true {
      if let parentScope: Scope = scope.parent {
        return parentScope
      } else {
        fatalError("Can't happen")
      }
    }
    
    if symbol.node.hasAncestor({ $0.is(InheritedTypeSyntax.self) }) {
      return scope.parent
    }
    
    if symbol.node.hasAncestor({ $0.is(ExtensionDeclSyntax.self) && symbol.node.isDescendent(of: $0.as(ExtensionDeclSyntax.self)!.extendedType._syntaxNode) }) {
      return scope.parent
    }
    
    return scope
  }
}

// MARK: - Symbol resolve
extension GraphImpl {
  enum ResolveSymbolOption: Equatable, CaseIterable {
    case function
    case variable
    case typeDecl
  }
  
  func _findSymbol(_ symbol: Symbol,
                   options: [ResolveSymbolOption] = ResolveSymbolOption.allCases,
                   onResult: (SymbolResolve) -> Bool) -> SymbolResolve? {
    var scope: Scope! = closetScopeThatCanResolveSymbol(symbol)
    while scope != nil {
      if let result: GraphImpl.SymbolResolve = cachedSymbolResolved[symbol], onResult(result) {
        return result
      }
      
      if let result: GraphImpl.SymbolResolve = _findSymbol(symbol, options: options, in: scope, onResult: onResult) {
        cachedSymbolResolved[symbol] = result
        return result
      }
      
      scope = scope?.parent
    }
    
    return nil
  }
  
  func _findSymbol(_ symbol: Symbol,
                   options: [ResolveSymbolOption] = ResolveSymbolOption.allCases,
                   in scope: Scope,
                   onResult: (SymbolResolve) -> Bool) -> SymbolResolve? {
    
    let scopesWithRelatedTypeDecl: [Scope]
    if let typeDecl: TypeDecl = scope.typeDecl {
      scopesWithRelatedTypeDecl = getAllRelatedTypeDecls(from: typeDecl).map { $0.scope }
    } else {
      scopesWithRelatedTypeDecl = [scope]
    }
    
    for scope in scopesWithRelatedTypeDecl {
      if options.contains(.variable) {
        if case let .identifier(node) = symbol, let variable: Variable = scope.getVariable(node) {
          let result: SymbolResolve = .variable(variable)
          if onResult(result) {
            cachedReferencesToVariable[variable] = (cachedReferencesToVariable[variable] ?? []) + [node]
            return result
          }
        }
      }
      
      if options.contains(.function) {
          if let functionDecl: String = try? cursor(symbol.node).annotated_decl_xml_value,
             let source: SourceFileSyntax = try? SyntaxParser.parse(source: functionDecl) {
              let visitor: FunctionDeclVisitor = FunctionDeclVisitor()
              visitor.walk(source)
              if let decl: FunctionDeclSyntax = visitor.decl {
                  let result: SymbolResolve = .function(decl)
                  if onResult(result) {
                      return result
                  }
              }
          }
      }
      
      if options.contains(.typeDecl) {
        let typeDecls: [TypeDecl] = scope.getTypeDecl(name: symbol.name)
        for typeDecl in typeDecls {
          let result: SymbolResolve = .typeDecl(typeDecl)
          if onResult(result) {
            return result
          }
        }
      }
    }
    
    return nil
  }
}

// MARK: - Variable reference
extension GraphImpl {
  
  @discardableResult
  func resolveVariable(_ identifier: IdentifierExprSyntax) -> Variable? {
    return _findSymbol(.identifier(identifier), options: [.variable]) { (resolve: GraphImpl.SymbolResolve) -> Bool in
      if resolve.variable != nil {
        return true
      }
      return false
    }?.variable
  }
  
  func getVariableReferences(variable: Variable) -> [IdentifierExprSyntax] {
    return cachedReferencesToVariable[variable] ?? []
  }
  
  func couldReferenceSelf(_ node: ExprSyntax) -> Bool {
    if node.isCalledExpr() {
      return false
    }
    
    if let identifierNode: IdentifierExprSyntax = node.as(IdentifierExprSyntax.self) {
      guard let variable: Variable = resolveVariable(identifierNode) else {
        return identifierNode.identifier.text == "self"
      }
      
      switch variable.raw {
      case .param:
        return false
      case let .capture(capturedNode):
        return couldReferenceSelf(ExprSyntax(capturedNode))
      case let .binding(_, valueNode):
        if let valueNode: ExprSyntax = valueNode {
          return couldReferenceSelf(valueNode)
        }
        return false
      }
    }
    
    return false
  }
}

// MARK: - Function resolve
extension GraphImpl {
  func resolveFunction(_ funcCallExpr: FunctionCallExprSyntax) -> (Function, Function.MatchResult.MappingInfo)? {
    if let identifier: IdentifierExprSyntax = funcCallExpr.calledExpression.as(IdentifierExprSyntax.self) { // doSmth(...) or A(...)
      return _findFunction(symbol: .identifier(identifier), funcCallExpr: funcCallExpr)
    }
    
    if let memberAccessExpr: MemberAccessExprSyntax = funcCallExpr.calledExpression.as(MemberAccessExprSyntax.self) { // a.doSmth(...) or .doSmth(...)
      if let base: ExprSyntax = memberAccessExpr.base {
        return _findFunction(symbol: .token(memberAccessExpr.name), funcCallExpr: funcCallExpr)
      } else {
        // Base is omitted when the type can be inferred.
        // For eg, we can say: let s: String = .init(...)
        return nil
      }
    }
    
    if funcCallExpr.calledExpression.is(OptionalChainingExprSyntax.self) {
      // TODO
      return nil
    }
    
    // Unhandled case
    return nil
  }
  
  // TODO: Currently we only resolve to `func`. This could resole to `closure` as well
  private func _findFunction(symbol: Symbol, funcCallExpr: FunctionCallExprSyntax)
    -> (Function, Function.MatchResult.MappingInfo)? {
    
    var result: (Function, Function.MatchResult.MappingInfo)?
    _ = _findSymbol(symbol, options: [.function]) { (resolve: GraphImpl.SymbolResolve) -> Bool in
      switch resolve {
      case .variable, .typeDecl: // This could be due to cache
        return false
      case .function(let function):
          let mustStop: Bool = true
        
        switch function.match(funcCallExpr) {
        case .argumentMismatch,
             .nameMismatch:
          return mustStop
        case .matched(let info):
          guard result == nil else {
            // Should not happenn
            assert(false, "ambiguous")
            return true // Exit
          }
          result = (function, info)
          #if DEBUG
          return mustStop // Continue to search to make sure no ambiguity
          #else
          return true
          #endif
        }
      }
    }
    
    return result
  }
  
  private func _findFunction(from typeDecls: [TypeDecl], symbol: Symbol, funcCallExpr: FunctionCallExprSyntax)
    -> (Function, Function.MatchResult.MappingInfo)? {
      
      for typeDecl in typeDecls {
        for function in typeDecl.scope.getFunctionWithSymbol(symbol) {
          if case let .matched(info) = function.match(funcCallExpr) {
            return (function, info)
          }
        }
      }
      
      return nil
  }
}

// MARK: Type resolve
extension GraphImpl {
  func resolveVariableType(_ variable: Variable) -> TypeResolve {
    if let type: TypeResolve = cachedVariableType[variable] {
      return type
    }
    
    let result: TypeResolve = _resolveType(variable.typeInfo)
    cachedVariableType[variable] = result
    return result
  }
  
  func resolveExprType(_ expr: ExprSyntax) -> TypeResolve {
    if let optionalExpr: OptionalChainingExprSyntax = expr.as(OptionalChainingExprSyntax.self) {
      return .optional(base: resolveExprType(optionalExpr.expression))
    }
    
    if let identifierExpr: IdentifierExprSyntax = expr.as(IdentifierExprSyntax.self) {
      if let variable: Variable = resolveVariable(identifierExpr) {
        return resolveVariableType(variable)
      }
      if identifierExpr.identifier.text == "self" {
        return enclosingTypeDecl(for: expr._syntaxNode).flatMap { .type($0) } ?? .unknown
      }
      // May be global variable, or type like Int, String,...
      return .unknown
    }
    
//    if let memberAccessExpr = node.as(MemberAccessExprSyntax.self) {
//      guard let base = memberAccessExpr.base else {
//        fatalError("Is it possible that `base` is nil ?")
//      }
//
//    }
    
    if let functionCallExpr: FunctionCallExprSyntax = expr.as(FunctionCallExprSyntax.self) {
      let result: TypeResolve = cachedFunCallExprType[functionCallExpr] ?? _resolveFunctionCallType(functionCallExpr: functionCallExpr)
      cachedFunCallExprType[functionCallExpr] = result
      return result
    }
    
    if let arrayExpr: ArrayExprSyntax = expr.as(ArrayExprSyntax.self) {
      return .sequence(elementType: resolveExprType(arrayExpr.elements[0].expression))
    }
    
    if expr.is(DictionaryExprSyntax.self) {
      return .dict
    }
    
    if expr.is(IntegerLiteralExprSyntax.self) {
      return _getAllExtensions(name: ["Int"]).first.flatMap { .type($0) } ?? .name(["Int"])
    }
    if expr.is(StringLiteralExprSyntax.self) {
      return _getAllExtensions(name: ["String"]).first.flatMap { .type($0) } ?? .name(["String"])
    }
    if expr.is(FloatLiteralExprSyntax.self) {
      return _getAllExtensions(name: ["Float"]).first.flatMap { .type($0) } ?? .name(["Float"])
    }
    if expr.is(BooleanLiteralExprSyntax.self) {
      return _getAllExtensions(name: ["Bool"]).first.flatMap { .type($0) } ?? .name(["Bool"])
    }
    
    if let tupleExpr: TupleExprSyntax = expr.as(TupleExprSyntax.self) {
      if tupleExpr.elementList.count == 1, let range: (left: ExprSyntax?, op: TokenSyntax, right: ExprSyntax?) = tupleExpr.elementList[0].expression.rangeInfo {
        if let leftType: TypeResolve = range.left.flatMap({ resolveExprType($0) })?.toNilIfUnknown {
          return .sequence(elementType: leftType)
        } else if let rightType: TypeResolve = range.right.flatMap({ resolveExprType($0) })?.toNilIfUnknown {
          return .sequence(elementType: rightType)
        } else {
          return .unknown
        }
      }
      
      return .tuple(tupleExpr.elementList.map { resolveExprType($0.expression) })
    }
    
    if let subscriptExpr: SubscriptExprSyntax = expr.as(SubscriptExprSyntax.self) {
      let sequenceElementType: TypeResolve = resolveExprType(subscriptExpr.calledExpression).sequenceElementType
      if sequenceElementType != .unknown {
        if subscriptExpr.argumentList.count == 1, let argument: ExprSyntax = subscriptExpr.argumentList.first?.expression {
          if argument.rangeInfo != nil {
            return .sequence(elementType: sequenceElementType)
          }
          if resolveExprType(argument).isInt {
            return sequenceElementType
          }
        }
      }
      
      return .unknown
    }
    
    return .unknown
  }
  
  private func _resolveType(_ typeInfo: TypeInfo) -> TypeResolve {
    switch typeInfo {
    case .exact(let type):
      return resolveType(type)
    case .inferedFromExpr(let expr):
      return resolveExprType(expr)
    case .inferedFromClosure(let closureExpr, let paramIndex, let paramCount):
      // let x: (X, Y) -> Z = { a,b in ...}
      if let closureVariable: Variable = enclosingScope(for: Syntax(closureExpr)).getVariableBindingTo(expr: ExprSyntax(closureExpr)) {
        switch closureVariable.typeInfo {
        case .exact(let type):
          guard let argumentsType: TupleTypeElementListSyntax = (type.as(FunctionTypeSyntax.self))?.arguments else {
            // Eg: let onFetchJobs: JobCardsFetcher.OnFetchJobs = { [weak self] jobs in ... }
            return .unknown
          }
          assert(argumentsType.count == paramCount)
          return resolveType(argumentsType[paramIndex].type)
        case .inferedFromClosure,
             .inferedFromExpr,
             .inferedFromSequence,
             .inferedFromTuple:
          assert(false, "Seems wrong")
          return .unknown
        }
      }
      // TODO: there's also this case
      // var b: ((X) -> Y)!
      // b = { x in ... }
      return .unknown
    case .inferedFromSequence(let sequenceExpr):
      let sequenceType: TypeResolve = resolveExprType(sequenceExpr)
      return sequenceType.sequenceElementType
    case .inferedFromTuple(let tupleTypeInfo, let index):
      if case let .tuple(types) = _resolveType(tupleTypeInfo) {
        return types[index]
      }
      return .unknown
    }
  }
  
  func resolveType(_ type: TypeSyntax) -> TypeResolve {
    if type.isOptional {
      return .optional(base: resolveType(type.wrappedType))
    }
    
    if let arrayType: ArrayTypeSyntax = type.as(ArrayTypeSyntax.self) {
      return .sequence(elementType: resolveType(arrayType.elementType))
    }
    
    if type.is(DictionaryTypeSyntax.self) {
      return .dict
    }
    
    if let tupleType: TupleTypeSyntax = type.as(TupleTypeSyntax.self) {
      return .tuple(tupleType.elements.map { resolveType($0.type) })
    }
    
    if let tokens: [TokenSyntax] = type.tokens, let typeDecl: TypeDecl = resolveTypeDecl(tokens: tokens) {
      return .type(typeDecl)
    } else if let name: [String] = type.name {
      return .name(name)
    } else {
      return .unknown
    }
  }
  
  private func _resolveFunctionCallType(functionCallExpr: FunctionCallExprSyntax, ignoreOptional: Bool = false) -> TypeResolve {
    
    if let (function, _) = resolveFunction(functionCallExpr) {
      if let type: TypeSyntax = function.signature.output?.returnType {
        return resolveType(type)
      } else {
        return .unknown // Void
      }
    }
    
    var calledExpr: ExprSyntax = functionCallExpr.calledExpression
    
    if let optionalExpr: OptionalChainingExprSyntax = calledExpr.as(OptionalChainingExprSyntax.self) { // Must be optional closure
      if !ignoreOptional {
        return .optional(base: _resolveFunctionCallType(functionCallExpr: functionCallExpr, ignoreOptional: true))
      } else {
        calledExpr = optionalExpr.expression
      }
    }
    
    // [X]()
    if let arrayExpr: ArrayExprSyntax = calledExpr.as(ArrayExprSyntax.self) {
      if let typeIdentifier: IdentifierExprSyntax = arrayExpr.elements[0].expression.as(IdentifierExprSyntax.self) {
        if let typeDecl: TypeDecl = resolveTypeDecl(tokens: [typeIdentifier.identifier]) {
          return .sequence(elementType: .type(typeDecl))
        } else {
          return .sequence(elementType: .name([typeIdentifier.identifier.text]))
        }
      } else {
        return .sequence(elementType: resolveExprType(arrayExpr.elements[0].expression))
      }
    }
    
    // [X: Y]()
    if calledExpr.is(DictionaryExprSyntax.self) {
      return .dict
    }
    
    // doSmth() or A()
    if let identifierExpr: IdentifierExprSyntax = calledExpr.as(IdentifierExprSyntax.self) {
      let identifierResolve: GraphImpl.SymbolResolve? = _findSymbol(.identifier(identifierExpr)) { (resolve: GraphImpl.SymbolResolve) in
        switch resolve {
        case .function(let function):
          return function.match(functionCallExpr).isMatched
        case .typeDecl:
          return true
        case .variable:
          return false
        }
      }
      if let identifierResolve: GraphImpl.SymbolResolve = identifierResolve {
        switch identifierResolve {
          // doSmth()
        case .function(let function):
          let returnType: TypeSyntax? = function.signature.output?.returnType
          return returnType.flatMap { resolveType($0) } ?? .unknown
          // A()
        case .typeDecl(let typeDecl):
          return .type(typeDecl)
        case .variable:
          break
        }
      }
    }
    
    // x.y()
    if let memberAccessExpr: MemberAccessExprSyntax = calledExpr.as(MemberAccessExprSyntax.self) {
      if let base: ExprSyntax = memberAccessExpr.base {
        let baseType: TypeResolve = resolveExprType(base)
        if _isCollection(baseType) {
          let funcName: String = memberAccessExpr.name.text
          if ["map", "flatMap", "compactMap", "enumerated"].contains(funcName) {
            return .sequence(elementType: .unknown)
          }
          if ["filter", "sorted"].contains(funcName) {
            return baseType
          }
        }
      } else {
        // Base is omitted when the type can be inferred.
        // For eg, we can say: let s: String = .init(...)
        return .unknown
      }
      
    }
    
    return .unknown
  }
}

// MARK: - TypeDecl resolve
extension GraphImpl {
  
  func resolveTypeDecl(tokens: [TokenSyntax]) -> TypeDecl? {
    guard tokens.count > 0 else {
      return nil
    }
    
    return _resolveTypeDecl(token: tokens[0], onResult: { (typeDecl: TypeDecl) in
      var currentScope: Scope = typeDecl.scope
      for token in tokens[1...] {
        if let scope: Scope = currentScope.getTypeDecl(name: token.text).first?.scope {
          currentScope = scope
        } else {
          return false
        }
      }
      return true
    })
  }
  
  private func _resolveTypeDecl(token: TokenSyntax, onResult: (TypeDecl) -> Bool) -> TypeDecl? {
    let result: GraphImpl.SymbolResolve? =  _findSymbol(.token(token), options: [.typeDecl]) { (resolve: GraphImpl.SymbolResolve) in
      if case let .typeDecl(typeDecl) = resolve {
        return onResult(typeDecl)
      }
      return false
    }
    
    if let result: GraphImpl.SymbolResolve = result, case let .typeDecl(scope) = result {
      return scope
    }
    
    return nil
  }
  
  func getAllRelatedTypeDecls(from: TypeDecl) -> [TypeDecl] {
    var result: [TypeDecl] = _getAllExtensions(typeDecl: from)
    if !from.isExtension {
      result = [from] + result
    } else {
      if let originalDecl: TypeDecl = resolveTypeDecl(tokens: from.tokens) {
        result = [originalDecl] + result
      }
    }
    
    return result + result.flatMap { (typeDecl: TypeDecl) -> [TypeDecl] in
      guard let inheritanceTypes: [InheritedTypeSyntax] = typeDecl.inheritanceTypes else {
        return []
      }
      
      return inheritanceTypes
        .compactMap { resolveTypeDecl(tokens: $0.typeName.tokens ?? []) }
        .flatMap { getAllRelatedTypeDecls(from: $0) }
    }
  }
  
  func getAllRelatedTypeDecls(from: TypeResolve) -> [TypeDecl] {
    switch from.wrappedType {
    case .type(let typeDecl):
      return getAllRelatedTypeDecls(from: typeDecl)
    case .sequence:
      return _getAllExtensions(name: ["Array"]) + _getAllExtensions(name: ["Collection"])
    case .dict:
      return _getAllExtensions(name: ["Dictionary"]) + _getAllExtensions(name: ["Collection"])
    case .name, .tuple, .unknown:
      return []
    case .optional:
      // Can't happen
      return []
    }
  }
  
  private func _getAllExtensions(typeDecl: TypeDecl) -> [TypeDecl] {
    guard let name: [String] = _getTypeDeclFullPath(typeDecl)?.map({ $0.text }) else { return [] }
    return _getAllExtensions(name: name)
  }
  
  private func _getAllExtensions(name: [String]) -> [TypeDecl] {
    return sourceFileScope.childScopes
    .compactMap { $0.typeDecl }
    .filter { $0.isExtension && $0.name == name }
  }
  
  // For eg, type path for C in be example below is A.B.C
  // class A {
  //   struct B {
  //     enum C {
  // Returns nil if the type is nested inside non-type entity like function
  private func _getTypeDeclFullPath(_ typeDecl: TypeDecl) -> [TokenSyntax]? {
    let tokens: [TokenSyntax] = typeDecl.tokens
    if typeDecl.scope.parent?.type == .sourceFileNode {
      return tokens
    }
    if let parentTypeDecl: TypeDecl = typeDecl.scope.parent?.typeDecl, let parentTokens: [TokenSyntax] = _getTypeDeclFullPath(parentTypeDecl) {
      return parentTokens + tokens
    }
    return nil
  }
}

// MARK: - Classification
extension GraphImpl {
  func isClosureEscape(_ closure: ClosureExprSyntax) -> Bool {
    func _isClosureEscape(_ expr: ExprSyntax, isFuncParam: Bool) -> Bool {
      // check cache
      if let closureNode: ClosureExprSyntax = expr.as(ClosureExprSyntax.self), let cachedResult: Bool = cachedClosureEscapeCheck[closureNode] {
        return cachedResult
      }
      
      // If it's a param, and it's inside an escaping closure, then it's also escaping
      // For eg:
      // func doSmth(block: @escaping () -> Void) {
      //   someObject.callBlock {
      //     block()
      //   }
      // }
      // Here block is a param and it's used inside an escaping closure
      if isFuncParam {
        if let parentClosure: ClosureExprSyntax = expr.getEnclosingClosureNode() {
          if isClosureEscape(parentClosure) {
            return true
          }
        }
      }
      
      // Function call expression: {...}()
      if expr.isCalledExpr() {
        return false // Not escape
      }
      
      // let x = closure
      // `x` may be used anywhere
      if let variable: Variable = enclosingScope(for: expr._syntaxNode).getVariableBindingTo(expr: expr) {
        let references: [IdentifierExprSyntax] = getVariableReferences(variable: variable)
        for reference in references {
          if _isClosureEscape(ExprSyntax(reference), isFuncParam: isFuncParam) == true {
            return true // Escape
          }
        }
      }
      
      // Used as argument in function call: doSmth(a, b, c: {...}) or doSmth(a, b) {...}
      if let (functionCall, argument) = expr.getEnclosingFunctionCallExpression() {
        if let (function, matchedInfo) = resolveFunction(functionCall) {
          let param: FunctionParameterSyntax!
          if let argument: FunctionCallArgumentSyntax = argument {
            param = matchedInfo.argumentToParamMapping[argument]
          } else {
            param = matchedInfo.trailingClosureArgumentToParam
          }
          guard param != nil else { fatalError("Something wrong") }
          
          // If the param is marked as `@escaping`, we still need to check with the non-escaping rules
          // If the param is not marked as `@escaping`, and it's optional, we don't know anything about it
          // If the param is not marked as `@escaping`, and it's not optional, we know it's non-escaping for sure
          return TypeEscapeVisitor.detect(code: param?.type?.description ?? "") //&& param!.type?.isOptional == false
//          if !param.isEscaping && param.type?.isOptional != true {
//            return false
//          }
//
//          // get the `.function` scope where we define this func
//          let scope = self.scope(for: function._syntaxNode)
//          assert(scope.type.isFunction)
//
//          guard let variableForParam = scope.variables.first(where: { $0.raw.token == (param.secondName ?? param.firstName) }) else {
//            fatalError("Can't find the Variable that wrap the param")
//          }
//          let references = getVariableReferences(variable: variableForParam)
//          for referennce in references {
//            if _isClosureEscape(ExprSyntax(referennce), isFuncParam: true) == true {
//              return true
//            }
//          }
//          return false
        } else {
          // Still can't figure out using custom rules, assume closure is escaping
          return true
        }
      }
      
      return false // It's unlikely the closure is escaping
    }
    
    let result: Bool = _isClosureEscape(ExprSyntax(closure), isFuncParam: false)
    cachedClosureEscapeCheck[closure] = result
    return result
  }
  
  func isCollection(_ node: ExprSyntax) -> Bool {
    let type: TypeResolve = resolveExprType(node)
    return _isCollection(type)
  }
  
  private func _isCollection(_ type: TypeResolve) -> Bool {
    let isCollectionTypeName: ([String]) -> Bool = { (name: [String]) in
      return name == ["Array"] || name == ["Dictionary"] || name == ["Set"]
    }
    
    switch type {
    case .tuple,
         .unknown:
      return false
    case .sequence,
         .dict:
      return true
    case .optional(let base):
      return _isCollection(base)
    case .name(let name):
      return isCollectionTypeName(name)
    case .type(let typeDecl):
      let allTypeDecls: [TypeDecl] = getAllRelatedTypeDecls(from: typeDecl)
      for typeDecl in allTypeDecls {
        if isCollectionTypeName(typeDecl.name) {
          return true
        }
        
        for inherritedName in (typeDecl.inheritanceTypes?.map { $0.typeName.name ?? [""] } ?? []) {
          // If it extends any of the collection types or implements Collection protocol
          if isCollectionTypeName(inherritedName) || inherritedName == ["Collection"] {
            return true
          }
        }
      }
      
      return false
    }
  }
}

private extension Scope {
  func getVariableBindingTo(expr: ExprSyntax) -> Variable? {
    return variables.first(where: { (variable: Variable) -> Bool in
      switch variable.raw {
      case .param, .capture: return false
      case let .binding(_, valueNode):
        return valueNode != nil ? valueNode! == expr : false
      }
    })
  }
}

private extension TypeResolve {
  var toNilIfUnknown: TypeResolve? {
    switch self {
    case .unknown: return nil
    default: return self
    }
  }
}


public final class FunctionDeclVisitor: SyntaxVisitor {

    private(set) var decl: FunctionDeclSyntax?

    public override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        self.decl = node
        return .skipChildren
    }
    
}
