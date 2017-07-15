//
//  Event.swift
//  events
//
//  Created by Skyler Ruesga on 7/12/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation

class Event {
    
    var eventid: String
    var eventname: String
    var totalcost: Double? //optional because may just be a free event
    var location: [Double]
    var longitude: Double
    var latitude: Double
    var organizerID: String //uid of the organizer
    var organizer: AppUser
    var guestlist: [String: Bool]
    var photos: [String: String]
    
    
    
    
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
        self.location = dictionary["location"] as! [Double]
        self.longitude = location[0]
        self.latitude = location[1]
        self.organizerID = dictionary["organizerID"] as! String
        self.organizer = AppUser(dictionary: FirebaseDatabaseManager.shared.getEventOrganizer(orgID: organizerID))
        self.guestlist = dictionary["guestlist"] as? [String: Bool] ?? [:]
        self.photos = dictionary["photos"] as? [String: String] ?? [:]
    }
}
