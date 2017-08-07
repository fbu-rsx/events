//
//  OAuthSwiftManager.swift
//  events
//
//  Created by Rhian Chavez on 7/11/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import Foundation
import OAuthSwift
import KeychainAccess
import Alamofire
import OAuthSwiftAlamofire


class SplitwiseAPIManger: SessionManager {
    
    static let splitwiseConsumerKey = "FfJUYvtU4ISkp0vyv7zcKXJIrQBaMMbXLPQUZ1Ko"
    static let splitwiseSecret = "i4400fExI2KcWcT372uDYWLQrD7l5hGzM2T0ypYT"
    static let splitwiseAuthorizeUrl = "https://secure.splitwise.com/oauth/authorize"
    static let splitwiseAccessTokenUrl = "https://secure.splitwise.com/oauth/access_token"
    static let splitwiseRequestTokenUrl = "https://secure.splitwise.com/oauth/request_token"
    static let callBackUrl = "events://callback"
    
    static var shared: SplitwiseAPIManger = SplitwiseAPIManger()
    var oauth : OAuth1Swift!
    
    private init() {
        super.init()
        
        oauth = OAuth1Swift(consumerKey: SplitwiseAPIManger.splitwiseConsumerKey, consumerSecret: SplitwiseAPIManger.splitwiseSecret, requestTokenUrl: SplitwiseAPIManger.splitwiseRequestTokenUrl, authorizeUrl: SplitwiseAPIManger.splitwiseAuthorizeUrl, accessTokenUrl: SplitwiseAPIManger.splitwiseAccessTokenUrl)
        
        if let credential = retrieveCredentials() {
            oauth.client.credential.oauthToken = credential.oauthToken
            oauth.client.credential.oauthTokenSecret = credential.oauthTokenSecret
            oauth.client.credential.oauthRefreshToken = credential.oauthRefreshToken
        }
        //        else{
        //            splitwiseLogin(success: {}, failure: { (error) in
        //                print(error!.localizedDescription)
        //            })
        //        }
        
        // Assign oauth request adapter to Alamofire SessionManager adapter to sign requests
        adapter = oauth.requestAdapter
    }
    
    func splitwiseLogin(success: (()->())?, failure: @escaping (Error?) -> ()) {
        
        let callback = URL(string: SplitwiseAPIManger.callBackUrl)!
        
        oauth.authorize(withCallbackURL: callback, success: { (credential, response, parameters) in
            self.save(credential: credential)
        }) { (error) in
            failure(error)
        }
        
    }
    
    func splitwiseTest(){
        request(URL(string: "https://secure.splitwise.com/api/v3.0/test")!).validate().responseJSON { (response) in
            print(response)
        }
    }
    
    func logout() {
        clearCredentials()
        //NotificationCenter.default.post(name: BashNotifications.logout, object: nil)
    }
    
    // MARK: Handle url
    // OAuth Step 3
    // Finish oauth process by fetching access token
    func handle(url: URL) {
        OAuth1Swift.handle(url: url)
    }
    
    // MARK: Save Tokens in Keychain
    private func save(credential: OAuthSwiftCredential) {
        
        // Store access token in keychain
        let keychain = Keychain()
        let data = NSKeyedArchiver.archivedData(withRootObject: credential)
        keychain[data: "splitwise_credentials"] = data
        //getSpotifyUserID({})
    }
    
    private func retrieveCredentials() -> OAuthSwiftCredential? {
        let keychain = Keychain()
        if let data = keychain[data: "splitwise_credentials"] {
            let credential = NSKeyedUnarchiver.unarchiveObject(with: data) as! OAuthSwiftCredential
            return credential
        } else {
            return nil
        }
    }
    
    // MARK: Clear tokens in Keychain
    private func clearCredentials() {
        // Store access token in keychain
        let keychain = Keychain()
        do {
            try keychain.remove("splitwise_credentials")
        } catch let error {
            print("error: \(error)")
        }
    }
    
    
    //////////////////////////////////////////////////////////
    //   Functions to Interact with Splitwise Web Client    //
    //////////////////////////////////////////////////////////
    
    func getCurrentUser(){
        let url = URL(string: "https://secure.splitwise.com/api/v3.0/get_current_user")!
        request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { (response) in
            print(response)
        }
    }
    
    func getUser(id: String){
        let url = URL(string: "https://secure.splitwise.com/api/v3.0/get_user/\(id)")!
        request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { (response) in
            print(response)
        }
    }

    func createGroup(memberIDs: [String]?){
        let url = URL(string: "https://secure.splitwise.com/api/v3.0/create_group")!
        var params: [String: Any] = ["name":"test group 2"]
        if let IDs = memberIDs{
            params = ["name":"test group 3", "users__ARRAYINDEX__PARAMNAME": IDs]
        }
        request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { (response) in
            print(response)
            if response.result.isSuccess{
                let response = response.result.value as! [String: Any]
                let group = response["group"] as! [String: Any]
                let idnum = group["id"] as! Int
                let id = String(idnum)
                print(idnum)
                self.createExpense(name: "test", cost: "100", description: "test", groupID: id)
            }
        }
    }
    
    func createExpense(name: String, cost: String, description: String, groupID: String){
        let url = URL(string: "https://secure.splitwise.com/api/v3.0/create_expense?payment=0&cost=100&description=\(description)&group_id=\(groupID)")!
        //let params: [String: Any] = ["payment": 0, "cost": "100", "description": description, "group_id": String(groupID)]
        request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { (response) in
            print(response)
        }
        
    }
 
}
