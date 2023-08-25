//
//  Reportable.swift
//  Cursor
//
//  Created by Yume on 2021/10/29.
//

import Foundation
import SwiftSyntax
import Danger

public enum Reporter: String, CaseIterable {
    case xcode
    case vscode
    case danger
    
    private static let _danger = Danger()
    
    public func report(_ info: CodeLocation, reason: String? = nil) {
        let defaultReason = info.syntax?.withoutTrivia().description ?? ""
        let newReason = reason ?? defaultReason
        switch self {
        case .vscode:
            print("\(info.reportVSCode) \(newReason)")
        case .xcode:
            print("\(info.reportXCode) \(newReason)")
        case .danger:
            if let line = info.location.line {
                Reporter._danger.warn(message: newReason, file: info.path, line: line)
            } else {
                Reporter._danger.warn(newReason)
            }
        }
    }
}
