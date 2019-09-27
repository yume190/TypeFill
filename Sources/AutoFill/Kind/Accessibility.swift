//
//  Accessibility.swift
//  AutoFill
//
//  Created by 林煒峻 on 2019/9/26.
//

import Foundation

//https://github.com/apple/swift/blob/2c9def8e74ede41f09c431dab5422bb0f8cc6adb/tools/SourceKit/lib/SwiftLang/SwiftEditor.cpp#L1101-L1105
//    static UIdent AccessOpen("source.lang.swift.accessibility.open");
//    static UIdent AccessPublic("source.lang.swift.accessibility.public");
//    static UIdent AccessInternal("source.lang.swift.accessibility.internal");
//    static UIdent AccessFilePrivate("source.lang.swift.accessibility.fileprivate");
//    static UIdent AccessPrivate("source.lang.swift.accessibility.private");
enum Accessibility: String, Codable {
    case `open` = "source.lang.swift.accessibility.open"
    case `public` = "source.lang.swift.accessibility.public"
    case `internal` = "source.lang.swift.accessibility.internal"
    case `fileprivate` = "source.lang.swift.accessibility.fileprivate"
    case `private` = "source.lang.swift.accessibility.private"
}
