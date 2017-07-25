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

// attempting to follow CodePath's implementation in out Twitter Demo App

class OAuthSwiftManager: SessionManager {
    
    static let spotifyConsumerKey = "c4ee2fb79ba345f39fc00914f36fe4a7"
    static let spotifySecret = "de1780aeca7840efbffe31a463c94767"
    static let spotifyAuthorizeUrl = "https://accounts.spotify.com/authorize"
    static let spotifyAccessTokenUrl = "https://accounts.spotify.com/api/token"
    static let callBackUrl = "events://"
    
    func spotifyLogin(success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        
        // Add callback url to open app when returning from Twitter login on web
        let Scope = "playlist-modify-public playlist-modify-private user-follow-modify"
        
        let callback = URL(string: OAuthSwiftManager.callBackUrl)!

        oauth.authorize(withCallbackURL: callback, scope: Scope, state: "random", success: { (credential, response, parameters) in
            self.save(credential: credential)
        }) { (error) in
            print("Error was hahteklra;sldfjka;sdlfjk")
            failure(error)
        }
        
    }
    
    func logout() {
        clearCredentials()
        // TODO: Clear current user by setting it to nil
        //User.current = nil
        NotificationCenter.default.post(name: NSNotification.Name("didLogout"), object: nil)
    }
    
    static var shared: OAuthSwiftManager = OAuthSwiftManager()
    var oauth : OAuth2Swift!
    
    private init() {
        super.init()
        
        oauth = OAuth2Swift(consumerKey: OAuthSwiftManager.spotifyConsumerKey, consumerSecret: OAuthSwiftManager.spotifySecret, authorizeUrl: OAuthSwiftManager.spotifyAuthorizeUrl, accessTokenUrl: OAuthSwiftManager.spotifyAccessTokenUrl, responseType: "code")
        
        if let credential = retrieveCredentials() {
            oauth.client.credential.oauthToken = credential.oauthToken
            oauth.client.credential.oauthTokenSecret = credential.oauthTokenSecret
        }
        
        // Assign oauth request adapter to Alamofire SessionManager adapter to sign requests
        adapter = oauth.requestAdapter
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
        keychain[data: "spotify_credentials"] = data
    }
    
    private func retrieveCredentials() -> OAuthSwiftCredential? {
        let keychain = Keychain()
        
        if let data = keychain[data: "spotify_credentials"] {
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
            try keychain.remove("spotify_credentials")
        } catch let error {
            print("error: \(error)")
        }
    }
}

enum JSONError: Error {
    case parsing(String)
}
