//
//  SourceKitResponse.swift
//  TypeFillTests
//
//  Created by Yume on 2021/10/21.
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
public struct SourceKitResponse {
    private let raw: [String : SourceKitRepresentable]
    public init(_ raw: [String : SourceKitRepresentable]) {
        self.raw = raw
    }
    
    private func addPrefix(_ name: String) -> String {
        return "key.\(name)"
    }
    
    private subscript<SKRepresentable: SourceKitRepresentable>(_ key: String) -> SKRepresentable? {
        return self.raw[self.addPrefix(key)] as? SKRepresentable
    }
    
    public var kind: Kind? {
        guard let kindStr: String = self[#function] else {return nil}
        return Kind(rawValue: kindStr)
    }
    
    public var typename: String? {
        return self[#function]
    }

    public var typeSyntax: TypeSyntax? {
//        guard let type: String = self.typename else {return nil}
        if self.name == "_" || self.name == nil { return nil }
        guard let type = self.decl else {return nil}
        
        return SyntaxFactory.makeTypeIdentifier(type)
    }
    
    public var fully_annotated_decl: String? {
        return self[#function]
    }
    
    public var annotated_decl: String? {
        return self[#function]
    }
    
    public var annotated_decl_xml_value: String? {
        return annotated_decl?.xml?.stringValue
    }
    
    
    
//    guard let xmlString = fully_annotated_decl else { return nil }
//    let xml = try? XMLDocument(xmlString: xmlString, options: .documentXInclude)

    // TODO:
    // closure paremeter:
    // <decl.var.parameter>
    //     <decl.var.parameter.type><ref.struct usr="s:Si">Int</ref.struct></decl.var.parameter.type>
    // </decl.var.parameter>
    // <decl.var.global>
    //     <decl.var.type><ref.typealias usr=\"s:4main6NewInta\">NewInt</ref.typealias>?</decl.var.type>
    // </decl.var.global>
    public var decl: String? {
        guard let xmlString = fully_annotated_decl else { return nil }
        let xml = try? XMLDocument(xmlString: xmlString, options: .documentXInclude)
        let root = xml?.rootElement()
        
        return root?.elements(forName: "decl.var.type").first?.stringValue ??
            root?.elements(forName: "decl.var.parameter.type").first?.stringValue
    }

    public var name: String? {
        return self[#function]
    }
    public var typeusr: String? {
        return self[#function]
    }
    public var usr: String? {
        return self[#function]
    }
    
    public var length: Int64? {
        return self[#function]
    }
    
    public var offset: Int64? {
        return self[#function]
    }
    
    public var isHaveInout: Bool {
        guard let demangled = USR(self.usr)?.demangle() else { return false }
        return demangled.contains("(inout ")
    }
    
    /// usr s:4main1AC3abcyyF
    /// entity-spec ::= decl-name label-list function-signature generic-signature? 'F'    // function
    /// return self.usr?.hasSuffix("F")
    public var isRefInstanceFunction: Bool {
        /// "source.lang.swift.ref.function.method.instance"
        return self.kind == .refFunctionMethodInstance
    }
    
}
