//
//  FacebookFriend.swift
//  events
//
//  Created by Skyler Ruesga on 7/26/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation

enum FriendKey: String {
    case id = "id"
    case name = "name"
    case photo = "picture"
}

class FacebookFriend {
    var id: String
    var name: String
    var photo: URL
    
    init(dict: [String: Any]) {
        //print(dict)
        self.id = dict[FriendKey.id.rawValue] as! String
        self.name = dict[FriendKey.name.rawValue] as! String
        let picDict = dict[FriendKey.photo.rawValue] as! [String: Any]
        let data = picDict["data"] as! [String: Any]
        let urlString = data["url"] as! String
        self.photo = URL(string: urlString)!
    }
}
