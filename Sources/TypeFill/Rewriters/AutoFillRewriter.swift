//
//  AutoFillRewriter.swift
//  AutoFill
//
//  Created by 林煒峻 on 2019/9/27.
//

import Foundation

struct AutoFillRewriter: Rewriter {
    func rewrite(description: Description, raw: Data) -> Data {
        guard let structure = description.structure else {return raw}
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
        
        //    if (json["key.typename"]) {
        //        counter += 1;
        //        console.log(counter, "補上型態", offset, offset+ length);
        //        let decl = json["key.parsed_declaration"];
        //        console.log(decl);
        //        console.log(replace.toString());
        //    }
        
        return head + replace + tail
    }
}
