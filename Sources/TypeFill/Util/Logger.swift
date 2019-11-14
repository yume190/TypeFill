//
//  Logger.swift
//  CYaml
//
//  Created by 林煒峻 on 2019/10/1.
//

import Foundation
import Rainbow

let logger: Logger = Logger()
final class Logger {
    private final var events: [Event] = []
    fileprivate init() {}
    func add(event: Event) {
        self.events.append(event)
    }
    
    func log() {
        _ = self.events.map { print($0) }
        self.logImplictTypeCount()
        self.logIBActionCount()
        self.logIBOutletCount()
    }
    
    private func logImplictTypeCount() {
        let implictTypeCount: Int = self.events.filter { (event: Event) -> Bool in
            if case .implictType = event {
                return true
            }
            return false
            }.count
        
        print("""
        \("[FIX IMPLICT TYPE]: \(implictTypeCount)".applyingColor(.green))
        """)
    }
    
    private func logIBActionCount() {
        let count: Int = self.events.filter { (event: Event) -> Bool in
            if case .ibAction = event {
                return true
            }
            return false
            }.count
        
        print("""
            \("[FIX IBAction]: \(count)".applyingColor(.green))
            """)
    }
    
    private func logIBOutletCount() {
        let count: Int = self.events.filter { (event: Event) -> Bool in
            if case .ibOutlet = event {
                return true
            }
            return false
            }.count
        
        print("""
            \("[FIX IBOutlet]: \(count)".applyingColor(.green))
            """)
    }
}
