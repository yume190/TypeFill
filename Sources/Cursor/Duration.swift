//
//  Duration.swift
//  Cursor
//
//  Created by Yume on 2021/10/25.
//

import Foundation

public enum Duration {
    public static func logger(_ prefix: @autoclosure () throws -> String, verbose: Bool, _ content: () throws -> ()) rethrows {
        if verbose {
            let now = Date()
            try content()
            print("\(try prefix()) \(Date().timeIntervalSince(now)) sec")
        } else {
            try content()
        }
    }
}
