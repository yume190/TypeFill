//
//  Event.swift
//  TypeFill
//
//  Created by 林煒峻 on 2019/10/1.
//

import Foundation
import Rainbow

enum Event: CustomStringConvertible {
    case openFile(path: String)
    case implictType(origin: String, fixed: String)
    case ibAction(origin: String, fixed: String)
    case ibOutlet(origin: String, fixed: String)
    case objc(origin: String, fixed: String)
    
    private var symbol: String {
        switch self {
        case .openFile(_): return "Open File"
        case .implictType(_, _): return "Implict Type"
        case .ibAction(_, _): return "@IBAction"
        case .ibOutlet(_, _): return "@IBOutlet"
        case .objc(_, _): return "@objc"
        }
    }
    
    var description: String {
        switch self {
        case .openFile(let filePath):
            return """
            \("[OPEN FILE]".applyingCodes(Color.yellow, Style.bold)): \(filePath)
            """
        case .implictType(let origin, let fixed),
             .ibAction(let origin, let fixed),
             .ibOutlet(let origin, let fixed),
             .objc(let origin, let fixed):
            return """
                \("[\(self.symbol)]: \(origin)".applyingColor(.red))
                \("[FIX]: \(fixed)".applyingColor(.green))
            """
        }
    }
}