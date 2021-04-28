import XCTest
import class Foundation.Bundle
import SourceKittenFramework
@testable import TypeFillKit

struct Config: Configable {
    //    let typeFill: Bool = true
    //    let ibaction: Bool = false
    //    let iboutlet: Bool = false
    //    let objc: Bool = false
    let print: Bool = true
    let verbose: Bool = false
}

final class AutoFillTests: XCTestCase {
    
    private final let sourceFile = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .appendingPathComponent("Resource")
    private final func resource(file: String) -> String {
        return sourceFile.appendingPathComponent(file).path
    }
    
    private final func rewriter(file: String) throws -> Rewrite {
        let path = resource(file: file)
        let arguments = CompilerArguments.ByModule([path, "-sdk", sdkPath()])
        return try Rewrite(path: path, arguments: arguments, config: Config())
    }
    
    /// let a = 1
    /// var b = a
    final func testType() throws {
        let file = resource(file: "Decl.swift.data")
        let args = [file, "-sdk", sdkPath()]
        let cursor = Cursor(filePath: file, arguments: args)
        let type = try cursor(4)
        XCTAssertEqual(type.typeSyntax?.description, "Int")
    }
    
    /// let a = 1
    /// var b = a
    final func testDecl() throws {
        let override = try rewriter(file: "Decl.swift.data").dump()
        let result = """
        let a: Int = 1
        var b: Int = a
        """
        XCTAssertEqual(override, result)
    }
    
    /// let (a, b) = (1, 2)
    final func testTuple() throws {
        let override = try rewriter(file: "Tuple.swift.data").dump()
        let result = """
        let (a, b): (Int, Int) = (1, 2)
        """
        XCTAssertEqual(override, result)
    }
    
    
    /// struct Test {
    ///     let a, b: Int
    ///     let c = 1, d = 2
    /// }
    final func testDeclWithComma() throws {
        let override = try rewriter(file: "DeclWithComma.swift.data").dump()
        let result = """
        struct Test {
            let a: Int, b: Int
            let c: Int = 1, d: Int = 2
        }
        """
        XCTAssertEqual(override, result)
    }
    
    /// typealias NewInt = Int
    /// let a: NewInt = 1
    /// let b = a
    final func testTypeAlias() throws {
        let override = try rewriter(file: "TypeAlias.swift.data").dump()
        let result = """
        typealias NewInt = Int
        let a: NewInt = 1
        let b: NewInt = a
        """
        XCTAssertEqual(override, result)
    }
    
    /// let a: (Int, Int) -> String = { a, b -> String in
    ///     return ""
    /// }
    final func testClosure1() throws {
        let override = try rewriter(file: "Closure1.swift.data").dump()
        let result = """
        let a: (Int, Int) -> String = { (a: Int, b: Int) -> String in
            return ""
        }
        """
        XCTAssertEqual(override, result)
    }
    
    /// let a: (Int, Int) -> String = { (a, b) -> String in
    ///     return ""
    /// }
    final func testClosure2() throws {
        let override = try rewriter(file: "Closure2.swift.data").dump()
        let result = """
        let a: (Int, Int) -> String = { (a: Int, b: Int) -> String in
            return ""
        }
        """
        XCTAssertEqual(override, result)
    }
    
    
    /// let a: (Int, Int) -> String = { (_, _) -> String in
    ///     return ""
    /// }
    final func testClosureUnderLine() throws {
        let override = try rewriter(file: "ClosureUnderLine.swift.data").dump()
        let result = """
        let a: (Int, Int) -> String = { (_, _) -> String in
            return ""
        }
        """
        XCTAssertEqual(override, result)
    }
    
    /// let a: () -> Void = {
    ///     return
    /// }
    final func testClosureEmpty() throws {
        let override = try rewriter(file: "ClosureEmpty.swift.data").dump()
        let result = """
        let a: () -> Void = {
            return
        }
        """
        XCTAssertEqual(override, result)
    }
    
    /// let a: Int? = nil
    /// if let aa = a {}
    final func testIf() throws {
        let override = try rewriter(file: "If.swift.data").dump()
        let result = """
        let a: Int? = nil
        if let aa: Int = a {}
        """
        XCTAssertEqual(override, result)
    }
    
    /// let a: Int? = nil
    /// guard let aa = a else {return}
    final func testGuard() throws {
        let override = try rewriter(file: "Guard.swift.data").dump()
        let result = """
        let a: Int? = nil
        guard let aa: Int = a else {return}
        """
        XCTAssertEqual(override, result)
    }
    
    /// let a: (inout Int) -> Int = { i in
    ///     return i
    /// }
    let a: (inout Int) -> Int = { (i: inout Int) in
        return i
    }
    // MARK: skip inout
    final func testInout() throws {
        let override = try rewriter(file: "Inout.swift.data").dump()
        /// let trueResult = """
        /// let a: (inout Int) -> Int = { (i: inout Int) in
        ///     return i
        /// }
        /// """
        let result = """
        let a: (inout Int) -> Int = { i in
            return i
        }
        """
        XCTAssertEqual(override, result)
    }
    
    /// Returns path to the built products directory.
    var productsDirectory: URL {
        #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
        #else
        return Bundle.main.bundleURL
        #endif
    }
    
    static var allTests = [
        ("testType", testType),
        ("testDecl", testDecl),
        ("testClosure1", testClosure1),
        ("testClosure2", testClosure2),
        ("testClosureEmpty", testClosureEmpty),
        ("testIf", testIf),
        ("testGuard", testGuard),
    ]
}
