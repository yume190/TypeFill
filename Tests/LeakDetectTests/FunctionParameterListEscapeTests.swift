//
//  FunctionParameterListEscapeTests.swift
//  TypeFillTests
//
//  Created by Yume on 2021/10/19.
//

import Foundation
import XCTest
@testable import Cursor
@testable import LeakDetectExtension

final class FunctionParameterListEscapeTests: XCTestCase {
    private typealias C = (@escaping (@escaping (Int) -> ()) -> (), Int) -> ()
    private typealias B = (((@escaping (Int) -> ()) -> ()), Int) -> ()
    private let normal = "(@escaping (@escaping (Int) -> ()) -> (), Int) -> ()"
    private let parenthesis = "(((@escaping (Int) -> ()) -> ()), Int) -> ()"
        
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
