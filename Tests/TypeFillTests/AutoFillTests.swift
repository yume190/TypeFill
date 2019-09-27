import XCTest
import class Foundation.Bundle

func origin(word: UInt8) -> Bool {
    return word != 58 && word != 44 && word != 41
}

func next(word: UInt8) -> Bool {
    return !(word == 58 || word == 44 || word == 41)
}

final class AutoFillTests: XCTestCase {
    func testOrigin() {
        XCTAssertFalse(origin(word: 41))
        XCTAssertFalse(origin(word: 44))
        XCTAssertFalse(origin(word: 58))
        
        XCTAssertTrue(origin(word: 59))
    }
    
    func testNext() {
        XCTAssertFalse(next(word: 41))
        XCTAssertFalse(next(word: 44))
        XCTAssertFalse(next(word: 58))
        
        XCTAssertTrue(next(word: 59))
    }
    
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return
        }

        let fooBinary = productsDirectory.appendingPathComponent("AutoFill")

        let process = Process()
        process.executableURL = fooBinary

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        XCTAssertEqual(output, "Hello, world!\n")
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
        ("testExample", testExample),
    ]
}
