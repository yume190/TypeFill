//
//  Rewrite.swift
//  
//
//  Created by Yume on 2021/2/4.
//

import Foundation
import SwiftSyntax
import SKClient

public struct Rewrite {
    public let fileHandle: FileHandle
    private let cursor: SKClient
    
    public init(path: String, cursor: SKClient, config: Configable) throws {
        if config.print {
            self.fileHandle = .standardOutput
        } else {
            let url: URL = URL(fileURLWithPath: path)
            self.fileHandle = try FileHandle(forWritingTo: url)
        }
        
        self.cursor = cursor
    }
    
    public init(path: String, arguments: CompilerArgumentsGettable, config: Configable) throws {
        let _arguments: [String] = arguments(path)
        let cursor: SKClient = try SKClient(path: path, arguments: _arguments)
        try self.init(path: path, cursor: cursor, config: config)
    }
    
    public func parse() {
        self.fileHandle.write(self.dump().utf8!)
    }
    
    public func dump() -> String {
        let rewrite: Syntax = TypeFillRewriter(cursor).visit(cursor.sourceFile)
        
        var result: String = ""
        rewrite.write(to: &result)

        return result
    }
}
