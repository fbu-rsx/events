//
//  FacebookAPIManager.swift
//  events
//
//  Created by Skyler Ruesga on 7/25/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation
import FBSDKCoreKit

class FacebookAPIManager {
    
    static var shared = FacebookAPIManager()
    
    
    
    func getUserFriendsList() {
        let params = ["fields": "id, first_name, last_name, name, picture", "limit": "1000"]
        let request = FBSDKGraphRequest(graphPath: "/me/friends", parameters: params)
        
        let connection = FBSDKGraphRequestConnection()
        connection.add(request) { (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let result = result as? [String: Any] {
                print("starting friends list")
                let arr = result["data"] as! NSArray
                for x in arr {
                    print(x)
                }
                print(arr.count)
                print("ending friends list")
            }
        }
        connection.start()
    }
}
