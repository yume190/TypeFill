import XCTest
import class Foundation.Bundle
import SourceKittenFramework
@testable import TypeFillKit

struct Config: Configable {
    var typeFill: Bool = true
    var ibaction: Bool = false
    var iboutlet: Bool = false
    var objc: Bool = false
    var print: Bool = true
}

final class AutoFillTests: XCTestCase {
    let bundle: Bundle = Bundle(for: AutoFillTests.self)
    
    let resoucePath = "/Users/yume/git/yume/TypeFill/Tests/TypeFillTests/Resource/"
    func resource(file: String) -> String {
        return resoucePath + file
    }
    
    func rewriter(file: String) throws -> Rewrite? {
        let path = resource(file: file)
        return try Rewrite(
            file: File(path: path)!,
            cursor: .init(filePath: path, arguments: [path, "-sdk", sdkPath()]),
            config: Config()
        )
    }
    
    /// let a = 1
    /// var b = a
    func testType() throws {
        let file = resource(file: "Decl.swift")
        let args = [file, "-sdk", sdkPath()]
        let cursor = Cursor(filePath: file, arguments: args)
        let type = try cursor(4)
        XCTAssertEqual(type?.description, " Int")
    }
    
    /// let a = 1
    /// var b = a
    func testDecl() throws {
        let override = try rewriter(file: "Decl.swift")?.dump()
        let result = """
        let a: Int = 1
        var b: Int = a
        """
        XCTAssertEqual(override, result)
    }
    
    /// let a: (Int, Int) -> String = { a, b -> String in
    ///     return ""
    /// }
    func testClosure1() throws {
        let override = try rewriter(file: "Closure1.swift")?.dump()
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
    func testClosure2() throws {
        let override = try rewriter(file: "Closure2.swift")?.dump()
        let result = """
        let a: (Int, Int) -> String = { (a: Int, b: Int) -> String in
            return ""
        }
        """
        XCTAssertEqual(override, result)
    }
    
    /// let a: Int? = nil
    /// if let aa = a {}
    func testIf() throws {
        let override = try rewriter(file: "If.swift")?.dump()
        let result = """
        let a: Int? = nil
        if let aa: Int = a {}
        """
        XCTAssertEqual(override, result)
    }
    
    /// let a: Int? = nil
    /// guard let aa = a else {return}
    func testGuard() throws {
        let override = try rewriter(file: "Guard.swift")?.dump()
        let result = """
        let a: Int? = nil
        guard let aa: Int = a else {return}
        """
        XCTAssertEqual(override, result)
    }
    
    
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct
//        // results.
//
//        // Some of the APIs that we use below are available in macOS 10.13 and above.
//        guard #available(macOS 10.13, *) else {
//            return
//        }
//
//        let fooBinary = productsDirectory.appendingPathComponent("typefill")
//
//        let process = Process()
//        process.executableURL = fooBinary
//
//        let pipe = Pipe()
//        process.standardOutput = pipe
//
//        try process.run()
//        process.waitUntilExit()
//
//        let data = pipe.fileHandleForReading.readDataToEndOfFile()
//        let output = String(data: data, encoding: .utf8)
//
//        XCTAssertEqual(output, "Hello, world!\n")
//    }

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
        ("testExample", testType),
    ]
}
