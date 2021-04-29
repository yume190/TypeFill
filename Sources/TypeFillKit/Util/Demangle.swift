//
//  Demangle.swift
//  TypeFillKit
//
//  Created by Yume on 2021/4/13.
//

import Foundation

/// SWIFT_RUNTIME_EXPORT
/// https://github.com/apple/swift/blob/a4e71aa819cfaa25d512555c351377efa968aa68/include/swift/Demangling/Demangle.h#L668
@_silgen_name("swift_demangle")
private func _stdlib_demangleImpl(_ mangledName: UnsafePointer<Int8>?, mangledNameLength: UInt, outputBuffer: UnsafeMutablePointer<Int8>?, outputBufferSize: UnsafeMutablePointer<UInt>?, flags: UInt32) -> UnsafeMutablePointer<Int8>?


func demangle(_ symbol: String) -> String? {
    return symbol.withCString { (cString: UnsafePointer<Int8>) -> String? in
        let std = _stdlib_demangleImpl(
            cString,
            mangledNameLength: UInt(strlen(cString)),
            outputBuffer: nil,
            outputBufferSize: nil,
            flags: 0
        )
        if let demangled = std {
            let out = String(cString: demangled)
            free(demangled)
            return out
        }
        return nil
    }
}
