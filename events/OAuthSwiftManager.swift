//
//  OAuthSwiftManager.swift
//  events
//
//  Created by Rhian Chavez on 7/11/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation
import OAuthSwift

class OAuthSwiftManager {
    
    func authorizeWithOath2(){
        let oauthswift = OAuth2Swift(
        consumerKey:    "********", // replace with consumerKey
        consumerSecret: "********", // replace with consumerSecret
        authorizeUrl:   "https://api.instagram.com/oauth/authorize", // replace with proper url
        responseType:   "token" // correct?
        )
        let handle = oauthswift.authorize(
            withCallbackURL: URL(string: "oauth-swift://oauth-callback/instagram")!, // replace with proper url
            scope: "likes+comments", state:"INSTAGRAM", // replace with proper arguments
            success: { credential, response, parameters in
                print(credential.oauthToken)
                // Do your request
        },
            failure: { error in
                print(error.localizedDescription)
        }
        )
    }
    
}
