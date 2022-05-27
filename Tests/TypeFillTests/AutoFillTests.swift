import XCTest
import class Foundation.Bundle
import SourceKittenFramework
@testable import TypeFillKit
@testable import SKClient


final class TypeTests: XCTestCase {
    final func testType() throws {
        let code = """
        let a = 1
        var b = a
        """
        
        try client(code: code) { client in
            try XCTAssertEqual(client(4).typeSyntax?.description, "Int")
            try XCTAssertEqual(client(14).typeSyntax?.description, "Int")
        }
    }
}

final class AutoFillTests: XCTestCase {}

// MARK: Pattern Binding
extension AutoFillTests {
    final func testDecl() throws {
        let code = """
        let a = 1
        var b = a
        """
        let result: String = """
        let a: Int = 1
        var b: Int = a
        """
        try rewriter(code: code) { modified in
            XCTAssertEqual(modified, result)
        }
    }
    
    final func testDeclTuple() throws {
        let code = """
        let (a, b) = (1, 2)
        """
        let result: String = """
        let (a, b): (Int, Int) = (1, 2)
        """
        
        try rewriter(code: code) { modified in
            XCTAssertEqual(modified, result)
        }
    }
    
    final func testDeclWithComma() throws {
        let code = """
        struct Test {
            let a, b: Int
            let c = 1, d = 2
        }
        """
        let result: String = """
        struct Test {
            let a: Int, b: Int
            let c: Int = 1, d: Int = 2
        }
        """

        try rewriter(code: code) { modified in
            XCTAssertEqual(modified, result)
        }
    }
}

// MARK: typealais
extension AutoFillTests {
    final func testTypeAliasAndOptional() throws {
        let code = """
        typealias NewInt = Int
        let a: NewInt! = 1
        let b = a
        """
        let result: String = """
        typealias NewInt = Int
        let a: NewInt! = 1
        let b: NewInt? = a
        """

        try rewriter(code: code) { modified in
            XCTAssertEqual(modified, result)
        }
    }
    
    final func testProtocolAnd() throws {
        let code = """
        protocol A {}
        protocol B {}
        extension Int: A, B {}
        
        let a: A & B = 1
        let b = a
        """
        let result: String = """
        protocol A {}
        protocol B {}
        extension Int: A, B {}

        let a: A & B = 1
        let b: A & B = a
        """

        try rewriter(code: code) { modified in
            XCTAssertEqual(modified, result)
        }
    }
}

// MARK: Closure
extension AutoFillTests {
    final func testClosure1() throws {
        let code = """
        let a: (Int, Int) -> String = { a, b -> String in
            return ""
        }
        """
        let result: String = """
        let a: (Int, Int) -> String = { (a: Int, b: Int) -> String in
            return ""
        }
        """

        try rewriter(code: code) { modified in
            XCTAssertEqual(modified, result)
        }
    }
    
    final func testClosure2() throws {
        let code = """
        let a: (Int, Int) -> String = { (a, b) -> String in
            return ""
        }
        """
        let result: String = """
        let a: (Int, Int) -> String = { (a: Int, b: Int) -> String in
            return ""
        }
        """

        try rewriter(code: code) { modified in
            XCTAssertEqual(modified, result)
        }
    }
    
    final func testClosureUnderLine() throws {
        let code = """
        let a: (Int, Int) -> String = { (_, _) -> String in
            return ""
        }
        """
        let result: String = """
        let a: (Int, Int) -> String = { (_, _) -> String in
            return ""
        }
        """

        try rewriter(code: code) { modified in
            XCTAssertEqual(modified, result)
        }
    }
    
    final func testClosureEmpty() throws {
        let code: String = """
        let a: () -> Void = {
            return
        }
        """
        let result = code

        try rewriter(code: code) { modified in
            XCTAssertEqual(modified, result)
        }
    }
}
    
// MARK: Optional Binding
extension AutoFillTests {
    final func testIfLet() throws {
        let code = """
        let a: Int? = nil
        if let aa = a {}
        """
        let result: String = """
        let a: Int? = nil
        if let aa: Int = a {}
        """

        try rewriter(code: code) { modified in
            XCTAssertEqual(modified, result)
        }
    }

    final func testGuardLet() throws {
        let code = """
        let a: Int? = nil
        guard let aa = a else {return}
        """
        let result: String = """
        let a: Int? = nil
        guard let aa: Int = a else {return}
        """

        try rewriter(code: code) { modified in
            XCTAssertEqual(modified, result)
        }
    }
}

// MARK: Array
extension AutoFillTests {
    final func testArrayIndex() throws {
        let code = """
        let array: [Int] = [1]
        let element = array.firstIndex(of: 2)
        """
        let result: String = """
        let array: [Int] = [1]
        let element: Array<Int>.Index? = array.firstIndex(of: 2)
        """

        try rewriter(code: code) { modified in
            XCTAssertEqual(modified, result)
        }
    }
}

// MARK: Skip
extension AutoFillTests {
    // MARK: skip Escaping
    final func _testEscaping1() throws {
        let code = """
        """
        let result: String = """
        typealias Closure = (@escaping Closure2) -> Void
        typealias Closure2 = (Int) -> Void
        var closure: Closure?
        func doSomething1(block: @escaping Closure) {
            closure = block
        }
        doSomething1 { (block: @escaping Closure2) in
            block(111)
        }
        """
        
        try rewriter(code: code) { modified in
            XCTAssertEqual(modified, result)
        }
    }
    
    /// typealias Closure = (@escaping Closure2) -> Void
    /// typealias Closure2 = (Int) -> Void
    /// var closure: Closure?
    /// func doSomething2(block: (Closure)) {
    ///     closure = block
    /// }
    /// doSomething2 { block in
    ///     block(111)
    /// }
    final func _testEscaping2() throws {
        
        let code = """
        """
        let result: String = """
        typealias Closure = (@escaping Closure2) -> Void
        typealias Closure2 = (Int) -> Void
        var closure: Closure?
        func doSomething1(block: (Closure)) {
            closure = block
        }
        doSomething1 { (block: @escaping Closure2) in
            block(111)
        }
        """
        try rewriter(code: code) { modified in
            XCTAssertEqual(modified, result)
        }
    }
    
    /// let a: (Int, inout Int) -> Int = { i, ii in
    ///     return i + ii
    /// }
    // MARK: skip inout
    final func _testInout() throws {
        
        let code = """
        """
        /// let trueResult = """
        /// let a: (Int, inout Int) -> Int = { (i: Int, ii: inout Int) in
        ///     return i + ii
        /// }
        /// """
        let result: String = """
        let a: (Int, inout Int) -> Int = { i, ii in
            return i + ii
        }
        """
        
        try rewriter(code: code) { modified in
            XCTAssertEqual(modified, result)
        }
    }
    
    /// let a: (inout Int, Int) -> Int = { i, ii in
    ///     return i + ii
    /// }
    // MARK: skip inout
    final func _testProtocolInout() throws {
        
        let code = """
        """
        /// let trueResult = """
        /// let a: (inout Int, Int) -> Int = { (i: inout Int, ii: Int) in
        ///     return i + ii
        /// }
        /// """
        let result: String = """
        let a: (inout Int, Int) -> Int = { i, ii in
            return i + ii
        }
        """
        try rewriter(code: code) { modified in
            XCTAssertEqual(modified, result)
        }
    }
}
