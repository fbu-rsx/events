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
    
    static var current: User?
    
    var name: String
    var email: String
    var profileURL: URL?
//    var location: {
//        get {
//            return getLocation()
//        }
//    }
    
    init(dictionary: [String: Any]) {
        name = dictionary["name"] as! String
        email = dictionary["email"] as! String
        if let url = (dictionary["profileURLString"] as? String) {
            profileURL = URL(string: url)
        }
    }
    
//    private func getLocation() {
//        return FirebaseDatabaseManager.
//    }
}
