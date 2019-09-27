//
//  Rewriter.swift
//  AutoFill
//
//  Created by 林煒峻 on 2019/9/27.
//

import Foundation

protocol Rewriter {
    typealias Description = Doc
    func rewrite(description: Description, raw: Data) -> Data
}

extension Rewriter {
    static var typeFill: Rewriter { return AutoFillRewriter() }
    static func build(rewriters: [Rewriter]) -> Rewriter {
        let rewriters = Rewriters(rewriters: rewriters)
        return RecurrsiveRewriter(rewriters: rewriters)
    }
}

enum RewriterFactory {
    static var typeFill: Rewriter { return AutoFillRewriter() }
    static func build(rewriters: [Rewriter]) -> Rewriter {
        let rewriters = Rewriters(rewriters: rewriters)
        return RecurrsiveRewriter(rewriters: rewriters)
    }
}
