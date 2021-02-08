//
//  File.swift
//  
//
//  Created by Yume on 2021/2/4.
//

import Foundation
import SourceKittenFramework
import SwiftSyntax
import SwiftSyntaxBuilder

//extension Configable {
//    @ArrayBuilder<SyntaxRewriter>
//    func rewriters(cursor: Cursor, converter: SourceLocationConverter) -> [SyntaxRewriter] {
//        if typeFill {
//            TypeFillRewriter(cursor, converter)
//        }
//    }
//}


public struct Rewrite {
    let file: File
    let cursor: Cursor
    let config: Configable
    
    let path: String
    let sourceFile: SourceFileSyntax
    let fileHandle: FileHandle
    let converter: SourceLocationConverter
    
//    @ArrayBuilder<SyntaxRewriter>
//    var rewriters: [SyntaxRewriter] {
//        if config.typeFill {
//            TypeFillRewriter(file.path!, cursor, converter)
//        }
//    }
    
    init?(file: File, cursor: Cursor, config: Configable) throws {
        self.file = file
        self.cursor = cursor
        self.config = config
        
        guard let path = file.path else { return nil }
        self.path = path
        
        if config.print {
            self.sourceFile = try SyntaxParser.parse(source: file.contents)
            self.fileHandle = .standardOutput
        } else {
            let url = URL(fileURLWithPath: path)
            sourceFile = try SyntaxParser.parse(url)
            fileHandle = try FileHandle(forWritingTo: url)
        }
        self.converter = .init(file: path, tree: self.sourceFile)
    }
    
    public func parse() throws {
        let rewrite = TypeFillRewriter(path, cursor, converter).visit(sourceFile)
        
        var result = ""
        rewrite.write(to: &result)

        self.fileHandle.write(result.data(using: .utf8)!)
    }
    
    public func dump() throws -> String {
        let rewrite = TypeFillRewriter(path, cursor, converter).visit(sourceFile)
        
        var result = ""
        rewrite.write(to: &result)

        return result
    }
}

