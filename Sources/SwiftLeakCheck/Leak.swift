//
//  LeakDetection.swift
//  SwiftLeakCheck
//
//  Copyright 2020 Grabtaxi Holdings PTE LTE (GRAB), All rights reserved.
//  Use of this source code is governed by an MIT-style license that can be found in the LICENSE file
//
//  Created by Hoang Le Pham on 27/10/2019.
//

import Foundation
import SwiftSyntax
import Cursor

open class Leak: CustomStringConvertible, Encodable {
  public let node: IdentifierExprSyntax
  public let capturedNode: ExprSyntax?
  public let cursor: Cursor

  public private(set) lazy var line: Int = {
    return cursor.converter.location(for: node.positionAfterSkippingLeadingTrivia).line ?? -1
  }()

  public private(set) lazy var column: Int = {
    return cursor.converter.location(for: node.positionAfterSkippingLeadingTrivia).column ?? -1
  }()

  public init(node: IdentifierExprSyntax,
              capturedNode: ExprSyntax?,
              cursor: Cursor) {
    self.node = node
    self.capturedNode = capturedNode
    self.cursor = cursor
  }

  private enum CodingKeys: CodingKey {
    case line
    case column
    case reason
  }

  open func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(line, forKey: .line)
    try container.encode(column, forKey: .column)

    let reason: String = {
      return "`self` is strongly captured here, from a potentially escaped closure."
    }()
    try container.encode(reason, forKey: .reason)
  }

  open var description: String {
    return """
    \(cursor.path):\(line):\(column)
    """
  }
}

extension Leak: Reportable {
    public var reportXCode: String {
        return "col: \(column) `\(node.description)`"
    }
    
    public var reportXCodeLocation: SourceLocation? {
        return self.cursor(offset: node)
    }
    
    public var reportVSCode: String {
        return self.description.red
    }
}
