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
struct Attribute {
    let attribute: _Attribute
    let length: Int
    let offset: Int
    
    enum CodingKeys: String, CodingKey {
        case attribute = "key.attribute"
        case length = "key.length"
        case offset = "key.offset"
    }
}

//https://github.com/apple/swift/blob/0a92b1cda36706b5e0bd30c172a24391aa524309/tools/SourceKit/lib/SwiftLang/SwiftLangSupport.cpp#L65-L81
//static UIdent Attr_IBAction("source.decl.attribute.ibaction");
//static UIdent Attr_IBOutlet("source.decl.attribute.iboutlet");
//static UIdent Attr_IBDesignable("source.decl.attribute.ibdesignable");
//static UIdent Attr_IBInspectable("source.decl.attribute.ibinspectable");
//static UIdent Attr_GKInspectable("source.decl.attribute.gkinspectable");
//static UIdent Attr_Objc("source.decl.attribute.objc");
//static UIdent Attr_ObjcNamed("source.decl.attribute.objc.name");
//static UIdent Attr_Private("source.decl.attribute.private");
//static UIdent Attr_FilePrivate("source.decl.attribute.fileprivate");
//static UIdent Attr_Internal("source.decl.attribute.internal");
//static UIdent Attr_Public("source.decl.attribute.public");
//static UIdent Attr_Open("source.decl.attribute.open");
//static UIdent Attr_Setter_Private("source.decl.attribute.setter_access.private");
//static UIdent Attr_Setter_FilePrivate("source.decl.attribute.setter_access.fileprivate");
//static UIdent Attr_Setter_Internal("source.decl.attribute.setter_access.internal");
//static UIdent Attr_Setter_Public("source.decl.attribute.setter_access.public");
//static UIdent Attr_Setter_Open("source.decl.attribute.setter_access.open");
enum _Attribute: String, Codable {
    case ibaction = "source.decl.attribute.ibaction"
    case iboutlet = "source.decl.attribute.iboutlet"
    case ibdesignable = "source.decl.attribute.ibdesignable"
    case ibinspectable = "source.decl.attribute.ibinspectable"
    case gkinspectable = "source.decl.attribute.gkinspectable"
    
    case `objc` = "source.decl.attribute.objc"
    case `objcName` = "source.decl.attribute.objc.name"
    
    case `private` = "source.decl.attribute.private"
    case `fileprivate` = "source.decl.attribute.fileprivate"
    case `internal` = "source.decl.attribute.internal"
    case `public` = "source.decl.attribute.public"
    case `open` = "source.decl.attribute.open"
    
    case `setterPrivate` = "source.decl.attribute.setter_access.private"
    case `setterFileprivate` = "source.decl.attribute.setter_access.fileprivate"
    case `setterIOnternal` = "source.decl.attribute.setter_access.internal"
    case `setterPublic` = "source.decl.attribute.setter_access.public"
    case `setterOpen` = "source.decl.attribute.setter_access.open"
}
