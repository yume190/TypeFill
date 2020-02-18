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

extension Array: Rewriter where Element == Rewriter {
    func rewrite(description: Description, raw: Data) -> Data {
        return self.reduce(raw) { (raw: Data, rewriter: Rewriter) -> Data in
            return rewriter.rewrite(description: description, raw: raw)
        }
    }
}

enum RewriterFactory {
    enum Item {
        case typeFill
        case ibAction
        case ibOutlet
        
        var rewriter: Rewriter {
            switch self {
            case .typeFill:
                return TypeFillRewriter()
            case .ibAction:
                return AttributeRewriter(find: .ibAction)
            case .ibOutlet:
                return AttributeRewriter(find: .ibOutlet)
            }
        }
    }
    class Builder {
        private var items: [RewriterFactory.Item]
        
        static var new: Builder { return Builder(items: []) }
        init(items: [RewriterFactory.Item]) {
            self.items = items
        }
        
        @discardableResult
        func add(item: RewriterFactory.Item) -> Builder {
            self.items.append(item)
            return self
        }
        func build() -> Rewriter {
            return RecurrsiveRewriter(rewriter: items.map { $0.rewriter })
        }
    }
//    static func build(items: [RewriterFactory.Item]) -> Rewriter {
//        return RecurrsiveRewriter(rewriter: items.map { $0.rewriter })
//    }
}
