//
//  RecurrsiveRewriter.swift
//  AutoFill
//
//  Created by 林煒峻 on 2019/9/27.
//

import Foundation

struct RecurrsiveRewriter: Rewriter {
    let rewriter: Rewriter
    func rewrite(description: Description, raw: Data) -> Data {
        let rawSub = self.rewriteSub(description: description, raw: raw)
        return self.rewriteSelf(description: description, raw: rawSub)
    }
    
    private func rewriteSelf(description: Description, raw: Data) -> Data {
        guard let _ = description.structure else {
            return raw
        }
        return self.rewriter.rewrite(description: description, raw: raw)
    }
    
    private func rewriteSub(description: Description, raw: Data) -> Data {
        guard let nexts = description.substructure?.reversed() else {
            return raw
        }

        return nexts.reduce(raw) { (raw: Data, next: Description) -> Data in
            return self.rewrite(description: next, raw: raw)
        }
    }
}
