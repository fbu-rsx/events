//
//  User.swift
//  events
//
//  Created by Skyler Ruesga on 7/12/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation
import FirebaseAuth
import FBSDKCoreKit

enum UserKey: String {
    case id = "uid"
    case name = "name"
    case date = "datetime"
    case photo = "photoURLString"
    case events = "events"
}

/*
 - "uid":
    - "uid": "gMrf7HieuJHoH7fsdg"
    - "name": "Skyler Ruesga"
    - "photoURLString": "https://etc.com/kjhdf76vf8"
    - "location": [latitude, longitude]
    - "events":
        - "eventid1": true
        - "eventid2": false
        - "eventid3": false
    - "transactions":
 */


class AppUser {
 
    static var current: AppUser!
 
    var uid: String //same as their facebook id
    var name: String
    var photoURLString: String
    var events: [Event] = []
    var eventsKeys: [String: Int]!  {
        didSet {
            FirebaseDatabaseManager.shared.addEventsListener()
        }
    } // Int represents InviteStatus
    
    var facebookFriends: [FacebookFriend]!
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary[UserKey.id.rawValue] as! String
        self.name = dictionary[UserKey.name.rawValue] as! String
        self.photoURLString = dictionary[UserKey.photo.rawValue] as! String
    }
    
    convenience init(user: User) {
        let userDict: [String: String] = [UserKey.id.rawValue: FBSDKAccessToken.current().userID,
                                       UserKey.name.rawValue: user.displayName!,
                                       UserKey.photo.rawValue: user.photoURL?.absoluteString ?? "gs://events-86286.appspot.com/default"]
        self.init(dictionary: userDict)

        // Adds user only if the user does not exists
        FirebaseDatabaseManager.shared.possiblyAddUser(userDict: userDict)
        FacebookAPIManager.shared.getUserFriendsList { (friends: [FacebookFriend]) in
            self.facebookFriends = friends
        }
        NotificationCenter.default.addObserver(self, selector: #selector(AppUser.inviteAdded(_:)), name: NSNotification.Name(rawValue: "inviteAdded"), object: nil)

    }
    
    /**
     *
     * Events related functions
     *
     */
    //adds existing event to user event list
    @objc func inviteAdded(_ notification: NSNotification) {
        let event = notification.object as! Event
        self.eventsKeys[event.eventid] = InviteStatus.noResponse.rawValue
        self.events.append(event)
    }
    
    func updateInvitation(for event: Event, withStatus status: InviteStatus) {
        FirebaseDatabaseManager.shared.updateInvitation(for: event, withStatus: status)
    }
    
    //create event and add to user event list and event database
    func createEvent(_ eventDict: [String: Any]) -> Event {
        let event = Event(dictionary: eventDict)
        self.eventsKeys[event.eventid] = InviteStatus.accepted.rawValue
        self.events.append(event)
        FirebaseDatabaseManager.shared.createEvent(eventDict) {
            FirebaseDatabaseManager.shared.inviteGuests(event.guestlist, to: event)
        }
        return event
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
        FirebaseDatabaseManager.shared.fetchUserEvents(userid: self.uid) { (keys: [String: Int], events: [String: Any]) in
            self.eventsKeys = keys
            for id in events.keys {
                let dict = events[id] as! [String: Any]
                self.events.append(Event(dictionary: dict))
            }
            print("AppUser Events: \(self.events)")
            completion()
        }
    }
}

