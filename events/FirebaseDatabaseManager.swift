//
//  FirebaseAPIManager.swift
//  events
//
//  Created by Skyler Ruesga on 7/10/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation
import Firebase

class FirebaseDatabaseManager {
    
    static var shared = FirebaseDatabaseManager() //shared instance of manager
    
    var ref = Database.database().reference() // root reference to database
    var eventRef = self.ref.child("events")
    var usersRef = self.ref.child("users")
    
    private init() {
        Database.database().isPersistenceEnabled = true
        
        setupConnectionObservers()
    }
    
    /*
     * Functions for additions to the database
     */
    func addUser(appUser: AppUser) {
        let newUserID = self.usersRef.childByAutoId().key
        let properties = ["uid":appUser.uid,
                          "name": 3,
                          "email": 3,
                          "profileURL": 3,
                          "events": AppUser.getEventsDict()]
        newUserRef.setValue(properties)
    }
    
    func addEvent(event: Event) {
        let eventRef = self.ref.child("events")
    }
    
    
    /*
     * Functions for deletions from the database
     */
    func deleteUser(appUser: AppUser) {
        
    }
    
    func deleteEvent(event: Event) {
        
    }
    
    
    /*
     * Functions for changes to the database
     */
    func editUserEvents(userid: String) {
        
    }

    
    /*
     * Get methods
     */
    // dictionary of eventid's
    func getEvents(dictionary: [String: Any]) -> [Event] {
        var events: [Event] = []
        for eventid in dictionary.keys {
            let eventDict = self.eventRef.value(forKey: eventid) as! [String: Any]
            events.append(Event(dictionary: eventDict))
        }
        
        return events
    }
    
    // dictionary of userid's
    func getUsers(dictionary: [String: Any]) -> [AppUser] {
        
        var users: [AppUser] = []
        for userid in dictionary.keys {
            let userDict = self.usersRef.value(forKey: userid) as! [String: Any]
            users.append(AppUser(dictionary: userDict))
        }
        
        return users
    }
    
    func getUserEvents(userid: String) -> [String: Bool] {
        return self.ref.child("users/\(userid)").value(forKey: "events") as? [String: Bool] ?? [:]
    }
    
    func userExists(userid: String) -> Bool {
        return self.usersRef
    }
    
    func getEventOrganizer(orgID: String) {
        
    }
    
    
    
    /*
     * Private Functions
     */
    private func offlineQuery() {
        
    }
    
    private func setupConnectionObservers() {
        // since I can connect from multiple devices, we store each connection instance separately
        // any time that connectionsRef's value is null (i.e. has no children) I am offline
        let myConnectionsRef = Database.database().reference(withPath: "users/\(AppUser.current.uid)/connections")
        
        // stores the timestamp of my last disconnect (the last time I was seen online)
        let lastOnlineRef = Database.database().reference(withPath: "users/\(AppUser.current.uid)/lastOnline")
        
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        
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
