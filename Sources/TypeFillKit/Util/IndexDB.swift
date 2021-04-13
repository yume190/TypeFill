//
//  IndexDB.swift
//  TypeFillKit
//
//  Created by Yume on 2021/4/13.
//

import Foundation
import IndexStoreDB

/// xcrun --find sourcekit-lsp
/// /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp

/// /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib

public struct IndexStore {
    private static let defaultLibPath = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib"
    
    public let db: IndexStoreDB
    // /Users/yume/git/yume/TypeFill/Sources/TestingData/Index
    
    public init?(path: String) {
        guard let lspPath = Exec.run(
            "/usr/bin/xcrun",
            "--find", "sourcekit-lsp"
        ).string else {return nil}
        
        let indexStoreLibPath: URL = URL(fileURLWithPath: lspPath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("lib")
            .appendingPathComponent("libIndexStore.dylib")

        let libPath = indexStoreLibPath.path
        
        do {
            try self.db = IndexStoreDB(
                storePath: path,
                databasePath: NSTemporaryDirectory() + "index_\(getpid())",
                library: IndexStoreLibrary(dylibPath: libPath)
            )
            db.pollForUnitChangesAndWait()
        } catch {
            print(error)
            return nil
        }
    }
}

//private static let libIndexStore = "/Applications/Xcode-12.3.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib"
//private static let lib = try? IndexStoreLibrary(dylibPath: Self.libIndexStore)
//
////    private static let path = "/Users/yume/Library/Developer/Xcode/DerivedData/Tangran-iOS-gwnoysptyaxistapkuhkxnfauehr/Index/DataStore"
//private static let path = "/Users/yume/git/yume/TypeFill/Sources/TestingData/Index"
//let db: IndexStoreDB = {
//    let db = try! IndexStoreDB(
//        storePath: Self.path,
//        databasePath: NSTemporaryDirectory() + "index_\(getpid())",
//        library: Self.lib
//    )
//    db.pollForUnitChangesAndWait()
//    db.forEachCanonicalSymbolOccurrence(containing: "test", anchorStart: true, anchorEnd: true, subsequence: true, ignoreCase: true) { (so) -> Bool in
//        print(so.symbol.usr)
//        return true
//    }
//    return db
//}()
//
//❯ xcrun --show-sdk-path
