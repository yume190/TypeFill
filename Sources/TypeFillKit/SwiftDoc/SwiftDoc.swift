//
//  SwiftDoc.swift
//  TypeFill
//
//  Created by 林煒峻 on 2019/9/27.
//

import Foundation

struct SwiftDoc: Codable, Doc {
    var structure: SwiftDoc? {return self}
    
    var declarationKind: DeclarationKind? {
        return DeclarationKind(rawValue: self.kind)
    }
    let accessibility: Accessibility?
    //    "key.annotated_decl"
    let attributes: [Attribute]?
    let filePath: String?
    //    "key.fully_annotated_decl"

    //    let bodyLength: Int // 1 only
    //    let bodyOffset: Int // 1 only
    let kind: String // SyntaxKind
    let length: Int
    let name: String?
    let nameLength: Int?
    let nameOffset: Int?
    let offset: Int

    let parsedDeclaration: String?
    //    "key.parsed_declaration"
    //    "key.parsed_scope.
    //    "key.parsed_scope.
    //    "key.setter_accessibility"
    let typeName: String?
    //    "key.typeusr"
    //    "key.usr"

    let substructure: [SwiftDoc]?

    enum CodingKeys: String, CodingKey {
        case accessibility = "key.accessibility"
        //    "key.annotated_decl"
        case attributes = "key.attributes"
        case filePath = "key.filepath"
        //    "key.fully_annotated_decl"

        //        case bodyLength = "key.bodylength"
        //        case bodyOffset = "key.bodyoffset"
        case kind = "key.kind"
        case length = "key.length"
        case name = "key.name"
        case nameLength = "key.namelength"
        case nameOffset = "key.nameoffset"
        case offset = "key.offset"

        case parsedDeclaration = "key.parsed_declaration"
        //    "key.parsed_scope.
        //    "key.parsed_scope.
        //    "key.setter_accessibility"
        case typeName = "key.typename"
        //    "key.typeusr"
        //    "key.usr"

        case substructure = "key.substructure"
    }
}

// MARK: Public
extension SwiftDoc {
    public func isImplicitVariable(raw: Data) -> Bool {
        return self.isVariable && self.isImplicitType(raw: raw)
    }

    /// 96 `
    public func isKeywordVar(raw: Data) -> Bool {
        guard let nameOffset = self.nameOffset else { return false }
        guard let nameLength = self.nameLength else { return false }
        let before: UInt8 = raw[nameOffset]
        let after: UInt8 = raw[nameOffset + nameLength + 1]
        return before == 96 && before == after
    }

    func getNameType(raw: Data) -> String? {
        guard let name = self.name else {return self.name}
        guard let varType = self.typeName else {return name}
        let varName = self.isKeywordVar(raw: raw) ? "`\(name)`" : name
        return "\(varName): \(varType)"
    }
}

extension SwiftDoc {
    private var isVariable: Bool {
        return
            self.declarationKind == DeclarationKind.varClass ||
            self.declarationKind == DeclarationKind.varGlobal ||
            self.declarationKind == DeclarationKind.varInstance ||
            self.declarationKind == DeclarationKind.varLocal ||
            self.declarationKind == DeclarationKind.varParameter ||
            self.declarationKind == DeclarationKind.varStatic
    }

    /// 58 ":"
    private func isColon(word: UInt8) -> Bool {
        return word == 58
    }

    /// 44 "," 41 ")"
    private func isTupleMember(word: UInt8) -> Bool {
        return word == 44 || word == 41
    }

    private func checkIsImplicitType(word: UInt8) -> Bool {
        return !(self.isColon(word: word) || self.isTupleMember(word: word))
    }

    private func isImplicitType(raw: Data) -> Bool {
        guard let nameOffset = self.nameOffset else { return false }
        guard let nameLength = self.nameLength else { return false }
        let index: Int = self.isKeywordVar(raw: raw) ?
            nameLength + nameOffset + 2 :
            nameLength + nameOffset
        let word: UInt8 = raw[index]
        return self.checkIsImplicitType(word: word)
    }
}
