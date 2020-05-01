//
//  Mouse.swift
//  hackcolor
//
//  Created by Sam on 4/29/20.
//  Copyright © 2020 Sam. All rights reserved.
//

import Foundation

class Mouse {
    static func click(position:CGPoint){
        let source = CGEventSource.init(stateID: .hidSystemState)
        let eventDown = CGEvent(mouseEventSource: source, mouseType: .leftMouseDown, mouseCursorPosition: position , mouseButton: .left)
        let eventUp = CGEvent(mouseEventSource: source, mouseType: .leftMouseUp, mouseCursorPosition: position , mouseButton: .left)
        
        eventDown?.post(tap: .cghidEventTap)
        
        //eventDown?.postToPid(71028)
        usleep(5)
        //eventUp?.postToPid(71028)
        eventUp?.post(tap: .cghidEventTap)
    }
}
