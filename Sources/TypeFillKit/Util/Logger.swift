//
//  Logger.swift
//  CYaml
//
//  Created by 林煒峻 on 2019/10/1.
//

import Foundation
import Rainbow

public enum Logger {
    
    private static var eventImplictCount: Int = 0
    private static var isPrintEvent: Bool = false
    
    public static func set(logEvent enable: Bool) {    
        self.isPrintEvent = enable
    }
    
    public static func summery() {
        print("""
        \("[FIX IMPLICT TYPE]: \(eventImplictCount)".applyingColor(.green))
        """)
    }
    
    public static func add(event: Event) {
        self.classify(event: event)
        
        guard isPrintEvent else { return }
        print(event)
    }
    
    private static func classify(event: Event) {
        switch event {
        case .implictType:
            self.eventImplictCount += 1
        default:
            return
        }
    }
    
    // TODO:
    // \("[FIX IBAction]: \(count)".applyingColor(.green))
    // \("[FIX IBOutlet]: \(count)".applyingColor(.green))
}
