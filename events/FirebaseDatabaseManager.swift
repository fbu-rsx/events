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
    
    static var shared = FirebaseAPIManager() //shared instance of manager
    
    private init() {
        Database.database().isPersistenceEnabled = true
        
        setupConnectionObservers()
    }
    
    
    func setChildValue(_ value: Any?, forPath path: RefPath) {
        self.ref.child(path).setValue(value)
    }
    
    func createListener(forChild: RefPath) {
        
    }
    
    private func offlineQuery() {
        
    }
    
    private func setupConnectionObservers() {
        // since I can connect from multiple devices, we store each connection instance separately
        // any time that connectionsRef's value is null (i.e. has no children) I am offline
        let myConnectionsRef = Database.database().reference(withPath: "users/morgan/connections")
        
        // stores the timestamp of my last disconnect (the last time I was seen online)
        let lastOnlineRef = Database.database().reference(withPath: "users/morgan/lastOnline")
        
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
