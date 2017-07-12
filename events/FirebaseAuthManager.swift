//
//  FirebaseAuthManager.swift
//  events
//
//  Created by Skyler Ruesga on 7/12/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation
import FirebaseAuth

class FirebaseAuthManager {
    
    static var shared = FirebaseAuthManager()
    
    var handle: AuthStateDidChangeListenerHandle?
    
    private init() {
        
    }
    
    
    func signInExistingWith(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user: User?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
