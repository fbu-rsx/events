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
    
    func createNewuser(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { (user: User?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as Error {
            print("Error signing out : %@", signOutError)
        }
    }
    
    func deleteCurrentUser() {
        Auth.auth().currentUser?.delete(completion: { (error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            }
        })
    }
    
//    func reauthenticateUser() {
//        let user = Auth.auth().currentUser
//        
//        
//        
//        user?.reauthenticate(with: credential, completion: { (error: Error?) in
//            if let error = error {
//                print(error.localizedDescription)
//            }
//        })
//    }
}
