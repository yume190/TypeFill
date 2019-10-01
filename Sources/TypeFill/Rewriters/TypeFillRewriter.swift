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
        let keywordOffset = structure.isKeywordVar(raw: raw) ? 2 : 0
        let offset = structure.nameOffset
        let length = structure.nameLength + keywordOffset

        let head = raw[0..<offset]
        let replace = structure.getNameTypeData(raw: raw)
        let tail = raw[(offset + length)...]
        
        logger.add(event: .implictType(
            origin: structure.parsedDeclaration ?? "",
            fixed: structure.getNameType(raw: raw)
        ))

        return head + replace + tail
    }
}
