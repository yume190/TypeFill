//
//  GraphLeakTests.swift
//  TypeFillTests
//
//  Created by Yume on 2021/10/22.
//

import Foundation
import XCTest
import SwiftSyntax
@testable import Cursor
import SwiftLeakCheck

final class GraphLeakTests: XCTestCase {
    
    func testNormal() throws {
        let path: String = resource(file: "Leak1.swift.data")
        let args = SDK.macosx.pathArgs + [
            resource(file: "Leak1.swift.data"),
            resource(file: "Leak2.swift.data"),
            resource(file: "Leak3.swift.data"),
        ]
        
        let cursor = try Cursor(path: path, arguments: args)
        let leaks = GraphLeakDetector().detect(cursor)
        
        let postions = [
            "\(path):4:7",
            "\(path):8:7",
            "\(path):16:7",
            "\(path):30:22",
        ]
        
        XCTAssertEqual(leaks.map(\.description), postions)
    }
}
