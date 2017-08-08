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

struct BashNotifications {
    static let invite = NSNotification.Name(rawValue: "inviteAdded")
    static let delete = NSNotification.Name(rawValue: "deleteEvent")
    static let accept = NSNotification.Name(rawValue: "acceptedInvitation")
    static let decline = NSNotification.Name(rawValue: "declineInvitation")
    static let logout = NSNotification.Name(rawValue: "logout")
    static let refresh = NSNotification.Name(rawValue: "refresh")
    static let enableSwipe = NSNotification.Name(rawValue: "enableSwipe")
    static let disableSwipe = NSNotification.Name(rawValue: "disableSwipe")
    static let swipeRight = NSNotification.Name(rawValue: "swipeRight")
    static let swipeLeft = NSNotification.Name(rawValue: "swipeLeft")
    static let eventsLoaded = NSNotification.Name(rawValue: "eventsLoaded")
    static let walletChanged = NSNotification.Name(rawValue: "walletChanged")
    static let changedTheme = NSNotification.Name(rawValue: "changedTheme")
}

struct UserKey {
    static let id = "uid"
    static let name = "name"
    static let photo = "photoURLString"
    static let events = "events"
    static let wallet = "wallet"
    static let splitwiseID = "splitwiseID"
    static let splitwiseName = "splitwiseName"
    static let splitwiseEmail = "splitwiseEmail"
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
    var eventsKeys: [String: Int] = [:]
    var wallet: Double = 0
    var transactions: [Transaction] = []
    var facebookFriends: [FacebookFriend] = []
    var splitwiseID: Int!
    var splitwiseName: String!
    var splitwiseEmail: String!
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary[UserKey.id] as! String
        self.name = dictionary[UserKey.name] as! String
        self.photoURLString = dictionary[UserKey.photo] as! String
        /// add splitwise stuff
        self.splitwiseID = dictionary[UserKey.splitwiseID] as! Int
        self.splitwiseEmail = dictionary[UserKey.splitwiseEmail] as! String
        self.splitwiseName = dictionary[UserKey.splitwiseName] as! String
    }
    
    init(user: User, completion: (() -> Void)?) {
        var userDict: [String: Any] = [UserKey.id: FBSDKAccessToken.current().userID,
                                       UserKey.name: user.displayName!,
                                       UserKey.photo: user.photoURL?.absoluteString ?? "gs://events-86286.appspot.com/default"]
        self.uid = userDict[UserKey.id] as! String
        self.name = userDict[UserKey.name] as! String
        self.photoURLString = userDict[UserKey.photo] as! String
        
        // Adds user only if the user does not exists
        FirebaseDatabaseManager.shared.addUser(userDict: userDict)
        FirebaseDatabaseManager.shared.fetchUserEvents(userid: self.uid) { (keys: [String: Int], events: [String: Any]) in
            self.eventsKeys = keys
            for id in events.keys {
                let dict = events[id] as! [String: Any]
                self.events.append(Event(dictionary: dict))
            }
            completion?()
            FirebaseDatabaseManager.shared.addEventsListener()
            NotificationCenter.default.post(name: BashNotifications.eventsLoaded, object: nil)
            print("events loaded notification posted")
        }
        FirebaseDatabaseManager.shared.createWallet(id: uid) { (value: Double) in
            self.wallet = value
            FirebaseDatabaseManager.shared.addWalletListener(id: self.uid)
        }
        FacebookAPIManager.shared.getUserFriendsList { (friends: [FacebookFriend]) in
            self.facebookFriends = friends
        }
        FirebaseDatabaseManager.shared.getTransactions(id: self.uid) { (dict: [String : Any]) in
            var arr: [Transaction] = []
            for key in dict.keys {
                let transaction = Transaction(dict: dict[key] as! [String: Any])
                arr.append(transaction)
            }
            self.transactions = arr
        }
        
        if !SplitwiseAPIManger.shared.checkIfHaveCredentials() {
            SplitwiseAPIManger.shared.splitwiseLogin(success: { (idNum, name, email) in
                self.splitwiseID = idNum
                self.splitwiseName = name
                self.splitwiseEmail = email
                let dict: [String: Any] = [UserKey.splitwiseID: self.splitwiseID,
                                           UserKey.splitwiseName: self.splitwiseName,
                                           UserKey.splitwiseEmail: self.splitwiseEmail]
                FirebaseDatabaseManager.shared.addSplitwiseToDatabase(id: self.uid, dict: dict)
            }, failure: { (error) in
                print(error?.localizedDescription)
            })
        } else {
            
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppUser.walletChanged(_:)), name: BashNotifications.walletChanged, object: nil)
    }

    /**
     *
     * Events related functions
     *
     */
    //adds existing event to user event list
    func addInvite(event: Event) {
        self.eventsKeys[event.eventid] = InviteStatus.noResponse.rawValue
        self.events.append(event)
    }
    
    func delete(event: Event) {
        FirebaseDatabaseManager.shared.deleteEvent(event)
        self.removeUserFromEvent(event)
    }
    
    func accept(event: Event) {
        FirebaseDatabaseManager.shared.updateInvitation(for: event, withStatus: .accepted)
        self.eventsKeys[event.eventid] = InviteStatus.accepted.rawValue
        if event.cost != nil {
            let transaction = Transaction(event: event)
            self.transactions.append(transaction)
            FirebaseDatabaseManager.shared.addTransaction(transaction: transaction)
        }
    }
    
    func decline(event: Event) {
        FirebaseDatabaseManager.shared.updateInvitation(for: event, withStatus: .declined)
        FirebaseDatabaseManager.shared.removeTransaction(forEventID: event.eventid)
        if event.myStatus == .accepted {
            var idx: Int!
            for i in 0..<self.transactions.count {
                let transaction = self.transactions[i]
                if transaction.id == event.eventid {
                    idx = i
                    break
                }
            }
            self.transactions.remove(at: idx)
        }
        self.eventsKeys[event.eventid] = InviteStatus.declined.rawValue
    }
    
    @objc func walletChanged(_ notification: NSNotification) {
        let value = notification.object as! Double
        self.wallet = value
    }

    
    func getBasicDict() -> [String: Any] {
        let dict = [UserKey.id: self.uid,
                    UserKey.name: self.name,
                    UserKey.photo: self.photoURLString]
        return dict
    }
    
    //create event and add to user event list and event database
    func createEvent(_ eventDict: [String: Any]) -> Event {
        let event = Event(dictionary: eventDict)
        self.eventsKeys[event.eventid] = InviteStatus.accepted.rawValue
        self.events.append(event)
        FirebaseDatabaseManager.shared.createEvent(eventDict) {
            FirebaseDatabaseManager.shared.inviteGuests(event.guestlist, to: event)
        }
        var splitwiseUserIDs: [String] = []
        var splitwiseNames: [String] = []
        var splitwiseEmails: [String] = []
        for fireBaseUserID in Array(event.guestlist.keys){
            FirebaseDatabaseManager.shared.getSingleUser(id: fireBaseUserID, completion: { (appUser) in
                splitwiseEmails.append(appUser.splitwiseEmail)
                splitwiseNames.append(appUser.splitwiseName)
                splitwiseUserIDs.append(String(appUser.splitwiseID))
            })
        }
        SplitwiseAPIManger.shared.createFriends(invitedFirstNames: splitwiseNames, invitedEmails: splitwiseEmails) { 
            SplitwiseAPIManger.shared.createGroup(groupName: event.eventname, individualCost: event.cost!, description: event.description, memberIDs: splitwiseUserIDs)
        }
        return event
    }
    
    //remove event from user event list
    private func removeUserFromEvent(_ event: Event) {
        FirebaseDatabaseManager.shared.removeUserFromEvent(event)
        let index = self.events.index(of: event)!
        self.events.remove(at: index)
        self.eventsKeys.removeValue(forKey: event.eventid)
    }
    
    func addToWallet(amount: Double) {
        FirebaseDatabaseManager.shared.updateWallet(id: self.uid, withValue: self.wallet + amount)
    }
}

