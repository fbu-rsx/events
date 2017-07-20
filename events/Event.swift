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

class Event: NSObject, NSCoding, MKAnnotation {
    
    var eventid: String
    var eventDictionary: [String: Any]

    //all below are required in the dictionary user to initialize an event
    var eventname: String
    var totalcost: Float? //optional because may just be a free event
    var coordinate: CLLocationCoordinate2D
    var radius: Double = 100
    var date: Date
    var organizerID: String //uid of the organizer
    var guestlist: [String: Bool] // true if guest attended
    var photos: [String: String]
    var about: String //description of event, the description variable as unfortunately taken by Objective C
    
    
    
    
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
        self.totalcost = dictionary["totalcost"] as? Float
        let datetime = dictionary["date"] as! String
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd hh:mm:ss"
        self.date = dateFormatterGet.date(from: datetime)!
        
        let location = dictionary["location"] as! [Double]
        self.coordinate = CLLocationCoordinate2D(latitude: location[0], longitude: location[1])
        
        self.organizerID = dictionary["organizerID"] as! String
        self.guestlist = dictionary["guestlist"] as? [String: Bool] ?? [:]
        self.photos = dictionary["photos"] as? [String: String] ?? [:]
        self.about = dictionary["about"] as! String
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
        dateFormatterPrint.dateFormat = "hh:mm:ss"
        return dateFormatterPrint.string(from: self.date)
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
