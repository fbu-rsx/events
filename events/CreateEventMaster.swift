//
//  CreateEventMaster.swift
//  events
//
//  Created by Skyler Ruesga on 7/19/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation

protocol CreateEventMasterDelegate {
    func didCreateNewEvent(_ event: Event)
}

class CreateEventMaster {
    
    static var shared = CreateEventMaster()
    
    var event: [String: Any]
    var delegate: CreateEventMasterDelegate?
    
    init() {
        self.event = [:]
    }
}
