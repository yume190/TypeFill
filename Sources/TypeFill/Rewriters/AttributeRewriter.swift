//
//  AttributeRewrite.swift
//  TypeFill
//
//  Created by 林煒峻 on 2019/10/3.
//

import Foundation

struct AttributeRewriter: Rewriter {
    enum FindItem: String {
        case ibAction, ibOutlet
    }
    
    fileprivate enum FixItem: String {
        case `private` = "private"
        case `final` = "final"
    }
    
    let find: AttributeRewriter.FindItem
    
    func rewrite(description: Description, raw: Data) -> Data {
        switch self.find {
        case .ibAction:
            return self.rewriteAction(description: description, raw: raw)
        case .ibOutlet:
            return self.rewriteOutlet(description: description, raw: raw)
        }
    }
    
    private func fixItem(attributes: [Attribute]) -> [AttributeRewriter.FixItem] {
        var item: [AttributeRewriter.FixItem] = []
        if !attributes.isHaveAccessor { item.append(.private) }
        if !attributes.isFinal { item.append(.final) }
        return item
    }
    
    private func rewriteAction(description: Description, raw: Data) -> Data {
        guard let structure = description.structure else {return raw}
        guard let attributes = structure.attributes else {return raw}
        guard let ibAction = attributes.ibAction else { return raw }
//        return self.replace(attribute: ibAction, attributes: attributes, raw: raw)
        
        let fixItem = self.fixItem(attributes: attributes)
        
        var raw = raw
        let offset = ibAction.offset + ibAction.length
        raw.replaceSubrange(offset..<offset, with: fixItem.attributeData)
        
        logger.add(event: .ibAction(
            origin: structure.parsedDeclaration ?? "",
            fixed: fixItem.attributeString
            ))
        
        return raw
    }
    
    private func rewriteOutlet(description: Description, raw: Data) -> Data {
        guard let structure = description.structure else {return raw}
        guard let attributes = structure.attributes else {return raw}
        guard let ibOutlet = attributes.ibOutlet else { return raw }
//        return self.replace(attribute: ibOutlet, attributes: attributes, raw: raw)
        
        let fixItem = self.fixItem(attributes: attributes)
        
        var raw = raw
        let offset = ibOutlet.offset + ibOutlet.length
        raw.replaceSubrange(offset..<offset, with: fixItem.attributeData)
        
        logger.add(event: .ibOutlet(
            origin: structure.parsedDeclaration ?? "",
            fixed: fixItem.attributeString
            ))
        
        return raw
    }
    
//    private func replace() -> ((_ attribute: Attribute, _ raw: Data) -> Data) {
//        return { (attribute: Attribute, raw: Data) -> Data in
//            let fixItem = self.fixItem(attributes: attributes)
//
//            var raw = raw
//            let offset = attribute.offset + attribute.length
//            raw.replaceSubrange(offset..<offset, with: fixItem.attributeData)
//
//            return raw
//        }
//    }
    
    
    private func replace(attribute: Attribute, attributes: [Attribute], raw: Data) -> Data {
        let fixItem = self.fixItem(attributes: attributes)
        
        var raw = raw
        let offset = attribute.offset + attribute.length
        raw.replaceSubrange(offset..<offset, with: fixItem.attributeData)
        //        logger.add(event: .implictType(
        //            origin: structure.parsedDeclaration ?? "",
        //            fixed: structure.getNameType(raw: raw)
        //            ))
        //
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
