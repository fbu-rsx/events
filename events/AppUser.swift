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
    
    static var current: AppUser?
    
    var user: User
    var name: String
    var email: String
    var password: String?
    var profileURL: URL?
//    var location: {
//        get {
//            return getLocation()
//        }
//    }
    
    init(user: User) {
        self.user = user
        name = user.displayName!
        email = user.email!
        profileURL = user.photoURL
    }
    
    
//    private func getLocation() {
//        return FirebaseDatabaseManager.
//    }
}
