//
//  Util.swift
//  TypeFillTests
//
//  Created by Yume on 2021/10/21.
//

import Foundation

private let sourceFile: URL = URL(fileURLWithPath: #file)
    .deletingLastPathComponent()
    .appendingPathComponent("Resource")

func resource(file: String) -> String {
    return sourceFile.appendingPathComponent(file).path
}
