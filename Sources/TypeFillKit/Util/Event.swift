//
//  Event.swift
//  TypeFill
//
//  Created by 林煒峻 on 2019/10/1.
//

import Foundation
import Rainbow

public enum Event: CustomStringConvertible {
    case openFile(path: String)
    case implicitType(origin: String, fixed: String)
    case ibAction(origin: String, fixed: String)
    case ibOutlet(origin: String, fixed: String)
    case objc(origin: String, fixed: String)
    
    private var symbol: String {
        switch self {
        case .openFile(_): return "Open File"
        case .implicitType(_, _): return "Implicit Type"
        case .ibAction(_, _): return "@IBAction"
        case .ibOutlet(_, _): return "@IBOutlet"
        case .objc(_, _): return "@objc"
        }
    }
    
    public var description: String {
        switch self {
        case .openFile(let filePath):
            return """
            \("[OPEN FILE]".applyingCodes(Color.yellow, Style.bold)): \(filePath)
            """
        case .implicitType(let origin, let fixed),
             .ibAction(let origin, let fixed),
             .ibOutlet(let origin, let fixed),
             .objc(let origin, let fixed):
            return """
            \("[\(self.symbol)]: \(origin)".applyingColor(.red))
            \("[FIX]:".applyingColor(.green))
            \(fixed.applyingColor(.green))
            """
        }
    }
}
