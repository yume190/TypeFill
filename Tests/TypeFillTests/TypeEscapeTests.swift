//
//  TypeEscapeTests.swift
//  TypeFillTests
//
//  Created by Yume on 2021/10/19.
//

import Foundation
import XCTest
import SwiftSyntax
@testable import Cursor

typealias Complete = () -> Void

final class TypeEscapeTests: XCTestCase {
    
    private let normal = "@escaping () -> Void"
    private let parenthesis = "(() -> Void)"
    private let parenthesisOption = "(() -> Void)?"
    private let other = "Int"
    
    func testNormal() throws {
        let target = self.normal
        XCTAssertTrue(TypeEscapeVisitor.detect(code: target))
    }
    
    func testParenthesis() throws {
        let target = self.parenthesis
        XCTAssertTrue(TypeEscapeVisitor.detect(code: target))
    }
    
    func testParenthesisOption() throws {
        let target = self.parenthesisOption
        XCTAssertTrue(TypeEscapeVisitor.detect(code: target))
    }
    
    func testOther() throws {
        let target = self.other
        XCTAssertFalse(TypeEscapeVisitor.detect(code: target))
    }
}
