//
//  Attributes.swift
//  AutoFill
//
//  Created by 林煒峻 on 2019/9/25.
//

import Foundation


enum Kind: String, Codable {
    case `struct` = "source.lang.swift.decl.struct"
    
    case memberVar = "source.lang.swift.decl.var.instance"
    case localVar = "source.lang.swift.decl.var.local"
}



struct SourceKittenItem: Codable {
    let accessibility: Accessibility
//    "key.annotated_decl"
    let attributes: [Attribute] //?
    let filePath: String?
//    "key.fully_annotated_decl"
//    let bodyLength: Int // 1 only
//    let bodyOffset: Int // 1 only
    let kind: Kind
    let length: Int
    let name: String
    let nameLength: Int
    let nameOffset: Int
    let offset: Int
    
//    "key.parsed_declaration"
//    "key.parsed_scope.
//    "key.parsed_scope.
//    "key.setter_accessibility"
    let typeName: String?
//    "key.typeusr"
//    "key.usr"
    
    enum CodingKeys: String, CodingKey {
        case accessibility = "key.accessibility"
        //    "key.annotated_decl"
        case attributes = "key.attributes"
        case filePath = "key.filepath"
        //    "key.fully_annotated_decl"
        case bodyLength = "key.bodylength"
        case bodyOffset = "key.bodyoffset"
        case kind = "key.kind"
        case length = "key.length"
        case name = "key.name"
        case nameLength = "key.namelength"
        case nameOffset = "key.nameoffset"
        case offset = "key.offset"
        
        //    "key.parsed_declaration"
        //    "key.parsed_scope.
        //    "key.parsed_scope.
        //    "key.setter_accessibility"
        case typeName = "key.typename"
        //    "key.typeusr"
        //    "key.usr"
    }
}

// MARK: Public
extension SourceKittenItem {
    public func isImplicitVariable(raw: Data) -> Bool {
        return self.isVariable && self.isImplicitType(raw: raw)
    }
    
    /// 96 `
    func isKeywordVar(raw: Data) -> Bool {
        let before = raw[self.nameOffset]
        let after = raw[self.nameOffset + nameLength + 1]
        return before == 96 && before == after
    }
    
    func getNameType(raw: Data) -> String {
        guard let type = self.typeName else {return self.name}
        let name = self.isKeywordVar(raw: raw) ? "`\(self.name)`" : self.name
        return "\(name): \(type)"
    }
}

extension SourceKittenItem {
    private var isVariable: Bool  {
        return self.kind == Kind.localVar || self.kind == Kind.memberVar
    }
    //    if (isKindVar(json) && isImplicitType(raw, json)) {
    //        raw = replacedString(raw, json)
    //    }
    
    /// 58 ":"
    private func isColon(word: UInt8) -> Bool {
        return word == 58
    }
    
    /// 44 ,
    /// 41 )
    private func isTupleMember(word: UInt8) -> Bool {
        return word == 44 || word == 41
    }
    
    private func checkIsImplicitType(word: UInt8) -> Bool {
        return self.isColon(word: word) || self.isTupleMember(word: word)
    }
    
    private func isImplicitType(raw: Data) -> Bool {
        let index = self.isKeywordVar(raw: raw) ?
            self.nameLength + self.nameOffset + 2 :
            self.nameLength + self.nameOffset
        let word = raw[index]
        return self.checkIsImplicitType(word: word)
    }
    
    
}
