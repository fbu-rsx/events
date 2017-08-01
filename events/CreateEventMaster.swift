//
//  CreateEventMaster.swift
//  events
//
//  Created by Skyler Ruesga on 7/19/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation

class CreateEventMaster {
    
    static var shared = CreateEventMaster()
    
    var event: [String: Any]
    var guestlist: [String: Int]
    
    init() {
        self.event = [EventKey.id: FirebaseDatabaseManager.shared.getNewEventID(),
                      EventKey.organizerID: AppUser.current.uid,
                      EventKey.radius: 50.0,
                      EventKey.orgURLString: AppUser.current.photoURLString]
        self.guestlist = [:]
    }
    
    func clear() {
        self.event = [EventKey.id: FirebaseDatabaseManager.shared.getNewEventID(),
                      EventKey.organizerID: AppUser.current.uid,
                      EventKey.radius: 50.0,
                      EventKey.orgURLString: AppUser.current.photoURLString]
        self.guestlist = [:]
    }
    
    func createNewEvent() -> Event {
        print("CREATING NEW EVENT")
        let event = AppUser.current.createEvent(self.event)
        CreateEventMaster.shared.clear()
        return event
    }
}
