//
//  User.swift
//  events
//
//  Created by Skyler Ruesga on 7/12/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation
import FirebaseAuth

class AppUser {
    
    static var current: AppUser!
    
    var uid: String
    var name: String
    var email: String
    var password: String?
    var photoURL: URL?
    var events: [Event]
    var lastLocation: [Double] {
        get {
            return getLocation()
        }
    }
    
    init(dictionary: [String: Any?]) {
        self.uid = dictionary["uid"] as! String
        self.name = dictionary["name"] as! String
        self.email = dictionary["email"] as! String
        self.photoURL = dictionary["photoURL"] as? URL
        let eventsDict = FirebaseDatabaseManager.shared.getUserEvents(userid: self.uid)
        self.events = FirebaseDatabaseManager.shared.getEvents(dictionary: eventsDict)
        if !FirebaseDatabaseManager.shared.userExists(userid: self.uid) {
            FirebaseDatabaseManager.shared.addUser(appUser: self)
        }
    }
    
    /* 
     * Events related functions
     */
    func addEvent(_ event: Event) {
        FirebaseDatabaseManager.shared.addEvent(event: event)
    }
    
    func getEventsDict() -> [String: Bool] {
        return FirebaseDatabaseManager.shared.getUserEvents(userid: self.uid)
    }
    
    
    /*
     * Private functions
     */
    
    
    private func getLocation() {
        return [0, 0]
    }
}
