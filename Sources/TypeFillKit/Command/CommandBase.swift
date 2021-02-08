//
//  CommandBase.swift
//  
//
//  Created by Yume on 2021/2/2.
//

import Foundation

protocol Configable {
    var typeFill: Bool { get }
    var ibaction: Bool { get }
    var iboutlet: Bool { get }
    var objc: Bool { get }
    
    var print: Bool { get }
}

protocol CommandBase: Configable {
    var args: [String] { get }
}


public struct Config: Configable {
    public let typeFill: Bool
    public let ibaction: Bool
    public let iboutlet: Bool
    public let objc: Bool
    public let print: Bool
}
