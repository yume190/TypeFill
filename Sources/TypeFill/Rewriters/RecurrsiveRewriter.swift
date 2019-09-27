//
//  RecurrsiveRewriter.swift
//  AutoFill
//
//  Created by 林煒峻 on 2019/9/27.
//

import Foundation

struct RecurrsiveRewriter: Rewriter {
    let rewriters: Rewriters
    func rewrite(description: Description, raw: Data) -> Data {
        guard let nexts = description.substructure?.reversed() else {
            return self.rewriters.rewrite(description: description, raw: raw)
        }
        
        return nexts.reduce(raw) { (raw: Data, next: Description) -> Data in
            return self.rewrite(description: next, raw: raw)
        }
    }
}
