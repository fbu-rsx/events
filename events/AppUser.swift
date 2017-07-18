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
    var photoURLString: String
    var events: [Event] = []
    var eventsDict: [String: Bool] = [:]
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as! String
        self.name = dictionary["name"] as! String
        self.email = dictionary["email"] as! String
        self.photoURLString = dictionary["photoURLString"] as! String
    }
    
    convenience init(user: User) {
        let userDict: [String: Any] = ["uid": user.uid,
                                       "name": user.displayName!,
                                       "email": user.email!,
                                       "photoURLString": user.photoURL?.absoluteString ?? "gs://events-86286.appspot.com/default"]
        self.init(dictionary: userDict)
      
        // Adds user only if the user does not exists
        FirebaseDatabaseManager.shared.addUser(appUser: self, userDict: userDict)
    }
    
    /**
     *
     * Events related functions
     *
     */
    //adds existing event to user event list
    func addEventToUser(_ event: Event) {
        FirebaseDatabaseManager.shared.addEventToUser(event)
        self.events.append(event)
        self.eventsDict[event.eventid] = true
    }
    
    //create event and add to user event list and event database
    func createEvent(_ eventDict: [String: Any]) {
        var copy = eventDict
        copy["eventid"] = FirebaseDatabaseManager.shared.getNewEventID()
        FirebaseDatabaseManager.shared.createEvent(copy)
        let event = Event(dictionary: copy)
        self.events.append(event)
        self.eventsDict[event.eventid] = true
    }
    
    //remove event from user event list
    func removeUserFromEvent(_ event: Event) {
        FirebaseDatabaseManager.shared.removeUserFromEvent(event)
        var index: Int!
        for i in 0..<self.events.count {
            if event.eventid == self.events[i].eventid {
                index = i
                break
            }
        }
        self.events.remove(at: index)
        self.eventsDict.removeValue(forKey: event.eventid)
    }
    
    // delete event and delete from all its users' event lists
    func deleteEvent(_ event: Event) {
        FirebaseDatabaseManager.shared.deleteEvent(event)
        self.removeUserFromEvent(event)
    }
}
