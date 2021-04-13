//
//  IndexStoreDBTests.swift
//  TypeFillTests
//
//  Created by Yume on 2021/4/13.
//

import XCTest
import SourceKittenFramework
import IndexStoreDB
@testable import TypeFillKit

final class IndexStoreDBTests: XCTestCase {
    
    private static let root = URL(fileURLWithPath: #file)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        
    private static let indexStore_spm = root
        .appendingPathComponent(".build")
        .appendingPathComponent("debug")
        .appendingPathComponent("index")
        .appendingPathComponent("store")
    
    
    private static let project = root
        .appendingPathComponent("TypeFill.xcodeproj")
    private static let derivedData = "/Users/yume/Library/Developer/Xcode/DerivedData/"
    private static let indexStore_xcode = URL(fileURLWithPath: derivedData + derivedPath(project.path)!)
        .appendingPathComponent("Index")
        .appendingPathComponent("DataStore")
        
    func testInSPM() throws {
        guard ProcessInfo.processInfo.environment["PWD"] == IndexStoreDBTests.root.path else {
            return
        }
            
        let db = IndexStore(path: IndexStoreDBTests.indexStore_spm.path)
    }
    
    func testInXcode() {
        guard ProcessInfo.processInfo.environment["PWD"] != IndexStoreDBTests.root.path else {
            return
        }
        
        let db = IndexStore(path: IndexStoreDBTests.indexStore_xcode.path)!.db
        // [def|canon]
        /// TypeFillKit::/Users/yume/git/yume/TypeFill/Sources/TypeFillKit/Rewriters/Rewrite.swift:12:15 | Rewrite | struct | s:11TypeFillKit7RewriteV | [def|canon]
        let result = db.canonicalOccurrences(ofName: "Rewrite")
        let usr = "s:11TypeFillKit7RewriteV"
        db.occurrences(ofUSR: usr, roles: .all)
        
        db.occurrences(ofUSR: "s:11TypeFillKit7RewriteV", roles: .all).forEach { (so) in
            print("\(so.location.path):\(so.location.line):\(so.location.utf8Column)")
        }
        db.occurrences(relatedToUSR: "s:11TypeFillKit7RewriteV", roles: .all)
        
        XCTAssertEqual(result.count, 1)
    }
    
    //sourceFile
//    /Users/yume/git/yume/TypeFill/Sources/TypeFillKit/Rewriters/Rewrite.swift:19:16
//    ▿ roles : [childOf]
//      - rawValue : 512
//    s:11TypeFillKit7RewriteV10sourceFile11SwiftSyntax06SourcefH0Vvp
    
//    - kind : IndexStoreDB.IndexSymbolKind.constructor
//  ▿ roles : [contBy]
    
    // TypeFillKit.Rewrite
//    ▿ 0 : SymbolRelation
//      ▿ symbol : Rewrite | struct | s:11TypeFillKit7RewriteV
//        - usr : "s:11TypeFillKit7RewriteV"
//        - name : "Rewrite"
//        - kind : IndexStoreDB.IndexSymbolKind.struct
//      ▿ roles : [childOf]
//        - rawValue : 512
    
    
    // "TypeFillKit.Rewrite.dump() -> Swift.String"
//    ▿ 0 : SymbolRelation
//      ▿ symbol : dump() | instanceMethod | s:11TypeFillKit7RewriteV4dumpSSyF
//        - usr : "s:11TypeFillKit7RewriteV4dumpSSyF"
//        - name : "dump()"
//        - kind : IndexStoreDB.IndexSymbolKind.instanceMethod
//      ▿ roles : [contBy]
//        - rawValue : 65536
    
//      ▿ 0 : SymbolRelation
//        ▿ symbol : run() | instanceMethod | s:8TypeFill9SPMModuleV3runyyKF
//          - usr : "s:8TypeFill9SPMModuleV3runyyKF"
//          - name : "run()"
//          - kind : IndexStoreDB.IndexSymbolKind.instanceMethod
//        ▿ roles : [contBy]
//          - rawValue : 65536
}

