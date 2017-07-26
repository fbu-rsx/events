//
//  CreateEventMaster.swift
//  events
//
//  Created by Skyler Ruesga on 7/19/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation

protocol CreateEventMasterDelegate: class {
    func createNewEvent(_ dict: [String: Any])
}

class CreateEventMaster {
    
    static var shared = CreateEventMaster()
    
    var event: [String: Any]
    var guestlist: [String: Bool]
    weak var delegate: CreateEventMasterDelegate!
    
    init() {
        self.event = [EventKey.id.rawValue: FirebaseDatabaseManager.shared.getNewEventID(),
                      EventKey.organizerID.rawValue: AppUser.current.uid]
        self.guestlist = [:]
    }
    
    func clear() {
        self.event = [:]
        self.guestlist = [:]
    }
}
