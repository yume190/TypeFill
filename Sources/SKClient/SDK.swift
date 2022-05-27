//
//  SDK.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/9.
//

import Foundation

public enum SDK: String, CaseIterable {
    case macosx
    case appletvos
    case watchsimulator
    case iphonesimulator
    case appletvsimulator
    case iphoneos
    case watchos
    
    public var path: String? {
        return Exec.run(
            "/usr/bin/xcrun",
            "--sdk", "\(self.rawValue)", "--show-sdk-path"
        ).string
    }
    
    public var pathArgs: [String] {
        if let sdkPath = self.path {
            return ["-sdk", sdkPath]
        } else {
            return []
        }
    }
    
    public static var all: String {
        return SDK
            .allCases
            .map(\.rawValue)
            .joined(separator: "|")
    }
}
