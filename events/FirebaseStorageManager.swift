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
    // We can easily allow for metadata to be uploaded as well later one
    func uploadFile(refLocation: String, data: Data, completion: ()->()){
        let fileRef = FirebaseStoreageManager.storageRef.child(refLocation)
        // create task so that we can later implement observers
        let uploadTask = fileRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else{
                print(error?.localizedDescription ?? "default error")
                return
            }
            let downloadURL =  metadata.downloadURL()
        }
    }
    
    func downloadFile(refLocation: String, completion: ()->()){
        let fileRef = FirebaseStoreageManager.storageRef.child(refLocation)
        // temporary maxSize
        fileRef.getData(maxSize: 1024*1024) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            else{
                // Assuming that return value of request is a UIImage
                let image = UIImage(data: data!)
                // either return image or pass it into completion
            }
        }
        // We can also add observers later on
    }
    
}

/* How to put image into a data object!
let image = UIImagePNGRepresentation(imageView.image!) as NSData?
imageView.image = UIImage(data: image as! Data)*/
