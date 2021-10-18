//
//  File.swift
//  Cursor
//
//  Created by Yume on 2021/10/18.
//

import Foundation
import SourceKittenFramework

public struct File {
    private let file: SourceKittenFramework.File
    public init(path: String) throws {
        guard let file = SourceKittenFramework.File(path: path) else {
            throw SourceKittenError.readFailed(path: path)
        }
        self.file = file
    }
    
    public var contents: String {
        self.file.contents
    }
}

private enum SourceKittenError: Error, CustomStringConvertible {
    /// Failed to read a file at the given path.
    case readFailed(path: String)

    /// An error message corresponding to this error.
    var description: String {
        switch self {
        case let .readFailed(path):
            return "Failed to read file at '\(path)'"
        }
    }
}
