//
//  Kind.swift
//  TypeFillTests
//
//  Created by Yume on 2021/10/21.
//

import Foundation

/// https://github.com/apple/swift/blob/b0678ca5244e343cec109b4e7dde4b8bc430a8c1/tools/SourceKit/docs/SwiftSupport.txt
public enum Kind: String, CaseIterable {
    case declFunctionFree = "source.lang.swift.decl.function.free"
    case declFunctionMethodInstance = "source.lang.swift.decl.function.method.instance"
    case declFunctionMethodStatic = "source.lang.swift.decl.function.method.static"
    case declFunctionConstructor = "source.lang.swift.decl.function.constructor"
    case declFunctionDestructor = "source.lang.swift.decl.function.destructor"
    case declFunctionOperator = "source.lang.swift.decl.function.operator"
    case declFunctionSubscript = "source.lang.swift.decl.function.subscript"
    case declFunctionAccessorGetter = "source.lang.swift.decl.function.accessor.getter"
    case declFunctionAccessorSetter = "source.lang.swift.decl.function.accessor.setter"
    case declClass = "source.lang.swift.decl.class"
    case declStruct = "source.lang.swift.decl.struct"
    case declEnum = "source.lang.swift.decl.enum"
    case declEnumelement = "source.lang.swift.decl.enumelement"
    case declProtocol = "source.lang.swift.decl.protocol"
    case declTypealias = "source.lang.swift.decl.typealias"
    case declVarGlobal = "source.lang.swift.decl.var.global"
    case declVarInstance = "source.lang.swift.decl.var.instance"
    case declVarStatic = "source.lang.swift.decl.var.static"
    case declVarLocal = "source.lang.swift.decl.var.local"
    
    case refFunctionFree = "source.lang.swift.ref.function.free"
    case refFunctionMethodInstance = "source.lang.swift.ref.function.method.instance"
    case refFunctionMethodStatic = "source.lang.swift.ref.function.method.static"
    case refFunctionConstructor = "source.lang.swift.ref.function.constructor"
    case refFunctionDestructor = "source.lang.swift.ref.function.destructor"
    case refFunctionOperator = "source.lang.swift.ref.function.operator"
    case refFunctionSubscript = "source.lang.swift.ref.function.subscript"
    case refFunctionAccessorGetter = "source.lang.swift.ref.function.accessor.getter"
    case refFunctionAccessorSetter = "source.lang.swift.ref.function.accessor.setter"
    case refClass = "source.lang.swift.ref.class"
    case refStruct = "source.lang.swift.ref.struct"
    case refEnum = "source.lang.swift.ref.enum"
    case refEnumelement = "source.lang.swift.ref.enumelement"
    case refProtocol = "source.lang.swift.ref.protocol"
    case refTypealias = "source.lang.swift.ref.typealias"
    case refVarGlobal = "source.lang.swift.ref.var.global"
    case refVarInstance = "source.lang.swift.ref.var.instance"
    case refVarStatic = "source.lang.swift.ref.var.static"
    case refVarLocal = "source.lang.swift.ref.var.local"
    
    case declExtensionStruct = "source.lang.swift.decl.extension.struct"
    case declExtensionClass = "source.lang.swift.decl.extension.class"
    case declExtensionEnum = "source.lang.swift.decl.extension.enum"
}
