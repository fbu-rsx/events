//
//  FirebaseAPIManager.swift
//  events
//
//  Created by Skyler Ruesga on 7/10/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation
import FirebaseDatabase

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
    func addUser(userDict: [String: Any]) {
        let uid = userDict[UserKey.id]!
        self.ref.child("users/\(uid)").updateChildValues(userDict)
    }
    
    // completion function provides dictionary of events
    func fetchUserEvents(userid: String, completion: @escaping ([String: Int], [String: Any]) -> Void) {
        self.ref.child("users/\(userid)/events").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            let result: [String: Int] = snapshot.value as? [String: Int] ?? [:]
            //print("user events results: \(result)")
            FirebaseDatabaseManager.shared.fetchEventsForEventIDs(dictionary: result, completion: { (keys: [String: Int], events: [String: Any]) in
                completion(keys, events)
            })
        }
    }
    
    // dictionary of eventid's
    func fetchEventsForEventIDs(dictionary: [String: Int], completion: @escaping ([String: Int], [String: Any]) -> Void) {
        self.ref.child("events").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            var eventsDict: [String: Any] = [:]
            if snapshot.exists() {
                for eventid in dictionary.keys {
                    let eventDict = snapshot.childSnapshot(forPath: eventid).value as! [String: Any]
                    eventsDict[eventid] = eventDict
                }
            }
            completion(dictionary, eventsDict) //sent to AppUser.current.fetchevents
        }
    }
    
    func createWallet(id: String, completion: @escaping (Double) -> Void) {
        self.ref.child("users/\(id)/wallet").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if !snapshot.exists() {
                self.updateWallet(id: id, withValue: 0.0)
                completion(0.0)
            } else {
                let value = snapshot.value as! Double
                completion(value)
            }
        }
    }
    
    func addWalletListener(id: String) {
        self.ref.child("users/\(id)/wallet").observe(.value) { (snapshot: DataSnapshot) in
            let value = snapshot.value as! Double
            AppUser.current.addToWallet(amount: value)
        }
    }
    
    func getTransactions(id: String, completion: @escaping ([String: Any]) -> Void) {
        self.ref.child("users/\(id)/transactions").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if snapshot.exists() {
                let dict = snapshot.value as! [String: Any]
                completion(dict)
            } else {
                completion([:])
            }
        }
    }
    
    func addTransaction(transaction: Transaction) {
        let update = ["users/\(AppUser.current.uid)/transactions/\(transaction.id)": transaction.getDictionary()]
        self.ref.updateChildValues(update)
    }
    
    func removeTransaction(forEventID id: String) {
        let update = ["users/\(AppUser.current.uid)/transactions/\(id)": NSNull()]
        self.ref.updateChildValues(update)
    }
    
    func updateWallet(id: String, withValue value: Double) {
        let update = ["users/\(id)/wallet": value]
        self.ref.updateChildValues(update) { (error: Error?, ref: DatabaseReference) in
            if let error = error {
                print("error updating wallet: \(error.localizedDescription)")
                return
            }
            NotificationCenter.default.post(name: BashNotifications.walletChanged, object: value)
        }
    }
    
    func updateOtherUserWallet(id: String, withValue value: Double) {
        self.ref.child("users/\(id)/wallet").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if !snapshot.exists() {
                self.updateWallet(id: id, withValue: value)
            } else {
                let oldValue = snapshot.value as! Double
                self.updateWallet(id: id, withValue: oldValue + value)
            }
        }
    }
    
    func updateTransaction(id: String) {
        let update = ["users/\(AppUser.current.uid)/transactions/\(id)/\(TransactionKey.status)": true]
        self.ref.updateChildValues(update)
    }
    
    func addEventsListener() {
        self.ref.child("users/\(AppUser.current.uid)/events").observe(.childAdded) { (snapshot: DataSnapshot) in
            if AppUser.current.eventsKeys[snapshot.key] != nil {
                return
            }
            //print(snapshot)
            FirebaseDatabaseManager.shared.getSingleEvent(withID: snapshot.key, completion: { (eventDict: [String : Any]) in
                let event = Event(dictionary: eventDict)
                if event.organizer.uid != AppUser.current.uid {
                    AppUser.current.addInvite(event: event)
                    NotificationCenter.default.post(name: BashNotifications.invite, object: event)
                }
            })
        }
    }
    
    func addQueuedSongsListener(event: Event) {
        self.ref.child("events/\(event.eventid)/queued_songs").observe(.childAdded) { (snapshot: DataSnapshot) in
            //print(snapshot)
            OAuthSwiftManager.shared.addSongToPlaylist(userID: event.playlistCreatorID!, playlistID: event.spotifyID!, song: snapshot.key)
            let update = ["events/\(event.eventid)/queued_songs/\(snapshot.key)": NSNull()]
            self.ref.updateChildValues(update)
        }
    }
    
    func addQueuedSong(event: Event, songID: String){
        let update = ["events/\(event.eventid)/queued_songs/\(songID)": true]
        self.ref.updateChildValues(update)
    }
    
    func getSingleEvent(withID id: String, completion: @escaping ([String: Any]) -> Void) {
        self.ref.child("events/\(id)").observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
            completion(snapshot.value as! [String: Any])
        })
    }
    
    
    
    
    /**
     *
     * Functions for additions to the database
     *
     */
    
    // add existing event to user
    func updateInvitation(for event: Event, withStatus status: InviteStatus) {
        let update: [String: Any] =
            ["users/\(AppUser.current.uid)/events/\(event.eventid)": status.rawValue,
             "events/\(event.eventid)/guestlist/\(AppUser.current.uid)": status.rawValue]
        self.ref.updateChildValues(update)
    }
    
    func inviteGuests(_ guests: [String: Int], to event: Event) {
        var update: [String: Any] = [:]
        for guest in guests.keys {
            update["users/\(guest)/events/\(event.eventid)"] = InviteStatus.noResponse.rawValue
        }
        self.ref.updateChildValues(update)
    }
    
    // create event from event dictionary
    func createEvent(_ dict: [String: Any], completion: @escaping () -> Void) {
        let eventid = dict[EventKey.id] as! String
        let update: [String: Any] = ["users/\(AppUser.current.uid)/events/\(eventid)": InviteStatus.accepted.rawValue,
                                     "events/\(eventid)": dict]
        self.ref.updateChildValues(update)
        self.ref.updateChildValues(update) { (error: Error?, ref: DatabaseReference) in
            if let error = error {
                print("ERROR CREATING EVENT: \(error.localizedDescription)")
            } else {
                completion()
            }
        }
    }
    
    // add images to existing event
    func addImage(eventID: String, completion: (_ id: String)->()){
        let id = self.ref.child("users/\(AppUser.current.uid)/photos").childByAutoId().key
        let update: [String: Any] = ["users/\(AppUser.current.uid)/photos/\(id)":AppUser.current.uid,
                                     "events/\(eventID)/photos/\(id)":AppUser.current.uid]
        self.ref.updateChildValues(update)
        completion(id)
    }
    
    func pullImageData(eventID: String, imageID: String,  completion: @escaping ((_ user : AppUser)->())){
        self.ref.child("events/\(eventID)/photos/\(imageID)").observeSingleEvent(of: .value, with: { (snapshot: DataSnapshot) in
            if snapshot.exists(){
                let userID = snapshot.value as! String
                self.getSingleUser(id: userID, completion: { (user) in
                    completion(user)
                })
            }
        })
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
        for eventid in AppUser.current.eventsKeys.keys {
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
        FirebaseStorageManager.shared.deleteAllEventImages(event: event)
        print("successfully removed \(event.eventname)")
    }
    
    
    
    
    
    
    /**
     *
     * Get methods to retrieve info from database
     *
     */
    // get user object from a user id
    func getSingleUser(id: String, completion: @escaping (AppUser) -> Void) {
        //print(id)
        self.ref.child("users/\(id)").observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            if snapshot.exists() {
                let dict = snapshot.value as! [String: Any]
                //print(dict)
                completion(AppUser(dictionary: dict))
            }
        }
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
//    private func setupListeners(userid: String) {
//        let eventsRef = self.ref.child("users/\(userid)/events")
//        
//        let eventsHandle = eventsRef.observe(.childAdded) { (snapshot: DataSnapshot) in
//            print("events snapshot for user: \(userid)")
//            
//            print(snapshot.key)
//            print(snapshot.value as Any)
//        }
//    }
    
//    private func setupConnectionObservers(userid: String) {
//        // since I can connect from multiple devices, we store each connection instance separately
//        // any time that connectionsRef's value is null (i.e. has no children) I am offline
//        let myConnectionsRef = self.ref.child("users/\(userid)/connections")
//        
//        // stores the timestamp of my last disconnect (the last time I was seen online)
//        let lastOnlineRef = self.ref.child("users/\(userid)/lastOnline")
//        
//        let connectedRef = self.ref.child(".info/connected")
//        
//        connectedRef.observe(.value, with: { snapshot in
//            // only handle connection established (or I've reconnected after a loss of connection)
//            guard let connected = snapshot.value as? Bool, connected else { return }
//            
//            // add this device to my connections list
//            let con = myConnectionsRef.childByAutoId()
//            
//            // when this device disconnects, remove it.
//            con.onDisconnectRemoveValue()
//            
//            // The onDisconnect() call is before the call to set() itself. This is to avoid a race condition
//            // where you set the user's presence to true and the client disconnects before the
//            // onDisconnect() operation takes effect, leaving a ghost user.
//            
//            // this value could contain info about the device or a timestamp instead of just true
//            con.setValue(true)
//            
//            // when I disconnect, update the last time I was seen online
//            lastOnlineRef.onDisconnectSetValue(ServerValue.timestamp())
//        })
//    }
}
