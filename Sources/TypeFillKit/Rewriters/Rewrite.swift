//
//  Rewrite.swift
//  
//
//  Created by Yume on 2021/2/4.
//

import Foundation
import SwiftSyntax
import Cursor

public struct Rewrite {
    public let path: String
    public let sourceFile: SourceFileSyntax
    public let fileHandle: FileHandle
    private let cursor: Cursor
    
    public init(path: String, arguments: CompilerArgumentsGettable, config: Configable) throws {
        let file = try File(path: path)
        self.path = path
        
        let _arguments: [String] = arguments(path)
        if config.print {
            self.sourceFile = try SyntaxParser.parse(source: file.contents)
            self.fileHandle = .standardOutput
        } else {
            let url: URL = URL(fileURLWithPath: path)
            self.sourceFile = try SyntaxParser.parse(url)
            self.fileHandle = try FileHandle(forWritingTo: url)
        }
        
        self.cursor = Cursor(filePath: path, sourceFile: self.sourceFile, arguments: _arguments)
    }
    
    public func parse() {
        self.fileHandle.write(self.dump().utf8!)
    }
    
    public func dump() -> String {
        let rewrite: Syntax = TypeFillRewriter(path, cursor).visit(sourceFile)
        
        var result: String = ""
        rewrite.write(to: &result)

        return result
    }
}

