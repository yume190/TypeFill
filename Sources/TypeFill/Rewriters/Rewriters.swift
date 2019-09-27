//
//  Rewriters.swift
//  AutoFill
//
//  Created by 林煒峻 on 2019/9/27.
//

import Foundation

struct Rewriters: Rewriter {
    let rewriters: [Rewriter]
    func rewrite(description: Description, raw: Data) -> Data {
        return self.rewriters.reduce(raw) { (raw: Data, rewriter: Rewriter) -> Data in
            return rewriter.rewrite(description: description, raw: raw)
        }
    }
}
