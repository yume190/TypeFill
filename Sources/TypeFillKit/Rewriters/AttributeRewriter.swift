//
//  AttributeRewrite.swift
//  TypeFill
//
//  Created by 林煒峻 on 2019/10/3.
//

import Foundation

struct AttributeRewriter: Rewriter {
    enum FindItem: String {
        case ibAction, ibOutlet, objc
    }
    
    fileprivate enum FixItem: String {
        case `private` = "private"
        case `final` = "final"
    }
    
    let find: AttributeRewriter.FindItem
    
    func rewrite(description: Description, raw: Data) -> Data {
        switch self.find {
        case .ibAction:
            return self.rewrite(description: description, raw: raw, targetAttribute: \[Attribute].ibAction) { (origin, fixed) -> Event in
                return .ibAction(origin: origin, fixed: fixed)
            }
        case .ibOutlet:
            return self.rewrite(description: description, raw: raw, targetAttribute: \[Attribute].ibOutlet) { (origin, fixed) -> Event in
                return .ibOutlet(origin: origin, fixed: fixed)
            }
        case .objc:
            return self.rewrite(description: description, raw: raw, targetAttribute: \[Attribute].objc) { (origin, fixed) -> Event in
                return .objc(origin: origin, fixed: fixed)
            }
        }
    }
    
    private func fixItem(attributes: [Attribute]) -> [AttributeRewriter.FixItem] {
        var item: [AttributeRewriter.FixItem] = []
        if !attributes.isHaveAccessor { item.append(.private) }
        if !attributes.isFinal { item.append(.final) }
        return item
    }
    
    private func rewrite(description: Description, raw: Data, targetAttribute: KeyPath<[Attribute], Attribute?>, logType: (String, String) -> Event) -> Data {
        guard let structure = description.structure else {return raw}
        guard let attributes = structure.attributes else {return raw}
        guard let attribute = attributes[keyPath: targetAttribute] else {return raw}
        
        let fixItem: [AttributeRewriter.FixItem] = self.fixItem(attributes: attributes)
        
        var raw: Data = raw
        let offset: Int = attribute.offset + attribute.length
        raw.replaceSubrange(offset..<offset, with: fixItem.attributeData)
        
        
        logger.add(event: logType(structure.parsedDeclaration ?? "", fixItem.attributeString))
        
        return raw
    }
}

extension Array where Element == AttributeRewriter.FixItem {
    var attributeString: String {
        if self.count == 0 {
            return ""
        }
        return self.map {$0.rawValue}.joined(separator: " ")
    }
    var attributeData: Data {
        return (" " + self.attributeString).utf8 ?? Data()
    }
}
