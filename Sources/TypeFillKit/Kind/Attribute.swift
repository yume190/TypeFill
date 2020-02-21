//
//  Attribute.swift
//  AutoFill
//
//  Created by 林煒峻 on 2019/9/26.
//

import Foundation

//    "key.attribute" : "source.decl.attribute.setter_access.private",
//    "key.length" : 12,
//    "key.offset" : 132
struct Attribute: Codable {
    let attribute: DeclarationAttributeKind
    let length: Int
    let offset: Int
    
    enum CodingKeys: String, CodingKey {
        case attribute = "key.attribute"
        case length = "key.length"
        case offset = "key.offset"
    }
}

extension Array where Element == Attribute {
    private var _attributes: [DeclarationAttributeKind] {
        return self.map {$0.attribute}
    }
    
    var ibAction: Attribute? {
        return self.filter {$0.attribute == .ibaction}.first
    }
    
    var ibOutlet: Attribute? {
        return self.filter {$0.attribute == .iboutlet}.first
    }
    
    var objc: Attribute? {
        return self.filter {$0.attribute == .objc}.first
    }
    
    var isIBAction: Bool {
        return self._attributes.contains(.ibaction)
    }
    
    var isIBOutlet: Bool {
        return self._attributes.contains(.iboutlet)
    }
    
    private var isOpen: Bool {
        return self._attributes.contains(.open)
    }
    
    private var isPublic: Bool {
        return self._attributes.contains(.public)
    }
    
    private var isInternal: Bool {
        return self._attributes.contains(.internal)
    }
    
    private var isFilePrivate: Bool {
        return self._attributes.contains(.fileprivate)
    }
    
    private var isPrivate: Bool {
        return self._attributes.contains(.private)
    }
    
    var isHaveAccessor: Bool {
        return self.isOpen || self.isPublic || self.isInternal || self.isFilePrivate || self.isPrivate
    }
    
    var isFinal: Bool {
        return self._attributes.contains(.final)
    }
}
