//
//  Doc.swift
//  TypeFill
//
//  Created by 林煒峻 on 2019/9/27.
//

import Foundation

//"\/Users\/yume\/git\/maxwinbus\/yume\/type\/yume.swift" : {
//    "key.diagnostic_stage" : "source.diagnostic.stage.swift.parse",
//    "key.length" : 846,
//    "key.offset" : 0,
//    "key.substructure" : [

protocol Doc {
    var structure: SwiftDoc? {get}
    var substructure: [SwiftDoc]? {get}
}
