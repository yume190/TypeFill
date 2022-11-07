//
//  Reportable.swift
//  Cursor
//
//  Created by Yume on 2021/10/29.
//

import Foundation
import SwiftSyntax

public protocol XCodeReportable {
    var reportXCode: String {get}
}

public protocol VSCodeReportable {
    var reportVSCode: String {get}
}

public protocol Reportable: XCodeReportable, VSCodeReportable {}

public enum Reporter: String, CaseIterable {
    case xcode
    case vscode
    
    public func report<R: Reportable>(_ reportable: R) {
        switch self {
        case .vscode:
            print(reportable.reportVSCode)
        case .xcode:
            print(reportable.reportXCode)
        }
    }
}
