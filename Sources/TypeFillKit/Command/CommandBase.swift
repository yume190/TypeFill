//
//  CommandBase.swift
//  
//
//  Created by Yume on 2021/2/2.
//

import Foundation

public protocol Configable {
    #warning("todo arguments")
//    var typeFill: Bool { get }
//    var ibaction: Bool { get }
//    var iboutlet: Bool { get }
//    var objc: Bool { get }
    
    var print: Bool { get }
    var verbose: Bool { get }
}

protocol CommandBase: Configable {
    var args: [String] { get }
}
