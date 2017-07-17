//
//  User.swift
//  events
//
//  Created by Skyler Ruesga on 7/12/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation
import FirebaseAuth

class AppUser {
    
    static var current: AppUser!
    
    var uid: String
    var name: String
    var email: String
    var password: String?
    var photoURLString: String
    var events: [Event]!
    var eventsDict: [String: Bool]!
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as! String
        self.name = dictionary["name"] as! String
        self.email = dictionary["email"] as! String
        self.photoURLString = dictionary["photoURLString"] as! String
    }
    
    convenience init(user: User) {
        let userDict: [String: Any] = ["uid": user.uid,
                                       "name": user.displayName!,
                                       "email": user.email!,
                                       "photoURLString": user.photoURL?.absoluteString ?? "gs://events-86286.appspot.com/default"]
        self.init(dictionary: userDict)
      
        // Adds user only if the user does not exists
        FirebaseDatabaseManager.shared.addUser(appUser: self, dict: userDict)
    }
    
    /*
     * Events related functions
     */
    func addEvent(_ event: Event) {
        FirebaseDatabaseManager.shared.addEvent(event: event)
    }
    
    
    
    /*
     * Private functions
     */
}
