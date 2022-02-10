//
//  DirectoryScanner.swift
//  SwiftLeakCheck
//
//  Copyright 2020 Grabtaxi Holdings PTE LTE (GRAB), All rights reserved.
//  Use of this source code is governed by an MIT-style license that can be found in the LICENSE file
//
//  Created by Hoang Le Pham on 09/12/2019.
//

import Foundation

public final class DirectoryScanner {
  private let callback: (URL, inout Bool) -> Void
  private var shouldStop: Bool = false
  
  public init(callback: @escaping (URL, inout Bool) -> Void) {
    self.callback = callback
  }
  
  public func scan(url: URL) {
    if shouldStop {
      shouldStop = false // Clear
      return
    }
    
    let isDirectory: Bool = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
    if !isDirectory {
      callback(url, &shouldStop)
    } else {
      let enumerator: FileManager.DirectoryEnumerator = FileManager.default.enumerator(
        at: url,
        includingPropertiesForKeys: nil,
        options: [.skipsSubdirectoryDescendants],
        errorHandler: nil
        )!
      
      for childPath in enumerator {
        if let url: URL = childPath as? URL {
          scan(url: url)
          if shouldStop {
            return
          }
        }
      }
    }
  }
}
