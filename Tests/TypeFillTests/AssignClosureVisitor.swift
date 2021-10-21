//
//  AssignClosureVisitor.swift
//  TypeFillTests
//
//  Created by Yume on 2021/10/20.

import Foundation
import XCTest
import SwiftSyntax
@testable import Cursor

final class AssignClosureTests: XCTestCase {
    
    func testNormal() throws {
        let path: String = resource(file: "AssignClosure.swift.data")
        let cursor = try Cursor(path: path)
        let results = AssignClosureVisitor(cursor).detect()
        
        let espect = [
            CodeLocation(path: path, location: SourceLocation(offset: 133, converter: cursor.converter)),
            CodeLocation(path: path, location: SourceLocation(offset: 147, converter: cursor.converter)),
            CodeLocation(path: path, location: SourceLocation(offset: 171, converter: cursor.converter)),
            CodeLocation(path: path, location: SourceLocation(offset: 186, converter: cursor.converter)),
        ]
        
        XCTAssertEqual(results, espect)
    }
}
