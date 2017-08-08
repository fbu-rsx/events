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
    
    func splitwiseLogin(success: ((_ id: Int, _ name: String, _ email: String)->())?, failure: @escaping (Error?) -> ()) {
        
        let callback = URL(string: SplitwiseAPIManger.callBackUrl)!
        
        oauth.authorize(withCallbackURL: callback, success: { (credential, response, parameters) in
            //print(response)
            self.save(credential: credential)
            self.getCurrentUser(closure: success)
            
            
            
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
    
    func getCurrentUser(closure: ((_ id: Int, _ name: String, _ email: String)->())?){
        let url = URL(string: "https://secure.splitwise.com/api/v3.0/get_current_user")!
        request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { (response) in
            print(response)
            if response.result.isSuccess{
                var result = response.result.value as! [String: Any]
                result = result["user"] as! [String: Any]
                let idInt = result["id"] as! Int
                
                //let idString = String(idInt)!
                let name = result["first_name"] as! String
                let email = result["email"] as! String
                // we now have name, idString, and email which should be added to the Firebase Database and associated with current user
                if let closure = closure{
                    closure(idInt, name, email)
                }
            }
        }
    }
    
    func getUser(id: String, completion: ()->()){
        let url = URL(string: "https://secure.splitwise.com/api/v3.0/get_user/\(id)")!
        request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { (response) in
            print(response)
        }
    }
    
    func checkIfHaveCredentials()-> Bool{
        let keychain = Keychain()
        if let data = keychain[data: "splitwise_credentials"] {
            //let credential = NSKeyedUnarchiver.unarchiveObject(with: data) as! OAuthSwiftCredential
            return true
        } else {
            return false
        }
    }
    
    func createFriends(invitedFirstNames:[String], invitedEmails: [String], closure: @escaping ()->()){
        var baseString = "https://secure.splitwise.com/api/v3.0/create_friends?"
        for userNum in 0..<invitedEmails.count{
            let stringIndex = String(userNum)
            if userNum != 0{
                baseString += "&"
            }
            baseString += "&friends__\(stringIndex)__user_email=\(invitedEmails[userNum])&friends__\(stringIndex)__user_first_name=\(invitedFirstNames[userNum])"
        }
        let url = URL(string: baseString)!
        print(url)
        request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { (response) in
            print(response)
            closure()
        }
    }

    func createGroup(groupName: String, individualCost: Double, description: String, memberIDs: [String]){
        var baseString: String = "https://secure.splitwise.com/api/v3.0/create_group?name=\(groupName)"
        for userNum in 0..<memberIDs.count{
            let stringIndex = String(userNum)
            baseString += "&users__\(stringIndex)__user_id=\(memberIDs[userNum])"
        }
        let url = URL(string: baseString)!
        print(url)
        request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { (response) in
            print(response)
            if response.result.isSuccess{
                let response = response.result.value as! [String: Any]
                let group = response["group"] as! [String: Any]
                print(group)
                let id = group["id"] as! Int
                let idString = String(id)
                self.createExpense(individualCost: individualCost, description: description, groupID: idString, invitedUsersIDs: memberIDs)
            }
        }
    }
    
    private func createExpense(individualCost: Double, description: String, groupID: String, invitedUsersIDs: [String]){
        // need to make user 0's id current users splitwise ID and say they are owed the total
        let invididualCostString = String(individualCost)
        let total = individualCost*Double(invitedUsersIDs.count)
        let totalString = String(total)
        var baseString: String = "https://secure.splitwise.com/api/v3.0/create_expense?payment=0&cost=\(totalString)&description=\(description)&group_id=\(groupID)&users__0__user_id=\(String(AppUser.current.splitwiseID))&users__0__paid_share=\(totalString)&users__0__owed_share=0"
        for userNum in 1...invitedUsersIDs.count{
            let stringIndex = String(userNum)
            baseString += "&users__\(stringIndex)__user_id=\(invitedUsersIDs[userNum-1])&users__\(stringIndex)__paid_share=0&users__\(stringIndex)__owed_share=\(invididualCostString)"
        }
        let url = URL(string: baseString)!
        print(url)
        //let params: [String: Any] = ["payment": 0, "cost": "100", "description": description, "group_id": String(groupID)]
        request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { (response) in
            print(response)
        }
        
    }
 
}
