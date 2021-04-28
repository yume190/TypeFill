////
////  IndexStoreDBTests.swift
////  TypeFillTests
////
////  Created by Yume on 2021/4/13.
////
//
//import XCTest
//import SourceKittenFramework
//import IndexStoreDB
//@testable import TypeFillKit
//
//final class IndexStoreDBTests: XCTestCase {
//    
//    private static let root = URL(fileURLWithPath: #file)
//        .deletingLastPathComponent()
//        .deletingLastPathComponent()
//        .deletingLastPathComponent()
//        
//    private static let indexStore_spm = DerivedPath.SPM(root.path)!.indexStorePath!
//    
//    private static let project = root
//        .appendingPathComponent("TypeFill.xcodeproj")
//    private static let indexStore_xcode = DerivedPath(project.path)!.indexStorePath!
//    
//    func testDerive() {
//        let path = IndexStoreDBTests.project.path
//        print(DerivedPath(path)!.name)
//        print(DerivedPath(path)!.indexStorePath!)
//        
//        print(IndexStoreDBTests.indexStore_xcode)
//        print(IndexStoreDBTests.indexStore_spm)
//    }
//        
//    func testInSPM() throws {
//        guard ProcessInfo.processInfo.environment["PWD"] == IndexStoreDBTests.root.path else {
//            return
//        }
//            
//        let db = IndexStore(path: IndexStoreDBTests.indexStore_spm)
//    }
//    
//    func testInXcode() {
//        guard ProcessInfo.processInfo.environment["PWD"] != IndexStoreDBTests.root.path else {
//            return
//        }
//        
//        let db = IndexStore(path: IndexStoreDBTests.indexStore_xcode)!.db
//        // [def|canon]
//        /// TypeFillKit::/Users/yume/git/yume/TypeFill/Sources/TypeFillKit/Rewriters/Rewrite.swift:12:15 | Rewrite | struct | s:11TypeFillKit7RewriteV | [def|canon]
//        let result = db.canonicalOccurrences(ofName: "Rewrite")
//        let usr = "s:11TypeFillKit7RewriteV"
//        db.occurrences(ofUSR: usr, roles: .all)
//        
//        db.occurrences(ofUSR: "s:11TypeFillKit7RewriteV", roles: .all).forEach { (so) in
//            print("\(so.location.path):\(so.location.line):\(so.location.utf8Column)")
//        }
//        db.occurrences(relatedToUSR: "s:11TypeFillKit7RewriteV", roles: .all)
//        
//        XCTAssertEqual(result.count, 1)
//    }
//
//}
