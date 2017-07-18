//
//  Event.swift
//  events
//
//  Created by Skyler Ruesga on 7/12/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation
import UIKit

class Event {
    
    var eventid: String
    var eventDictionary: [String: Any]

    //all below are required in the dictionary user to initialize an event
    var eventname: String
    var totalcost: Double? //optional because may just be a free event
    var location: [Double]
    var time: Date
    var organizerID: String //uid of the organizer
    var guestlist: [String: Bool] // true if guest attended
    var photos: [String: String]
    var description: String
    
    
    
    
    /* Example Dictionary:
    dictionary: {
        "eventname": "Coachella"
        "totalcost": 500000.00
        "location": [longitude, latitude] (Doubles)
        "organizer": "uid" (String)
        "guestlist":
            // true if user checked in /attended
            "uid1": true
            "uid1": true
        "photos":
     
    }
    */
    init(dictionary: [String: Any]) {
        self.eventid = dictionary["eventid"] as! String
        self.eventname = dictionary["eventname"] as! String
        self.totalcost = dictionary["totalcost"] as? Double
        self.time = dictionary["time"] as! Date
        self.location = dictionary["location"] as! [Double]
        self.organizerID = dictionary["organizerID"] as! String
        self.guestlist = dictionary["guestlist"] as? [String: Bool] ?? [:]
        self.photos = dictionary["photos"] as? [String: String] ?? [:]
        self.description = dictionary["description"] as! String
        self.eventDictionary = dictionary
    }
    
    
    func getGuestList() -> [AppUser] {
        return FirebaseDatabaseManager.shared.getUsersFromEventDict(dictionary: self.guestlist)
    }
    
    func uploadImage(_ image: UIImage) {
        FirebaseDatabaseManager.shared.addImage(eventID: self.eventid) { (id) in
            FirebaseStorageManager.shared.uploadImage(user: AppUser.current, image: image, imageID: id, eventID: self.eventid)
        }
    }
}
