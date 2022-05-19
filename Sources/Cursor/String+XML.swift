//
//  String+XML.swift
//  TypeFillTests
//
//  Created by Yume on 2021/10/21.
//

import Foundation

extension String {
    var xml: XMLElement? {
        guard let xml = try? XMLDocument(xmlString: self, options: .documentXInclude) else { return nil }
        let root = xml.rootElement()
        return root
    }
    
    var xmlContent: (_ name: String) -> String? {
        return { (name: String) -> String? in
            xml?.elements(forName: name).first?.stringValue
        }
    }
}

extension XMLElement {
    subscript(name: String) -> [XMLElement] {
        self.elements(forName: name)
    }
}
