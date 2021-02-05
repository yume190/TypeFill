//
//  File.swift
//  
//
//  Created by Yume on 2021/2/2.
//

import Foundation
import SourceKittenFramework
import ArgumentParser

protocol CommandBase {
    var typeFill: Bool { get }
    var ibaction: Bool { get }
    var iboutlet: Bool { get }
    var objc: Bool { get }
    var args: [String] { get }
    
//    var print: Bool { get }
//        var rewriter: Rewriter
}

//var rewriter: Rewriter {
//    let builder: RewriterFactory.Builder = RewriterFactory.Builder.new
//    if typeFill { builder.add(item: .typeFill)}
//    if ibaction { builder.add(item: .ibAction) }
//    if iboutlet { builder.add(item: .ibOutlet) }
//    if objc { builder.add(item: .objc) }
//
//    return builder.build()
//}


//extension CommandBase {
//    func rewrite(rewriter: Rewriter, docsList: [SwiftDocs]) throws {
//        defer { logger.log() }
//        try docsList.forEach { (doc: SwiftDocs) in
//            try self.rewrite(rewriter: rewriter, docs: doc)
//        }
//    }
//    
//    func rewrite(rewriter: Rewriter, docs: SwiftDocs) throws {
//        guard let docsData = docs.description.utf8 else {
//            throw SourceKittenError.utf8
//        }
//        let decoder = JSONDecoder()
//        
//        let docsInfo: [String: SwiftDocInfo]
//        do {
//            docsInfo = try decoder.decode(
//                [String: SwiftDocInfo].self,
//                from: docsData
//            )
//        } catch {
//            throw SourceKittenError.jsonDecode(error)
//        }
//        try self.rewrite(rewriter: rewriter, docsInfo: docsInfo)
//    }
//    
//    func rewrite(rewriter: Rewriter, docsInfo: [String: SwiftDocInfo]) throws {
//        try docsInfo.forEach { (path, doc) in
//            logger.add(event: .openFile(path: path))
//            let raw = try Data(contentsOf: URL(fileURLWithPath: path))
//            guard let data = rewriter.rewrite(description: doc, raw: raw).string else {
//                throw SourceKittenError.utf8
//            }
//            try data.write(toFile: path, atomically: true, encoding: .utf8)
//        }
//        //                print("[OPEN Error]: \(next.path)")
//        //                print("[OPEN Error]: \(error)")
//        //                throw SourceKittenError.failed(error)
//    }
//}
