//
//  USR.swift
//  TypeFillKit
//
//  Created by Yume on 2021/4/13.
//

import Foundation

/// /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libswiftDemangle.dylib
/// https://github.com/apple/swift/blob/main/docs/ABI/Mangling.rst
public enum USR {
    case _demangle(usr: String)
    case _indexStoreDB(usr: String) 
    
    public var usr: String {
        switch self {
        case ._demangle(let usr): fallthrough
        case ._indexStoreDB(let usr): return usr
        }
    }
    
    public func toDemagle() -> USR {
        switch self {
        case ._demangle: return self
        case ._indexStoreDB(let usr): return ._demangle(usr: USR.toDemangle(usr))
        }
    }
    
    public func toIndexStoreDB() -> USR {
        switch self {
        case ._demangle(let usr): return ._indexStoreDB(usr: USR.toIndexStoreDB(usr))
        case ._indexStoreDB: return self
        }
    }
    
    public func demangle() -> String? {
        return _Swift.demangle(self.toDemagle().usr)
    }
    
    /// s:6sample1aSivp -> $s6sample1aSivp
    /// for `demangle(symbol: String)`
    private static func toDemangle(_ usr: String) -> String {
        return usr.replacingOccurrences(of: "s:", with: "$s")
    }
    
    /// $s6sample1aSivp -> s:6sample1aSivp
    /// for `IndexStoreDB.occurrences(ofUSR: "s:11TypeFillKit7RewriteV", roles: .all)`
    private static func toIndexStoreDB(_ usr: String) -> String {
        return usr.replacingOccurrences(of: "$s", with: "s:")
    }
    
    private static func new(_ usr: String) -> USR? {
        if usr.hasPrefix("$s") { return ._demangle(usr: usr) }
        if usr.hasPrefix("s:") { return ._indexStoreDB(usr: usr) }
        return nil
    }
    
    public init?(_ usr: String?) {
        guard let usr: String = usr else { return nil }
        self.init(usr)
    }
    
    public init?(_ usr: String) {
        guard let usr: USR = USR.new(usr) else { return nil }
        self = usr
    }
}
