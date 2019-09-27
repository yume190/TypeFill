//
//  SwiftDocInfo.swift
//  CYaml
//
//  Created by 林煒峻 on 2019/9/27.
//

import Foundation

struct SwiftDocInfo: Codable, Doc {
    var structure: SwiftDoc? {return nil}
    
    let diagnosticStage: String
    let length: Int
    let offset: Int
    let substructure: [SwiftDoc]?
    enum CodingKeys: String, CodingKey {
        case diagnosticStage = "key.diagnostic_stage"
        case length = "key.length"
        case offset = "key.offset"
        case substructure = "key.substructure"
    }
}
