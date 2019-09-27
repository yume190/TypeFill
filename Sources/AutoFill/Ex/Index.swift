//
//  Index.swift
//  AutoFill
//
//  Created by 林煒峻 on 2019/9/26.
//

import Foundation

protocol Rewriter {
    typealias Description = SourceKittenItem
    func rewrite(description: Description, raw: Data) -> Data
}

struct Rewriters: Rewriter {
    let rewriters: [Rewriter]
    func rewrite(description: Description, raw: Data) -> Data {
        var raw = raw
        for rewriter in self.rewriters {
            raw = rewriter.rewrite(description: description, raw: raw)
        }
        return raw
    }
}

struct AutoFillRewriter: Rewriter {
    func rewrite(description: Description, raw: Data) -> Data {
        return raw
    }
}

//
//function getExType(raw, json) {
//    let name = json["key.name"];
//    let type = json["key.typename"];
//    if (isKeywordVar(raw, json)) {
//        name = "`" + name + "`"
//    }
//    return name + ": " + type;
//}
//function replacedString(raw, json) {
//    var keywordOffset = 0
//    if (isKeywordVar(raw, json)) {
//        keywordOffset = 2
//    }
//
//    let offset = json["key.nameoffset"]
//    let length = json["key.namelength"] + keywordOffset
//
//    let head = raw.subarray(0, offset)
//    let replace = Buffer.from(getExType(raw, json))
//    let tail = raw.subarray(offset + length)
//
//    if (json["key.typename"]) {
//        counter += 1;
//        console.log(counter, "補上型態", offset, offset+ length);
//        let decl = json["key.parsed_declaration"];
//        console.log(decl);
//        console.log(replace.toString());
//    }
//
//    return Buffer.concat([head, replace, tail]);
//}
//
//function recurrsive(raw, json) {
//    if (isKindVar(json) && isImplicitType(raw, json)) {
//        raw = replacedString(raw, json)
//    }
//
//    let nexts = json["key.substructure"]
//    if (nexts) {
//        for(let next of nexts.reverse()) {
//            raw = recurrsive(raw, next)
//        }
//    }
//    return raw;
//}
///*
// dict file
// "key.substructure" [] // "key.kind" : "source.lang.swift.decl.var.instance",
// "key.substructure" [] // "key.kind" : "source.lang.swift.decl.var.local",
// */

