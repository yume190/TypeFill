//
//  AutoFillRewriter.swift
//  AutoFill
//
//  Created by 林煒峻 on 2019/9/27.
//

import Foundation

struct TypeFillRewriter: Rewriter {
    func rewrite(description: Description, raw: Data) -> Data {
        guard let structure = description.structure else {return raw}
        guard let _ = structure.name else {return raw}
        return structure.isImplicitVariable(raw: raw) ?
            self.replace(description: description, raw: raw) :
            raw
    }

    private func replace(description: Description, raw: Data) -> Data {
        guard let structure = description.structure else {return raw}
        guard let nameType = structure.getNameType(raw: raw) else {
            #warning("[TODO]: log fix fail")
            return raw
        }
        let keywordOffset: Int = structure.isKeywordVar(raw: raw) ? 2 : 0
        let offset: Int = structure.nameOffset
        let length: Int = structure.nameLength + keywordOffset
        let range: Range<Int> = offset..<(offset+length)

        var raw: Data = raw
        raw.replaceSubrange(range, with: nameType.utf8 ?? Data())
        
        logger.add(event: .implictType(
            origin: structure.parsedDeclaration ?? "",
            fixed: nameType
        ))

        return raw
    }
}
