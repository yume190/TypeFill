//
//  SDK.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/9.
//

import Foundation
import ArgumentParser

enum SDK: String, ExpressibleByArgument, CaseIterable {
    case macosx
    case appletvos
    case watchsimulator
    case iphonesimulator
    case appletvsimulator
    case iphoneos
    case watchos
    func path() -> String {
        let xcrun: URL = URL(fileURLWithPath: "/usr/bin/xcrun")

        let process: Process = Process()
        process.executableURL = xcrun
        process.arguments =  [
            "--sdk",
            "\(self.rawValue)",
            "--show-sdk-path",
        ]
        
        let pipe: Pipe = Pipe()
        process.standardOutput = pipe

        try? process.run()
        process.waitUntilExit()

        let data: Data = pipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\n", with: "") ?? ""
    }
    
    static var all: String {
        return SDK
            .allCases
            .map(\.rawValue)
            .joined(separator: "|")
    }
}
