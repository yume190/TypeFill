//
//  Cursor.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/5.
//

import Foundation
import SwiftSyntax
import SourceKittenFramework

/// "key.length" : 1,
/// "key.name" : "a",
/// "key.offset" : 4,
/// "key.typename" : "Int",
/// "key.typeusr" : "$sSiD",
/// "key.usr" : "s:6sample1aSivp"
/// "key.annotated_decl" : "<Declaration>let a: <Type usr=\"s:Si\">Int<\/Type><\/Declaration>",
/// "key.filepath" : "...",
/// "key.fully_annotated_decl" : "<decl.var.global><syntaxtype.keyword>let<\/syntaxtype.keyword> <decl.name>a<\/decl.name>: <decl.var.type><ref.struct usr=\"s:Si\">Int<\/ref.struct><\/decl.var.type><\/decl.var.global>",
/// "key.kind" : "source.lang.swift.decl.var.global",
struct SourceKitResponse {
    private let raw: [String : SourceKitRepresentable]
    init(_ raw: [String : SourceKitRepresentable]) {
        self.raw = raw
    }
    
    private func addPrefix(_ name: String) -> String {
        return "key.\(name)"
    }
    
    private subscript(_ key: String) -> SourceKitRepresentable? {
        return self.raw[self.addPrefix(key)]
    }
    
    var typename: String? {
        return self[#function] as? String
    }

    var typeSyntax: TypeSyntax? {
//        guard let type: String = self.typename else {return nil}
        if self.name == "_" || self.name == nil { return nil }
        guard let type = self.decl else {return nil}
        
        return SyntaxFactory.makeTypeIdentifier(type)
    }
    
    var fully_annotated_decl: String? {
        return self[#function] as? String
    }
    
    var annotated_decl: String? {
        return self[#function] as? String
    }

    // TODO:
    // closure paremeter:
    // <decl.var.parameter>
    //     <decl.var.parameter.type><ref.struct usr="s:Si">Int</ref.struct></decl.var.parameter.type>
    // </decl.var.parameter>
    // <decl.var.global>
    //     <decl.var.type><ref.typealias usr=\"s:4main6NewInta\">NewInt</ref.typealias>?</decl.var.type>
    // </decl.var.global>
    var decl: String? {
        guard let xmlString = fully_annotated_decl else { return nil }
        let xml = try? XMLDocument(xmlString: xmlString, options: .documentTidyXML)
        let root = xml?.rootElement()
        
        return root?.elements(forName: "decl.var.type").first?.stringValue ??
            root?.elements(forName: "decl.var.parameter.type").first?.stringValue
    }

    var name: String? {
        return self[#function] as? String
    }
    var typeusr: String? {
        return self[#function] as? String
    }
    var usr: String? {
        return self[#function] as? String
    }
    
    var length: Int64? {
        return self[#function] as? Int64
    }
    
    var offset: Int64? {
        return self[#function] as? Int64
    }
    
    var isHaveInout: Bool {
        guard let usr = self.usr else { return false }
        guard let demangled = demangle(USR.toDemagle(usr)) else { return false }
        return demangled.contains("(inout ")
    }
}

struct Cursor {
    let filePath: String
    let arguments: [String]
    
    func callAsFunction(_ offset: Int) throws -> SourceKitResponse {
        let raw: [String : SourceKitRepresentable] = try Request.cursorInfo(file: filePath, offset: ByteCount(offset), arguments: arguments).send()
        return SourceKitResponse(raw)
    }
}
