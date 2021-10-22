//
//  BaseSyntaxTreeLeakDetector.swift
//  SwiftLeakCheck
//
//  Copyright 2020 Grabtaxi Holdings PTE LTE (GRAB), All rights reserved.
//  Use of this source code is governed by an MIT-style license that can be found in the LICENSE file
//
//  Created by Hoang Le Pham on 09/12/2019.
//

import SwiftSyntax
import Cursor

open class BaseSyntaxTreeLeakDetector {
  public init() {}
  
  open func detect(_ cursor: Cursor) -> [Leak] {
    fatalError("Implemented by subclass")
  }
}
