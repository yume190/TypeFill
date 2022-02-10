//
//  GraphLeakDetector.swift
//  SwiftLeakCheck
//
//  Copyright 2020 Grabtaxi Holdings PTE LTE (GRAB), All rights reserved.
//  Use of this source code is governed by an MIT-style license that can be found in the LICENSE file
//
//  Created by Hoang Le Pham on 12/11/2019.
//

import SwiftSyntax
import Cursor

public final class GraphLeakDetector: BaseSyntaxTreeLeakDetector {
  
  override public func detect(_ cursor: Cursor) -> [Leak] {
    var res: [Leak] = []
    let graph: GraphImpl = GraphBuilder.buildGraph(cursor: cursor)
    let visitor: LeakSyntaxVisitor = LeakSyntaxVisitor(graph: graph, cursor: cursor) { (leak: Leak) in
        res.append(leak)
    }
    visitor.walk(cursor.sourceFile)
    return res
  }
}

private final class LeakSyntaxVisitor: BaseGraphVistor {
  private let graph: GraphImpl
  private let cursor: Cursor
  
  private let onLeakDetected: (Leak) -> Void
  
  init(graph: GraphImpl,
       cursor: Cursor,
       onLeakDetected: @escaping (Leak) -> Void) {
    self.graph = graph
    self.cursor = cursor
    self.onLeakDetected = onLeakDetected
  }
  
  override func visit(_ node: IdentifierExprSyntax) -> SyntaxVisitorContinueKind {
    detectLeak(node)
    return .skipChildren
  }
  
  private func detectLeak(_ node: IdentifierExprSyntax) {
    var leak: Leak?
    defer {
      if let leak: Leak = leak {
        onLeakDetected(leak)
      }
    }
    
    if node.getEnclosingClosureNode() == nil {
      // Not inside closure -> ignore
      return
    }
    
    if !graph.couldReferenceSelf(ExprSyntax(node)) {
      return
    }
    
    var currentScope: Scope! = graph.closetScopeThatCanResolveSymbol(.identifier(node))
    var isEscape: Bool = false
    while currentScope != nil {
      if let variable: Variable = currentScope.getVariable(node) {
        if !isEscape {
          // No leak
          return
        }

        switch variable.raw {
        case .param:
          fatalError("Can't happen since a param cannot reference `self`")
        case let .capture(capturedNode):
          if variable.isStrong && isEscape {
            leak = Leak(node: node, capturedNode: ExprSyntax(capturedNode), cursor: cursor)
          }
        case let .binding(_, valueNode):
          if let referenceNode: IdentifierExprSyntax = valueNode?.as(IdentifierExprSyntax.self) {
            if variable.isStrong && isEscape {
              leak = Leak(node: node, capturedNode: ExprSyntax(referenceNode), cursor: cursor)
            }
          } else {
            fatalError("Can't reference `self`")
          }
        }

        return
      }

      if case let .closureNode(closureNode) = currentScope.scopeNode {
        isEscape = graph.isClosureEscape(closureNode)
      }

      currentScope = currentScope.parent
    }

    if isEscape {
      leak = Leak(node: node, capturedNode: nil, cursor: cursor)
      return
    }
  }
}
