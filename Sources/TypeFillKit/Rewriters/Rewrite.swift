//
//  File.swift
//  
//
//  Created by Yume on 2021/2/4.
//

import Foundation
import SourceKittenFramework
import SwiftSyntax

public struct Rewrite {
    public let path: String
    // public let arguments: [String]
    public let config: Configable
    
    public let file: File
    let cursor: Cursor
    public let sourceFile: SourceFileSyntax
    public let fileHandle: FileHandle
    public let converter: SourceLocationConverter
    
    public init(path: String, arguments: [String], config: Configable) throws {
        guard let file = File(path: path) else {
            throw SourceKittenError.readFailed(path: path)
        }
        
        self.path = path
        self.config = config
        self.file = file
        
        self.cursor = Cursor.init(filePath: path, arguments: arguments)
        if config.print {
            self.sourceFile = try SyntaxParser.parse(source: file.contents)
            self.fileHandle = .standardOutput
        } else {
            let url: URL = URL(fileURLWithPath: path)
            self.sourceFile = try SyntaxParser.parse(url)
            self.fileHandle = try FileHandle(forWritingTo: url)
        }
        
        self.converter = SourceLocationConverter(file: path, tree: self.sourceFile)
    }
    
    public func parse() {
        self.fileHandle.write(self.dump().utf8!)
    }
    
    public func dump() -> String {
        let rewrite: Syntax = TypeFillRewriter(path, cursor, converter).visit(sourceFile)
        
        var result: String = ""
        rewrite.write(to: &result)

        return result
    }
}

