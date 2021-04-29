//
//  TypeFill.swift
//
//
//  Created by Yume on 2021/2/4.
//

import ArgumentParser

/// https://github.com/jpsim/SourceKitten/blob/master/Source/sourcekitten/Doc.swift
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
        version: "0.1.7",
        subcommands: [SingleFile.self, SPMModule.self, WorkSpace.self, Project.self],
        defaultSubcommand: SPMModule.self
    )
}
