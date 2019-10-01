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
    //    case decode(doc: String)
    case implictType(origin: String, fixed: String)
    
    var description: String {
        switch self {
        case .openFile(let filePath):
            return
                "[OPEN FILE]".applyingCodes(Color.yellow, Style.bold) +
            ": \(filePath)"
        //        case .decode(let doc):
        //            return ""
        case .implictType(let origin, let fixed):
            return """
            \("[FIND]: \(origin)".applyingColor(.red))
            \("[FIX]: \(fixed)".applyingColor(.green))
            """
        }
    }
}
