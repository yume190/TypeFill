//
//  SDK.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/9.
//

import Foundation
import ArgumentParser
import TypeFillKit

enum SDK: String, ExpressibleByArgument, CaseIterable {
    case macosx
    case appletvos
    case watchsimulator
    case iphonesimulator
    case appletvsimulator
    case iphoneos
    case watchos
    
    func path() -> String {
        return Exec.run(
            "/usr/bin/xcrun",
            "--sdk", "\(self.rawValue)", "--show-sdk-path"
        ).string ?? ""
    }
    
    static var all: String {
        return SDK
            .allCases
            .map(\.rawValue)
            .joined(separator: "|")
    }
}
