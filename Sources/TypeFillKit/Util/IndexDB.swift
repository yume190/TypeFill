//
//  IndexDB.swift
//  TypeFillKit
//
//  Created by Yume on 2021/4/13.
//

import Foundation
import IndexStoreDB

public protocol IndexStoreProvider {
    var indexStorePath: String? {get}
}

/// xcrun --find sourcekit-lsp
/// /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp
/// libIndexStore:
/// /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib
public struct IndexStore {
    private static let defaultLibPath: String = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libIndexStore.dylib"
    
    public let db: IndexStoreDB
    
    public init?(provider: IndexStoreProvider) {
        guard let path: String = provider.indexStorePath else {return nil}
        self.init(path: path)
    }
    
    public init?(path: String) {
        guard let lspPath: String = Exec.run(
            "/usr/bin/xcrun",
            "--find", "sourcekit-lsp"
        ).string else {return nil}
        
        let indexStoreLibPath: URL = URL(fileURLWithPath: lspPath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("lib/libIndexStore.dylib")

        let libPath: String = indexStoreLibPath.path
        
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
