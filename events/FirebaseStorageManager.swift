//
//  FirebaseStorageManager.swift
//  events
//
//  Created by Rhian Chavez on 7/12/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation
import Firebase

class FirebaseStorageManager {
    
    // Get a reference to the storage service using the default Firebase App
    // Create a storage reference from Firebase storage service
    let storageRef = Storage.storage().reference()
    var imageIDs: [String: [String]] = [:] // [eventID: [picIDs]]
    static var shared = FirebaseStorageManager()
    
    // When calling this function, will need to convert images/videos to type Data (how to at bottom of page)
    // We can easily allow for metadata to be uploaded as well later one
    func uploadImage(user: AppUser, image: UIImage, imageID: String, eventID: String){
        let data = UIImagePNGRepresentation(image)! as NSData
        //let fileRef = storageRef.child("\(event.eventid)/images/\(imageID)")
        let fileRef = storageRef.child("\(eventID)/images/\(imageID)")
        // create task so that we can later implement observers
        let uploadTask = fileRef.putData(data as Data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else{
                print(error?.localizedDescription ?? "default error")
                return
            }
            let downloadURL =  metadata.downloadURL()
        }
    }
    
    func downloadImage(event: Event, imageID: String, completion: @escaping (_ image: UIImage)->()){
        let fileRef = storageRef.child("\(event.eventid)/images/\(imageID)")
        // temporary maxSize
        fileRef.getData(maxSize: 30000*30000) { (data, error) in
            if let error = error {
                print(error.localizedDescription)
                
            }
            else{
                // Assuming that return value of request is a UIImage
                let image = UIImage(data: data!)
                // either return image or pass it into completion
                completion(image!)
            }
        }
        // We can also add observers later on
    }
    
}

/* How to put image into a data object!
let image = UIImagePNGRepresentation(imageView.image!) as NSData?
imageView.image = UIImage(data: image as! Data)*/
