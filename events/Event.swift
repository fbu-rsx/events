//
//  Event.swift
//  events
//
//  Created by Skyler Ruesga on 7/12/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation
import MapKit
import UIKit

enum InviteStatus: Int {
    case noResponse = 0
    case delined = 1
    case accepted = 2
}

enum EventKey: String {
    case id = "eventid"
    case name = "eventname"
    case cost = "totalcost"
    case date = "datetime"
    case location = "location"
    case radius = "radius"
    case organizerID = "organizerID"
    case orgURLString = "organizerURLString"
    case about = "about"
    case guestlist = "guestlist"
    case photos = "photos"
    case active = "active"
}

class Event: NSObject, NSCoding, MKAnnotation {
    
    var eventid: String
    var eventDictionary: [String: Any]

    //all below are required in the dictionary user to initialize an event
    var eventname: String
    var totalcost: Float? //optional because may just be a free event
    var date: Date
    var coordinate: CLLocationCoordinate2D
    var radius: Double = 100
    var organizerID: String //uid of the organizer
    var organizerURL: URL //organizer photo URL
    var guestlist: [String: Bool] // true if guest attended
    var photos: [String: Bool]
    var about: String //description of event, the description variable as unfortunately taken by Objective C
    var myStatus: InviteStatus {
        return InviteStatus(rawValue: AppUser.current.eventsKeys[organizerID] as! Int)
    }
    
    
    //for Mapview anotations
    var title: String? {
        return eventname
    }
    var subtitle: String? {
        if about.isEmpty {
            return "No description."
        }
        return about
    }

    
    
    /* Example Dictionary:
    dictionary: {
     "eventid": String
     "eventname": "Birthday Party"
     "datetime": String
     "totalcost": 1000.00 (Float)
     "radius": 67.378 (Double)
     "location": [longitude, latitude] (Doubles)
     "organizerID": "uid"
     "about": "Come to my birthday party! We have lots of alcohol and food."
     "guestlist":
        // true if the user has attended/checked in
        "uid1": true
        "uid2": true
        "uid3": false
     "photos":
        "photo1": true
        "photo2": true
    }
    */
    init(dictionary: [String: Any]) {
        self.eventid = dictionary[EventKey.id.rawValue] as! String
        self.eventname = dictionary[EventKey.name.rawValue] as! String
        self.totalcost = dictionary[EventKey.cost.rawValue] as? Float
        let datetime = dictionary[EventKey.date.rawValue] as! String
        
        let dateConverter = DateFormatter()
        dateConverter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        self.date = dateConverter.date(from: datetime)!
        
        let location = dictionary[EventKey.location.rawValue] as! [Double]
        self.coordinate = CLLocationCoordinate2D(latitude: location[0], longitude: location[1])
        
        self.radius = dictionary[EventKey.radius.rawValue] as! Double
        self.organizerID = dictionary[EventKey.organizerID.rawValue] as! String
        self.organizerURL = URL(string: dictionary[EventKey.orgURLString.rawValue] as! String)!
        self.about = dictionary[EventKey.about.rawValue] as! String
        self.guestlist = dictionary[EventKey.guestlist.rawValue] as! [String: Bool]
        self.photos = dictionary[EventKey.photos.rawValue] as? [String: Bool] ?? [:]
        self.eventDictionary = dictionary
    }
    
    
    func getGuestList() -> [AppUser] {
        return FirebaseDatabaseManager.shared.getUsersFromEventDict(dictionary: self.guestlist)
    }
    
    func getDateStringOnly() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd,yyyy"
        return dateFormatterPrint.string(from: self.date)
    }
    
    func getTimeStringOnly() -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "h:mm a"
        return dateFormatterPrint.string(from: self.date)
    }
    
    func getDateTimeString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: self.date)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        if let event = object as? Event {
            if self.eventid == event.eventid {
                return true
            }
        }
        return false
    }
    
    
    
    // MARK: NSCoding
    required convenience init?(coder decoder: NSCoder) {
        let dict = decoder.decodeObject(forKey: "eventDictionary") as! [String: Any]
        self.init(dictionary: dict)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.eventDictionary, forKey: "eventDictionary")
    }
    
    func uploadImage(_ image: UIImage) {
        FirebaseDatabaseManager.shared.addImage(eventID: self.eventid) { (id) in
            FirebaseStorageManager.shared.uploadImage(user: AppUser.current, image: image, imageID: id, eventID: self.eventid)
        }
    }
}
