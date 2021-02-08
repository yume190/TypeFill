//
//  File.swift
//  
//
//  Created by Yume on 2021/2/4.
//

import ArgumentParser
//import SourceKittenFramework

/// https://github.com/jpsim/SourceKitten/blob/master/Source/sourcekitten/Doc.swift

//@Option(help: "Name of Swift module to document (can't be used with `--single-file`)")
//var moduleName: String = ""

//sourcekitten doc -- -workspace SourceKitten.xcworkspace -scheme SourceKittenFramework
//sourcekitten doc --single-file file.swift -- -j4 file.swift
//sourcekitten doc --module-name Alamofire -- -project Alamofire.xcodeproj
//sourcekitten doc -- -workspace Haneke.xcworkspace -scheme Haneke
//sourcekitten doc --objc Realm/Realm.h -- -x objective-c -isysroot $(xcrun --show-sdk-path) -I $(pwd)

public struct TypeFill: ParsableCommand {
    public init() {}
    public static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "typefill",
        abstract: "A utility for fill swift types.",
        subcommands: [SingleFile.self, SPMModule.self, WorkSpaceCommand.self],
        defaultSubcommand: SPMModule.self
    )
}
