//
//  Reportable.swift
//  Cursor
//
//  Created by Yume on 2021/10/29.
//

import Foundation
import SwiftSyntax

public enum Reporter {
    public typealias R = (CodeLocation, String?) -> Void
    
    case xcode
    case vscode
    case custom(R)
    
    public func report(_ info: CodeLocation, reason: String? = nil) {
      let defaultReason = info.syntax?.withoutTrivia().description ?? ""
        let newReason = reason ?? defaultReason
        switch self {
        case .vscode:
            print("\(info.reportVSCode) \(newReason)")
        case .xcode:
            print("\(info.reportXCode) \(newReason)")
        case let .custom(report):
            report(info, reason)
        }
    }
}

extension SyntaxProtocol {
    func withoutTrivia() -> Self {
        return self
            .with(\.leadingTrivia, .spaces(0))
            .with(\.trailingTrivia, .spaces(0))
    }
}
