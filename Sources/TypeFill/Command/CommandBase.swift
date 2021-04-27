//
//  CommandBase.swift
//  
//
//  Created by Yume on 2021/2/2.
//

import Foundation
import protocol TypeFillKit.Configable

protocol CommandBase: Configable {
    var args: [String] { get }
}

protocol CommandBuild: CommandBase {
    var skipBuild: Bool { get }
}
