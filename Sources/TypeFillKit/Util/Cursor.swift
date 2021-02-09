//
//  Cursor.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/5.
//

import Foundation
import SwiftSyntax
import SourceKittenFramework

struct Cursor {
    let filePath: String
    let arguments: [String]
    
    func callAsFunction(_ offset: Int) throws -> TypeSyntax? {
        let request: [String : SourceKitRepresentable] = try Request.cursorInfo(file: filePath, offset: ByteCount(offset), arguments: arguments).send()
        guard let type: String = request["key.typename"] as? String else {return nil}
        return SyntaxFactory.makeTypeIdentifier(type)
            .withLeadingTrivia(.spaces(1))
    }
}
