//
//  Reportable.swift
//  Cursor
//
//  Created by Yume on 2021/10/29.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxParser

public protocol XCodeReportable {
    var reportXCode: String {get}
    var reportXCodeLocation: SourceLocation? {get}
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
            let message: Diagnostic.Message = Diagnostic.Message(.warning, "LeakDetect: find at \(reportable.reportXCode)")
            let diag = Diagnostic(message: message, location: reportable.reportXCodeLocation, notes: [], highlights: [], fixIts: [])
            
            print(diag.debugDescription)
        }
    }
}
