//
//  DerivedPath.swift
//  TypeFillKit
//
//  Created by Yume on 2021/4/13.
//

import Foundation
import CryptoSwift
//import CryptoKit

public func derivedPath(_ path: String) -> String? {
    guard let url = URL(string: path) else { return nil }
    let fileName = url.deletingPathExtension().lastPathComponent
    
    guard let data = path.data(using: .utf8) else { return nil }
    
    let digestBytes = [UInt8](data.md5())
//    let digest: Insecure.MD5.Digest = Insecure.MD5.hash(data: data)
//    let digestBytes: [UInt8] = digest.withUnsafeBytes { (pointer: UnsafeRawBufferPointer)  in
//        return Array(pointer)
//    }

    let digest64 = unsafeBitCast(digestBytes, to: [UInt64].self)
    var resultStr = Array<UInt8>(repeating: 0, count: 28)
    var startValue: UInt64 = 0
    
    startValue = CFSwapInt64BigToHost(digest64[0])
    for index in (0...13).reversed() {
        resultStr[index] = UInt8(startValue % 26) + 97 // 'a'
        startValue /= 26
    }
    
    startValue = CFSwapInt64BigToHost(digest64[1])
    for index in (14...27).reversed() {
        resultStr[index] = UInt8(startValue % 26) + 97 // 'a'
        startValue /= 26
    }
    guard let derived = String(bytes: resultStr, encoding: .utf8) else {return nil}
    return "\(fileName)-\(derived)"
}
