//
//  CodeCursor.swift
//  TypeFillTests
//
//  Created by Yume on 2021/10/21.
//

/// not support `key.sourcetext`

///// {
/////     <key.request>:            (UID)     <source.request.cursorinfo>,
/////     [opt] <key.sourcetext>:   (string)  // Source contents.
/////     [opt] <key.sourcefile>:   (string)  // Absolute path to the file.
/////                                         // **Require**: key.sourcetext or key.sourcefile
/////     [opt] <key.offset>:       (int64)   // Byte offset of code point inside the source contents.
/////     [opt] <key.usr>:          (string)  // USR string for the entity.
/////                                         // **Require**: key.offset or key.usr
/////     [opt] <key.compilerargs>: [string*] // Array of zero or more strings for the compiler arguments,
/////                                         // e.g ["-sdk", "/path/to/sdk"]. If key.sourcefile is provided,
/////                                         // these must include the path to that file.
/////     [opt] <key.cancel_on_subsequent_request>: (int64) // Whether this request should be canceled if a
/////                                         // new cursor-info request is made that uses the same AST.
/////                                         // This behavior is a workaround for not having first-class
/////                                         // cancelation. For backwards compatibility, the default is 1.
///// }
/////
///// case let .cursorInfo(file, offset, arguments):
/////     return [
/////         "key.request": UID("source.request.cursorinfo"),
/////         "key.name": file,
/////         "key.sourcefile": file,
/////         "key.offset": Int64(offset.value),
/////         "key.compilerargs": arguments
/////     ]
//public struct CodeCursor {
//    public let code: String
//    public let arguments: [String]
//    init(code: String, sdk: SDK) {
//        self.code = code
//        self.arguments = []//sdk.pathArgs
//    }
//
//    public func callAsFunction(_ offset: Int) throws -> SourceKitResponse {
//        let request: SourceKitObject = [
//            "key.request": UID("source.request.cursorinfo"),
////            "key.name": "Yume",
////            "key.modulename": "Yume",
//            "key.sourcetext": String(code.utf8),
//            "key.offset": Int64(offset),
//            "key.compilerargs": arguments
//        ]
//        let raw: [String : SourceKitRepresentable] = try Request.customRequest(request: request).send()
//        return SourceKitResponse(raw)
//    }
//}
