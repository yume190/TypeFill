//
//  Logger.swift
//  CYaml
//
//  Created by 林煒峻 on 2019/10/1.
//

import Foundation
import Rainbow

public final class Logger {
    
    private final var events: [Event] = []
    private final var isPrintEvent: Bool = false
    fileprivate init() {}
    
    static let shared: Logger = Logger()
    public static func set(logEvent enable: Bool) {
        shared.set(logEvent: enable)
    }
    
    public static func summery() {
        shared.summery()
    }
    
    public static func add(event: Event) {
        shared.add(event: event)
    }
    
    final func set(logEvent enable: Bool) {
        self.isPrintEvent = enable
    }
    
    public final func add(event: Event) {
        self.events.append(event)
        
        guard isPrintEvent else { return }
        print(event)
    }
    
    final func summery() {
        self.logImplictTypeCount()
        self.logIBActionCount()
        self.logIBOutletCount()
    }
    
    private func logImplictTypeCount() {
        let count: Int = self.events.filter { (event: Event) -> Bool in
            if case .implictType = event {
                return true
            }
            return false
            }.count
        
        guard count > 0 else { return }
        print("""
        \("[FIX IMPLICT TYPE]: \(count)".applyingColor(.green))
        """)
    }
    
    private func logIBActionCount() {
        let count: Int = self.events.filter { (event: Event) -> Bool in
            if case .ibAction = event {
                return true
            }
            return false
            }.count
        
        guard count > 0 else { return }
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
        
        guard count > 0 else { return }
        print("""
        \("[FIX IBOutlet]: \(count)".applyingColor(.green))
        """)
    }
}
