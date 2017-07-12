//
//  FirebaseStorageManager.swift
//  events
//
//  Created by Skyler Ruesga on 7/12/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation
import Firebase

class FirebaseStoreageManager {
    
    // Get a reference to the storage service using the default Firebase App
    // Create a storage reference from Firebase storage service
    static let storageRef = Storage.storage().reference()
    
    // When calling this function, will need to convert images/videos to type Data (how to at bottom of page)
    func uploadFile(refLocation: String, data: Data, completion: ()->()){
        let fileRef = FirebaseStoreageManager.storageRef.child(refLocation)
        fileRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else{
                print(error?.localizedDescription ?? "default error")
                return
            }
            let downloadURL =  metadata.downloadURL()
        }
    }
    
}

/* How to put image into a data object!
let image = UIImagePNGRepresentation(imageView.image!) as NSData?
imageView.image = UIImage(data: image as! Data)*/
