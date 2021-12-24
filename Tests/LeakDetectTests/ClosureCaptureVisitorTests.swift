////
////  ClosureCaptureVisitorTests.swift
////  TypeFillTests
////
////  Created by Yume on 2021/10/26.
////
//
//import Foundation
//import XCTest
//import SwiftSyntax
//@testable import Cursor
//@testable import LeakDetectExtension
//
//final class ClosureCaptureVisitorTests: XCTestCase {
//    
//    func testNormal() throws {
//        let path: String = resource(file: "Temp123.swift.data")
//        let cursor = try Cursor(path: path)
//        let v = ClosureCaptureVisitor(cursor)
//        v.walk(cursor.sourceFile)
//    }
//}
