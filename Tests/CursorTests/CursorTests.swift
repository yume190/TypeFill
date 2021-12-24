//
//  CursorTests.swift
//  CursorTests
//
//  Created by Yume on 2021/10/29.
//

import Foundation
import XCTest
@testable import Cursor

final class CursorTests: XCTestCase {
    
    private lazy var path: String = resource(file: "Cursor.swift.data")
    private lazy var cursor = try! Cursor(path: path)
    
    /// _ = AAA()           // "source.lang.swift.ref.class"
    ///                 // secondary_symbols
    ///                 //     "source.lang.swift.ref.function.constructor"
    /// _ = BBB()           // "source.lang.swift.ref.struct"
    ///                 // secondary_symbols
    ///                 //     "source.lang.swift.ref.function.constructor"
    /// let _c: CCC = .test // "source.lang.swift.ref.enumelement"
    /// _ = CCC.test         // "source.lang.swift.ref.enumelement"
    func testInit() throws {
        var code: SourceKitResponse
        
        /// AAA()
        code = try cursor(795)
        XCTAssertEqual(code.kind, .refClass)
        XCTAssertEqual(code.secondary_symbols?.kind, .refFunctionConstructor)
        
        /// BBB()
        code = try cursor(997)
        XCTAssertEqual(code.kind, .refStruct)
        XCTAssertEqual(code.secondary_symbols?.kind, .refFunctionConstructor)
        
        /// CCC.test -> CCC
        code = try cursor(1271)
        XCTAssertEqual(code.kind, .refEnum)
        
        /// CCC.test -> .test
        code = try cursor(1275)
        XCTAssertEqual(code.kind, .refEnumelement)
    }
    
    /// print(aaa)          // "source.lang.swift.ref.var.local"
    /// print(bbb)          // "source.lang.swift.ref.var.local"
    /// print(ccc)          // "source.lang.swift.ref.var.local"
    /// print(self)         // "source.lang.swift.ref.var.local"
    /// print(this)         // "source.lang.swift.ref.var.local"
    func testLocal() throws {
        var code: SourceKitResponse
        
        /// aaa
        code = try cursor(1406)
        XCTAssertEqual(code.kind, .refVarLocal)
        
        /// bbb
        code = try cursor(1475)
        XCTAssertEqual(code.kind, .refVarLocal)
        
        /// ccc
        code = try cursor(1544)
        XCTAssertEqual(code.kind, .refVarLocal)
        
        /// self
        code = try cursor(1613)
        XCTAssertEqual(code.kind, .refVarLocal)
        
        /// this
        code = try cursor(1682)
        XCTAssertEqual(code.kind, .refVarLocal)
    }
    
    /// print(global)       // "source.lang.swift.ref.var.global"
    /// print(AAA.globalS)  // "source.lang.swift.ref.var.static"
    /// print(AAA.a)        // "source.lang.swift.ref.var.static"
    /// print(AAA.b)        // "source.lang.swift.ref.var.class"
    func testGlobal() throws {
        var code: SourceKitResponse
        
        /// global
        code = try cursor(1786)
        XCTAssertEqual(code.kind, .refVarGlobal)
        
        /// AAA.globalS
        code = try cursor(1860)
        XCTAssertEqual(code.kind, .refVarStatic)
        
        /// AAA.a
        code = try cursor(1930)
        XCTAssertEqual(code.kind, .refVarStatic)
        
        /// AAA.b
        code = try cursor(2000)
        XCTAssertEqual(code.kind, .refVarClass)
    }
    
    /// print(aaa.c)        // "source.lang.swift.ref.var.instance"
    func testInstance() throws {
        var code: SourceKitResponse
        
        /// aaa.c
        code = try cursor(2106)
        XCTAssertEqual(code.kind, .refVarInstance)
    }
    
    /// globalFunc()        // "source.lang.swift.ref.function.free"
    /// AAA.classFunc()     // "source.lang.swift.ref.function.method.class"
    /// AAA.staticFunc()    // "source.lang.swift.ref.function.method.static"
    /// aaa.instanceFunc()  // "source.lang.swift.ref.function.method.instance"
    func testFunc() throws {
        var code: SourceKitResponse
        
        /// globalFunc()
        code = try cursor(2201)
        XCTAssertEqual(code.kind, .refFunctionFree)
        
        /// AAA.classFunc()
        code = try cursor(2278)
        XCTAssertEqual(code.kind, .refFunctionMethodClass)
        
        /// AAA.staticFunc()
        code = try cursor(2359)
        XCTAssertEqual(code.kind, .refFunctionMethodStatic)
        
        /// aaa.instanceFunc()
        code = try cursor(2441)
        XCTAssertEqual(code.kind, .refFunctionMethodInstance)
    }
    
    func testSelf() throws {
        var code: SourceKitResponse
        
        /// func funcInfunc() {
        ///     print(self)         // self parent_loc -> test
        /// }
        code = try cursor(387)
        XCTAssertEqual(code.offset, 331)
        XCTAssertEqual(code.parent_loc, 331)
        
        /// let c: C = { [ccc = aaa, weak this = self] in   // self parent_loc -> test
        code = try cursor(508)
        XCTAssertEqual(code.offset, 331)
        XCTAssertEqual(code.parent_loc, 331)
        
        /// { [weak self] in
        code = try cursor(2601)
        XCTAssertEqual(code.offset, 2601)
        XCTAssertEqual(code.parent_loc, nil)
        
        /// print(self)
        code = try cursor(2632)
        XCTAssertEqual(code.offset, 2601)
        XCTAssertEqual(code.parent_loc, nil)
    }
    
    func testOptionalBinding() throws {
        var code: SourceKitResponse
        
        /// let c: C = { [ccc = aaa, weak this = self] in   // self parent_loc -> test
        ///     if let this1 = this {}                  // "source.lang.swift.decl.var.local"
        ///     guard let this2 = this else {return}    // "source.lang.swift.decl.var.local"
        
        /// this -> weak this
        code = try cursor(605)
        XCTAssertEqual(code.offset, 501)
        XCTAssertEqual(code.parent_loc, nil)
        
        /// this1
        code = try cursor(597)
        XCTAssertEqual(code.offset, 597)
        XCTAssertEqual(code.parent_loc, nil)
        
        /// this2
        code = try cursor(690)
        XCTAssertEqual(code.offset, 690)
        XCTAssertEqual(code.parent_loc, nil)
    }
    
    func testEditorOpen() throws {
        print("open")
        try Duration.logger {
            try cursor.editorOpen()
        }
        
        try Duration.logger {
            _ = try cursor(387)
        }
        try Duration.logger {
            _ = try cursor(508)
        }
        try Duration.logger {
            _ = try cursor(2589)
        }
        try Duration.logger {
            _ = try cursor(2620)
        }
    }
    
    func testEditorWithoutOpen() throws {
        print("not open")
//        try cursor.editorOpen()
        
        try Duration.logger {
            _ = try cursor(387)
        }
        try Duration.logger {
            _ = try cursor(508)
        }
        try Duration.logger {
            _ = try cursor(2589)
        }
        try Duration.logger {
            _ = try cursor(2620)
        }
    }
}
