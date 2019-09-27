//
//  Attribute.swift
//  AutoFill
//
//  Created by 林煒峻 on 2019/9/26.
//

import Foundation

//    "key.attribute" : "source.decl.attribute.setter_access.private",
//    "key.length" : 12,
//    "key.offset" : 132
struct Attribute: Codable {
    let attribute: DeclarationAttributeKind
    let length: Int
    let offset: Int
    
    enum CodingKeys: String, CodingKey {
        case attribute = "key.attribute"
        case length = "key.length"
        case offset = "key.offset"
    }
}
