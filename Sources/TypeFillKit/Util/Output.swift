//
//  Output.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/5.
//

import Foundation

/// https://nshipster.com/textoutputstream/

import func Darwin.fputs
import var Darwin.stderr

struct StderrOutputStream: TextOutputStream {
    mutating func write(_ string: String) {
        fputs(string, stderr)
    }
}

struct FileHandleOutputStream: TextOutputStream {
    private let fileHandle: FileHandle
    let encoding: String.Encoding

    init(_ fileHandle: FileHandle, encoding: String.Encoding = .utf8) {
        self.fileHandle = fileHandle
        self.encoding = encoding
    }

    mutating func write(_ string: String) {
        if let data: Data = string.data(using: encoding) {
            fileHandle.write(data)
        }
    }
}
