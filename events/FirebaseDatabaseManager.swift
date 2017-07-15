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
    
    static var shared:FirebaseDatabaseManager = FirebaseDatabaseManager() //shared instance of manager
    
    var ref = Database.database().reference() // root reference to database
    var eventRef: DatabaseReference
    var usersRef: DatabaseReference
        
    private init() {
        eventRef = ref.child("events")
        usersRef = ref.child("users")
    }
    
    /*
     * Functions for additions to the database
     */
    func addUser(appUser: AppUser) {
        let newUserID = self.usersRef.childByAutoId().key
        let properties: [String: Any?] = ["uid":appUser.uid,
                          "name": appUser.name,
                          "email": appUser.email,
                          "photoURL": appUser.photoURL,
                          "events": getUserEvents(userid: appUser.uid)]
        self.usersRef.child(newUserID).updateChildValues(properties)
        
//        setupConnectionObservers()
    }
    
    func addEvent(event: Event) {
        let eventRef = self.ref.child("events")
    }
    
    
    /*
     * Functions for deletions from the database
     */
    func deleteUser(appUser: AppUser) {
        self.ref.child(appUser.uid).removeValue { (error: Error?, ref: DatabaseReference) in
            if let error = error {
                print(error.localizedDescription)
            }
            print("successfully removed \(appUser.name)")
        }
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
        
        
        self.usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
            print("SNAPSHOT STARTED")
            let value = snapshot.value as? [String: Any]
            print(value)
        })
        
        
        self.ref.child("users/\(userid)/username").updateChildValues(["uid" : userid])
        
        return [:]
    }
    
    func getEventOrganizer(orgID: String) -> [String: Any] {
        return [:]
    }
    
    
    
    /*
     * Boolean methods
     */
    
    func userExists(userid: String) -> Bool {
        self.usersRef.child(userid).observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot.value)
        })
        return self.usersRef.value(forKey: userid) != nil
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
