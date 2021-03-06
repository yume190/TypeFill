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
    
    private final let sourceFile: URL = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .appendingPathComponent("Resource")
    private final func resource(file: String) -> String {
        return sourceFile.appendingPathComponent(file).path
    }
    
    private final func rewriter(file: String) throws -> Rewrite {
        let path: String = resource(file: file)
        let arguments: [String] = [path, "-sdk", sdkPath()]
        return try Rewrite(path: path, arguments: arguments, config: Config())
    }
    
    /// let a = 1
    /// var b = a
    final func testType() throws {
        let file: String = resource(file: "Decl.swift.data")
        let args: [String] = [file, "-sdk", sdkPath()]
        let cursor: Cursor = Cursor(filePath: file, arguments: args)
        let type: SourceKitResponse = try cursor(4)
        XCTAssertEqual(type.typeSyntax?.description, "Int")
    }
    
    /// let a = 1
    /// var b = a
    final func testDecl() throws {
        let override: String = try rewriter(file: "Decl.swift.data").dump()
        let result: String = """
        let a: Int = 1
        var b: Int = a
        """
        XCTAssertEqual(override, result)
    }
    
    /// let (a, b) = (1, 2)
    final func testTuple() throws {
        let override: String = try rewriter(file: "Tuple.swift.data").dump()
        let result: String = """
        let (a, b): (Int, Int) = (1, 2)
        """
        XCTAssertEqual(override, result)
    }
    
    
    /// struct Test {
    ///     let a, b: Int
    ///     let c = 1, d = 2
    /// }
    final func testDeclWithComma() throws {
        let override: String = try rewriter(file: "DeclWithComma.swift.data").dump()
        let result: String = """
        struct Test {
            let a: Int, b: Int
            let c: Int = 1, d: Int = 2
        }
        """
        XCTAssertEqual(override, result)
    }
    
    /// typealias NewInt = Int
    /// let a: NewInt! = 1
    /// let b = a
    final func testTypeAlias() throws {
        let override: String = try rewriter(file: "TypeAlias.swift.data").dump()
        let result: String = """
        typealias NewInt = Int
        let a: NewInt! = 1
        let b: NewInt? = a
        """
        XCTAssertEqual(override, result)
    }
    
    /// let a: (Int, Int) -> String = { a, b -> String in
    ///     return ""
    /// }
    final func testClosure1() throws {
        let override: String = try rewriter(file: "Closure1.swift.data").dump()
        let result: String = """
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
        let override: String = try rewriter(file: "Closure2.swift.data").dump()
        let result: String = """
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
        let override: String = try rewriter(file: "ClosureUnderLine.swift.data").dump()
        let result: String = """
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
        let override: String = try rewriter(file: "ClosureEmpty.swift.data").dump()
        let result: String = """
        let a: () -> Void = {
            return
        }
        """
        XCTAssertEqual(override, result)
    }
    
    /// let a: Int? = nil
    /// if let aa = a {}
    final func testIf() throws {
        let override: String = try rewriter(file: "If.swift.data").dump()
        let result: String = """
        let a: Int? = nil
        if let aa: Int = a {}
        """
        XCTAssertEqual(override, result)
    }
    
    /// let a: Int? = nil
    /// guard let aa = a else {return}
    final func testGuard() throws {
        let override: String = try rewriter(file: "Guard.swift.data").dump()
        let result: String = """
        let a: Int? = nil
        guard let aa: Int = a else {return}
        """
        XCTAssertEqual(override, result)
    }
    
    /// let a: (inout Int) -> Int = { i in
    ///     return i
    /// }
    // MARK: skip inout
    final func testInout() throws {
        let override: String = try rewriter(file: "Inout.swift.data").dump()
        /// let trueResult = """
        /// let a: (inout Int) -> Int = { (i: inout Int) in
        ///     return i
        /// }
        /// """
        let result: String = """
        let a: (inout Int) -> Int = { i in
            return i
        }
        """
        XCTAssertEqual(override, result)
    }
    
    /// protocol IInout {
    ///     init(_ build: (inout Int) -> Void)
    /// }
    /// struct _IInout: IInout {
    ///     init(_ build: (inout Int) -> Void) {
    ///
    ///     }
    /// }
    /// let aaa = _IInout { a in
    ///     print(a)
    /// }
    // MARK: skip inout
    final func testProtocolInout() throws {
        let override: String = try rewriter(file: "ProtocolInout.swift.data").dump()
        /// let trueResult = """
        /// let a: (inout Int) -> Int = { (i: inout Int) in
        ///     return i
        /// }
        /// """
        let result: String = """
        protocol IInout {
            init(_ build: (inout Int) -> Void)
        }
        struct _IInout: IInout {
            init(_ build: (inout Int) -> Void) {
            }
        }
        let aaa: _IInout = _IInout { a in
            print(a)
        }
        """
        XCTAssertEqual(override, result)
    }

    /// protocol A {}
    /// protocol B {}
    /// extension Int: A, B {}
    /// 
    /// let a: A & B = 1
    /// let b = a
    final func testProtocolAnd() throws {
        let override: String = try rewriter(file: "ProtocolAnd.swift.data").dump()
        let result: String = """
        protocol A {}
        protocol B {}
        extension Int: A, B {}

        let a: A & B = 1
        let b: A & B = a
        """
        XCTAssertEqual(override, result)
    }
        
    /// let array: [Int] = [1]
    /// let element = array.firstIndex(of: 2)
    final func testArrayIndex() throws {
        let override: String = try rewriter(file: "ArrayIndex.swift.data").dump()
        let result: String = """
        let array: [Int] = [1]
        let element: Array<Int>.Index? = array.firstIndex(of: 2)
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
