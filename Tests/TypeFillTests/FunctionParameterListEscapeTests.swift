//
//  FunctionParameterListEscapeTests.swift
//  TypeFillTests
//
//  Created by Yume on 2021/10/19.
//

import Foundation
import XCTest
import SwiftSyntax
@testable import Cursor

public final class FunctionDeclVisitor: SyntaxVisitor {

    private(set) var decl: FunctionDeclSyntax?

    public override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        self.decl = node
        return .skipChildren
    }
}


final class FunctionParameterListEscapeTests: XCTestCase {
    private typealias C = (@escaping (@escaping (Int) -> ()) -> (), Int) -> ()
    private typealias B = (((@escaping (Int) -> ()) -> ()), Int) -> ()
    private let normal = "(@escaping (@escaping (Int) -> ()) -> (), Int) -> ()"
    private let parenthesis = "(((@escaping (Int) -> ()) -> ()), Int) -> ()"
    
//    func testTemp() throws {
////        func doSmth1(block: @escaping (Int) -> Void)
//        let target = "func doSmth1(block: @escaping (Int) -> Void)"
//        let source = try SyntaxParser.parse(source: target)
//        let visitor = FunctionParameterListEscapeVisitor(0)
//        visitor.walk(source)
//    }
    
    func testNormal0() throws {
        let target = self.normal
        XCTAssertTrue(FunctionParameterListEscapeVisitor.detect(code: target, index: 0))
    }
    
    func testNormal1() throws {
        let target = self.normal
        XCTAssertFalse(FunctionParameterListEscapeVisitor.detect(code: target, index: 1))
    }
    
    func testParenthesis0() throws {
        let target = self.parenthesis
        XCTAssertTrue(FunctionParameterListEscapeVisitor.detect(code: target, index: 0))
    }
    
    func testParenthesis1() throws {
        let target = self.parenthesis
        XCTAssertFalse(FunctionParameterListEscapeVisitor.detect(code: target, index: 1))
    }
}
