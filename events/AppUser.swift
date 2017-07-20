//
//  User.swift
//  events
//
//  Created by Skyler Ruesga on 7/12/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation
import FirebaseAuth

enum UserKey: String {
    case id = "uid"
    case name = "name"
    case email = "email"
    case date = "datetime"
    case phone = "phoneNumber"
    case photo = "photoURLString"
    case events = "events"
}

/*
 - "uid":
    - "uid": "gMrf7HieuJHoH7fsdg"
    - "name": "Skyler Ruesga"
    - "email": "sruesga@fb.com"
    - "phoneNumber": String
    - "photoURLString": "https://etc.com/kjhdf76vf8"
    - "lastOnline": "serverValue.timestamp()"
    - "connections": []
    - "location": [latitude, longitude]
    - "events":
        - "eventid1": true
        - "eventid2": true
        - "eventid3": true
    - "transactions":
 */


class AppUser {
 
    static var current: AppUser!
 
    var uid: String
    var name: String
    var email: String
    var password: String?
    var phoneNumber: String?
    var photoURLString: String
    var events: [Event] = []
    var eventsKeys: [String: Bool] = [:]
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary[UserKey.id.rawValue] as! String
        self.name = dictionary[UserKey.name.rawValue] as! String
        self.email = dictionary[UserKey.email.rawValue] as! String
        self.photoURLString = dictionary[UserKey.photo.rawValue] as! String
    }
    
    convenience init(user: User) {
        let userDict: [String: Any] = [UserKey.id.rawValue: user.uid,
                                       UserKey.name.rawValue: user.displayName!,
                                       UserKey.email.rawValue: user.email!,
                                       UserKey.phone.rawValue: user.phoneNumber ?? NSNull(),
                                       UserKey.photo.rawValue: user.photoURL?.absoluteString ?? "gs://events-86286.appspot.com/default"]
        self.init(dictionary: userDict)
      
        // Adds user only if the user does not exists
        FirebaseDatabaseManager.shared.possiblyAddUser(userDict: userDict)
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
        self.eventsKeys[event.eventid] = true
    }
    
    //create event and add to user event list and event database
    func createEvent(_ eventDict: [String: Any]) {
        FirebaseDatabaseManager.shared.createEvent(eventDict)
        let event = Event(dictionary: eventDict)
        self.events.append(event)
        self.eventsKeys[event.eventid] = true
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
        self.eventsKeys.removeValue(forKey: event.eventid)
    }
    
    // delete event and delete from all its users' event lists
    func deleteEvent(_ event: Event) {
        FirebaseDatabaseManager.shared.deleteEvent(event)
        self.removeUserFromEvent(event)
    }
}

extension AppUser: LoadEventsDelegate {
    func fetchEvents(completion: @escaping () -> Void) {
        FirebaseDatabaseManager.shared.fetchUserEvents(userid: self.uid) { (keys: [String: Bool], events: [String: Any]) in
            self.eventsKeys = keys
            for id in events.keys {
                let dict = events[id] as! [String: Any]
                self.events.append(Event(dictionary: dict))
            }
            print(self.events)
            completion()
        }
    }
}

