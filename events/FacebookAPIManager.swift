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
    
    
    
    func getUserFriendsList(completion: @escaping ([FacebookFriend]) -> Void) {
        let params = ["fields": "id, name, picture", "limit": "1000"]
        let request = FBSDKGraphRequest(graphPath: "/me/friends", parameters: params)
        
        var friends = [FacebookFriend]()
        
        let connection = FBSDKGraphRequestConnection()
        connection.add(request) { (connection: FBSDKGraphRequestConnection?, result: Any?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
            } else if let result = result as? [String: Any] {
                let arr = result["data"] as! NSArray
                for x in arr {
                    friends.append(FacebookFriend(dict: x as! [String: Any]))
                }
                completion(friends)
            }
        }
        connection.start()
    }
}
