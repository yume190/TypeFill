//
//  ArrayBuilder.swift
//  TypeFillKit
//
//  Created by Yume on 2021/2/8.
//

import Foundation

@frozen
public indirect enum ArrayBox<T> {
    case single(T)
    case multi([T])
    case nothing
    case nest([ArrayBox<T>])
    
    var flat: [T] {
        switch self {
        case .nothing:
            return []
        case .single(let t):
            return [t]
        case .multi(let ts):
            return ts
        case .nest(let ns):
            return ns.flatMap {
                $0.flat
            }
        }
    }
}

@_functionBuilder
public enum ArrayBuilder<T> {
    public static func buildExpression(_ item: T) -> ArrayBox<T> {
        return .single(item)
    }
    
    public static func buildExpression(_ item: T?) -> ArrayBox<T> {
        guard let item = item else { return .nothing }
        return .single(item)
    }
    
    public static func buildFinalResult(_ box: ArrayBox<T>) -> [T] {
        return box.flat
    }
    
    public static func buildBlock() -> ArrayBox<T> {
        return .nothing
    }
    
    public static func buildBlock(_ items: ArrayBox<T>...) -> ArrayBox<T> {
        return .nest(items)
    }
    
    public static func buildIf(_ value: ArrayBox<T>?) -> ArrayBox<T> {
        guard let v = value else { return .nothing }
        return v
    }
    
    public static func buildEither(first value: ArrayBox<T>) -> ArrayBox<T> {
        return value
    }

    public static func buildEither(second value: ArrayBox<T>) -> ArrayBox<T> {
        return value
    }
}

