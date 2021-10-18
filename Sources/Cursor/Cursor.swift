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
public struct SourceKitResponse {
    private let raw: [String : SourceKitRepresentable]
    public init(_ raw: [String : SourceKitRepresentable]) {
        self.raw = raw
    }
    
    private func addPrefix(_ name: String) -> String {
        return "key.\(name)"
    }
    
    private subscript(_ key: String) -> SourceKitRepresentable? {
        return self.raw[self.addPrefix(key)]
    }
    
    public var typename: String? {
        return self[#function] as? String
    }

    public var typeSyntax: TypeSyntax? {
//        guard let type: String = self.typename else {return nil}
        if self.name == "_" || self.name == nil { return nil }
        guard let type = self.decl else {return nil}
        
        return SyntaxFactory.makeTypeIdentifier(type)
    }
    
    public var fully_annotated_decl: String? {
        return self[#function] as? String
    }
    
    public var annotated_decl: String? {
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
    public var decl: String? {
        guard let xmlString = fully_annotated_decl else { return nil }
        let xml = try? XMLDocument(xmlString: xmlString, options: .documentXInclude)
        let root = xml?.rootElement()
        
        return root?.elements(forName: "decl.var.type").first?.stringValue ??
            root?.elements(forName: "decl.var.parameter.type").first?.stringValue
    }

    public var name: String? {
        return self[#function] as? String
    }
    public var typeusr: String? {
        return self[#function] as? String
    }
    public var usr: String? {
        return self[#function] as? String
    }
    
    public var length: Int64? {
        return self[#function] as? Int64
    }
    
    public var offset: Int64? {
        return self[#function] as? Int64
    }
    
    public var isHaveInout: Bool {
        guard let demangled = USR(self.usr)?.demangle() else { return false }
        return demangled.contains("(inout ")
    }
}

public struct Cursor {
    let filePath: String
    let arguments: [String]
    let sourceFile: SourceFileSyntax
    let converter: SourceLocationConverter
    
    public init(filePath: String, sourceFile: SourceFileSyntax, arguments: [String]) {
        self.filePath = filePath
        self.sourceFile = sourceFile
        self.converter = SourceLocationConverter(file: filePath, tree: sourceFile)
        self.arguments = arguments
    }
    
    public func callAsFunction(_ offset: Int) throws -> SourceKitResponse {
        let raw: [String : SourceKitRepresentable] = try Request.cursorInfo(file: filePath, offset: ByteCount(offset), arguments: arguments).send()
        return SourceKitResponse(raw)
    }
    
    public func callAsFunction<Syntax: SyntaxProtocol>(_ syntax: Syntax) -> SwiftSyntax.SourceLocation {
        return self.converter.location(for: syntax.position)
    }
}
