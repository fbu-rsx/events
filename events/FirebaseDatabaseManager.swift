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
    
    /*
     * User initialization functions
     */
    
    
    // Add user only if they do not already exist
    func addUser(appUser: AppUser, dict: [String: Any]) {
        
        self.ref.child("users/\(appUser.uid)").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            print("addUser snapshot started")
            if !snapshot.exists() {
                self.ref.child("users/\(appUser.uid)").updateChildValues(dict)
                print("new user \(appUser.name) added")
            }
            print(snapshot.value)
            self.setupConnectionObservers(userid: appUser.uid)
            self.setUserEvents(user: appUser)
        }
    }
    
    
    func setUserEvents(user: AppUser) {
        self.ref.child("users/\(user.uid)/events").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if snapshot.exists() {
                let result = snapshot.value as! [String: Bool]
                user.eventsDict = result
                user.events = self.getEvents(dictionary: result)
            }
        }
    }
    
    /*
     * Functions for additions to the database
     */
    
    
    func addEvent(event: Event) {
        let update: [String: Any] =
            ["users/\(event.organizerID)/events/\(event.eventid)": true,
             "events/\(event.eventid)": event.eventDictionary]
        self.ref.updateChildValues(update)
    }
    
    /*
     * Functions for deletions from the database
     */
    func deleteCurrentUser() {
        let id = AppUser.current.uid
        var update: [String: Any] = ["users/\(id)": NSNull()]
        for eventid in AppUser.current.eventsDict.keys {
            update["events/\(eventid)/guestlist/\(id)"] = NSNull()
        }
        self.ref.updateChildValues(update)
        print("successfully removed \(AppUser.current.name)")
    }
    
    func deleteEvent(event: Event) {
        var update: [String: Any] = ["events/\(event.eventid)": NSNull()]
        for userid in event.guestlist.keys {
            update["users/\(userid)/events/\(event.eventid)"] = NSNull()
        }
        self.ref.updateChildValues(update)
        print("successfully removed \(event.eventname)")
    }
    
    
    /*
     * Functions for changes to the database
     */
    func logout() {
        FirebaseAuthManager.shared.signOut()
        print("Goodbye!")
    }

    
    /*
     * Get methods
     */
    // dictionary of eventid's
    func getEvents(dictionary: [String: Bool]) -> [Event] {
        var events: [Event] = []
        for eventid in dictionary.keys {
            let eventDict = self.ref.child("events").value(forKey: eventid) as! [String: Any]
            events.append(Event(dictionary: eventDict))
        }
        
        return events
    }
    
    
    // dictionary of userid's
    func getUsers(dictionary: [String: Any]) -> [AppUser] {
        
        var users: [AppUser] = []
        for userid in dictionary.keys {
            let userDict = self.ref.child("users").value(forKey: userid) as! [String: Any]
            users.append(AppUser(dictionary: userDict))
        }
        
        return users
    }

    
    
    
    
    // Setup listeners at endpoints in database
    func setupListeners(userid: String) {
        let eventsRef = self.ref.child("users/\(userid)/events")
        
        let eventsHandle = eventsRef.observe(.childAdded) { (snapshot: DataSnapshot) in
            print("events snapshot for user: \(userid)")
            
            print(snapshot.key)
            print(snapshot.value)
        }
    }
    
    
    
    
    /*
     * Private Functions
     */
    private func offlineQuery() {
        
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
