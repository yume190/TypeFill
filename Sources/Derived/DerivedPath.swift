//
//  DerivedPath.swift
//  TypeFillKit
//
//  Created by Yume on 2021/4/13.
//

import Foundation
import CryptoSwift
//import CryptoKit

// TODO IndexStore
public struct DerivedPath {
    public static let `default`: String = "\(NSHomeDirectory())/Library/Developer/Xcode/DerivedData"
    private let name: String
    
    public init?(_ path: String) {
        let url = URL(fileURLWithPath: path)
        let fileName: String = url.deletingPathExtension().lastPathComponent
        let absolutePath = url.path
        let data = Data(absolutePath.utf8)
        
        let digestBytes: [UInt8] = [UInt8](data.md5())
    //    let digest: Insecure.MD5.Digest = Insecure.MD5.hash(data: data)
    //    let digestBytes: [UInt8] = digest.withUnsafeBytes { (pointer: UnsafeRawBufferPointer)  in
    //        return Array(pointer)
    //    }

        let digest64: [UInt64] = unsafeBitCast(digestBytes, to: [UInt64].self)
        var resultStr: [UInt8] = Array<UInt8>(repeating: 0, count: 28)
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
        guard let derived: String = String(bytes: resultStr, encoding: .utf8) else { return nil }
        self.name = "\(fileName)-\(derived)"
    }

    public func isExist(derivedPath: String = DerivedPath.default) -> Bool {
        return FileManager.default.fileExists(atPath: self.path(derivedPath: derivedPath))
    }
    
    public func path(derivedPath: String = DerivedPath.default) -> String {
        return DerivedPath.default + "/\(name)"
    }
    
    /// .../Index/DataStore
    public var indexStorePath: String? {
        let path = DerivedPath.default + "/\(name)/Index/DataStore"
        guard FileManager.default.fileExists(atPath: path) else { return nil }
        return path
    }
}

extension DerivedPath {
    // TODO IndexStore
    public struct SPM {
        private let root: String
        public init?(_ root: String) {
            guard FileManager.default.fileExists(atPath: root + "/.build") else { return nil }
            self.root = root
        }
        
        /// .../.build/debug/index/store"
        public var indexStorePath: String? {
            let path = root + "/.build/debug/index/store"
            guard FileManager.default.fileExists(atPath: path) else { return nil }
            return path
        }
    }
}
