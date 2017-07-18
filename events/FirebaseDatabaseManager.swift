//
//  FirebaseAPIManager.swift
//  events
//
//  Created by Skyler Ruesga on 7/10/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuthUI

class FirebaseDatabaseManager {
    
    static var shared:FirebaseDatabaseManager = FirebaseDatabaseManager() //shared instance of manager
    
    var ref: DatabaseReference // root reference to database
    
    private init() {
        let db = Database.database()
        db.isPersistenceEnabled = false
        self.ref = db.reference()
    }
    
    
    
    
    
    /**
     *
     * User initialization functions
     *
     */
    
    // Add user only if they do not already exist
    func addUser(appUser: AppUser, userDict: [String: Any]) {
        
        self.ref.child("users/\(appUser.uid)").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            print("addUser snapshot started")
            if !snapshot.exists() {
                self.ref.child("users/\(appUser.uid)").updateChildValues(userDict, withCompletionBlock: { (error: Error?, userRef: DatabaseReference) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.setUserEvents(user: appUser)
                    }
                })
                print("new user \(appUser.name) added")
            } else {
                print(snapshot)
                // self.setupConnectionObservers(userid: appUser.uid)
                self.setUserEvents(user: appUser)
            }
        }
    }
    
    // asynchronous function that will set events to AppUser.current
    private func setUserEvents(user: AppUser) {
        self.ref.child("users/\(user.uid)/events").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if snapshot.exists() {
                let result = snapshot.value as! [String: Bool]
                user.eventsDict = result
                user.events = self.getEventsArray(dictionary: result)
            }
        }
    }
    
    
    
    
    
    /**
     *
     * Functions for additions to the database
     *
     */
    
    // add existing event to user
    func addEventToUser(_ event: Event) {
        let update: [String: Any] =
            ["users/\(AppUser.current.uid)/events/\(event.eventid)": true,
             "events/\(event.eventid)/guestlist/\(AppUser.current.uid)": true]
        self.ref.updateChildValues(update)
    }
    
    // create event from dictionary containing everything except eventid
    func createEvent(_ dict: [String: Any]) {
        let eventid = dict["eventid"] as! String
        let update: [String: Any] = ["users/\(AppUser.current.uid)/events/\(eventid)": true,
                                     "events/\(eventid)": dict]
        self.ref.updateChildValues(update)
    }
    
    
    
    
    
    
    /**
     *
     * Listener function:
     * .childAdded: returns snapshot of child node added
     * .value: returns entire list of data as a single snapshot, fetches all children
     *
     *
     */
    func addListener(ofType type: DataEventType, at path: String, completion: @escaping (DataSnapshot) -> Void) {
        self.ref.child(path).observe(type) { (snapshot) in
            completion(snapshot)
        }
    }
    
    
    

    
    
    /**
     *
     * Functions for deletions from the database
     *
     */
    
    // deletes the current user
    // deletes all user events, photos, and deletes the user from all events
    func deleteCurrentUser() {
        let id = AppUser.current.uid
        var update: [String: Any] = ["users/\(id)": NSNull()]
        for eventid in AppUser.current.eventsDict.keys {
            update["events/\(eventid)/guestlist/\(id)"] = NSNull()
        }
        self.ref.updateChildValues(update)
        print("successfully removed \(AppUser.current.name)")
    }
    
    // remove user from an event
    func removeUserFromEvent(_ event: Event) {
        let id = AppUser.current.uid
        let update: [String: Any] = ["users/\(id)/events/\(event.eventid)": NSNull(),
                                     "events/\(event.eventid)/guestlist/\(id)": NSNull()]
        self.ref.updateChildValues(update)
    }
    
    // delete an event from the database
    func deleteEvent(_ event: Event) {
        var update: [String: Any] = ["events/\(event.eventid)": NSNull()]
        for userid in event.guestlist.keys {
            update["users/\(userid)/events/\(event.eventid)"] = NSNull()
        }
        self.ref.updateChildValues(update)
        print("successfully removed \(event.eventname)")
    }
    
    
    
    
    
    
    /**
     *
     * Get methods to retrieve info from database
     *
     */
    
    // dictionary of eventid's
    func getEventsArray(dictionary: [String: Bool]) -> [Event] {
        var events: [Event] = []
        for eventid in dictionary.keys {
            let eventDict = self.ref.child("events").value(forKey: eventid) as! [String: Any]
            events.append(Event(dictionary: eventDict))
        }
        
        return events
    }
    
    
    
    // gets users from an event dictionary, and creates AppUser objects
    func getUsersFromEventDict(dictionary: [String: Any]) -> [AppUser] {
        var users: [AppUser] = []
        for userid in dictionary.keys {
            let userDict = self.ref.child("users").value(forKey: userid) as! [String: Any]
            users.append(AppUser(dictionary: userDict))
        }
        
        return users
    }
    
    // get user object from a user id
    func getSingleUser(id: String) -> AppUser {
        let dict = self.ref.value(forKeyPath: "users/\(id)") as! [String: Any]
        return AppUser(dictionary: dict)
    }
    
    // get unique id for a new event
    func getNewEventID() -> String {
        return self.ref.child("events").childByAutoId().key
    }

    
    
    
    /**
     *
     * Logout the user
     *
     */
    
    // logout the user and redirect them to the sign in view
    func logout() {
        FirebaseAuthManager.shared.signOut()
        print("Goodbye!")
    }
    
    
    
    
    
    /**
     *
     * Private Functions
     *
     */
    
    // Setup listeners at endpoints in database
    private func setupListeners(userid: String) {
        let eventsRef = self.ref.child("users/\(userid)/events")
        
        let eventsHandle = eventsRef.observe(.childAdded) { (snapshot: DataSnapshot) in
            print("events snapshot for user: \(userid)")
            
            print(snapshot.key)
            print(snapshot.value)
        }
    }
    
    private func setupConnectionObservers(userid: String) {
        // since I can connect from multiple devices, we store each connection instance separately
        // any time that connectionsRef's value is null (i.e. has no children) I am offline
        let myConnectionsRef = self.ref.child("users/\(userid)/connections")
        
        // stores the timestamp of my last disconnect (the last time I was seen online)
        let lastOnlineRef = self.ref.child("users/\(userid)/lastOnline")
        
        let connectedRef = self.ref.child(".info/connected")
        
        connectedRef.observe(.value, with: { snapshot in
            // only handle connection established (or I've reconnected after a loss of connection)
            guard let connected = snapshot.value as? Bool, connected else { return }
            
            // add this device to my connections list
            let con = myConnectionsRef.childByAutoId()
            
            // when this device disconnects, remove it.
            con.onDisconnectRemoveValue()
            
            // The onDisconnect() call is before the call to set() itself. This is to avoid a race condition
            // where you set the user's presence to true and the client disconnects before the
            // onDisconnect() operation takes effect, leaving a ghost user.
            
            // this value could contain info about the device or a timestamp instead of just true
            con.setValue(true)
            
            // when I disconnect, update the last time I was seen online
            lastOnlineRef.onDisconnectSetValue(ServerValue.timestamp())
        })
    }
}
