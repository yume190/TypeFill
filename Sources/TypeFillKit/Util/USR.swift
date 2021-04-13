//
//  USR.swift
//  TypeFillKit
//
//  Created by Yume on 2021/4/13.
//

import Foundation

enum USR {
    /// s:6sample1aSivp -> $s6sample1aSivp
    /// for `demangle(symbol: String)`
    static func toDemagle(_ usr: String) -> String {
        return usr.replacingOccurrences(of: "s:", with: "$s")
    }
    
    /// $s6sample1aSivp -> s:6sample1aSivp
    /// for `IndexStoreDB.occurrences(ofUSR: "s:11TypeFillKit7RewriteV", roles: .all)`
    static func toIndexStoreDB(_ usr: String) -> String {
        return usr.replacingOccurrences(of: "$s", with: "s:")
    }
}
