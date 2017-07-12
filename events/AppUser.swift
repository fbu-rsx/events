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
    
    static var current: User {
        get {
            return Auth.auth().currentUser!
        }
    }
    
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
        name = user.displayName!
        email = user.email!
        profileURL = user.photoURL
    }
    
    func signIn(user: User) {
//        FirebaseAuthManager.shared.signInExistingWith(email: user.email, password: user.password)
    }
    
//    private func getLocation() {
//        return FirebaseDatabaseManager.
//    }
}
