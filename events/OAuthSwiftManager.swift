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

class OAuthSwiftManager: SessionManager {
    
    static let spotifyConsumerKey = "c4ee2fb79ba345f39fc00914f36fe4a7"
    static let spotifySecret = "de1780aeca7840efbffe31a463c94767"
    static let spotifyAuthorizeUrl = "https://accounts.spotify.com/authorize"
    static let spotifyAccessTokenUrl = "https://accounts.spotify.com/api/token"
    static let callBackUrl = "events://"
    
    static var shared: OAuthSwiftManager = OAuthSwiftManager()
    var oauth : OAuth2Swift!
    
    private init() {
        super.init()
        
        oauth = OAuth2Swift(consumerKey: OAuthSwiftManager.spotifyConsumerKey, consumerSecret: OAuthSwiftManager.spotifySecret, authorizeUrl: OAuthSwiftManager.spotifyAuthorizeUrl, accessTokenUrl: OAuthSwiftManager.spotifyAccessTokenUrl, responseType: "token")
        
        if let credential = retrieveCredentials() {
            oauth.client.credential.oauthToken = credential.oauthToken
            oauth.client.credential.oauthTokenSecret = credential.oauthTokenSecret
        }
        else{
            spotifyLogin(success: {}, failure: { (error) in
                print(error!.localizedDescription)
            })
        }
        
        // Assign oauth request adapter to Alamofire SessionManager adapter to sign requests
        adapter = oauth.requestAdapter
    }
    
    func spotifyLogin(success: @escaping () -> (), failure: @escaping (Error?) -> ()) {
        
        // Add callback url to open app when returning from Twitter login on web
        let Scope = "playlist-modify-public playlist-modify-private user-follow-modify user-read-private"
        
        let callback = URL(string: OAuthSwiftManager.callBackUrl)!
        
        oauth.authorize(withCallbackURL: callback, scope: Scope, state: "randomString", success: { (credential, response, parameters) in
            print(credential)
            self.save(credential: credential)
            success()
        }) { (error) in
            failure(error)
        }
        
    }
//    
//    func logout() {
//        clearCredentials()
//        // User.current = nil
//        NotificationCenter.default.post(name: BashNotifications.logout, object: nil)
//    }
//    
    // MARK: Handle url
    // OAuth Step 3
    // Finish oauth process by fetching access token
    func handle(url: URL) {
        OAuth2Swift.handle(url: url)
    }
    
    // MARK: Save Tokens in Keychain
    private func save(credential: OAuthSwiftCredential) {
        
        // Store access token in keychain
        let keychain = Keychain()
        let data = NSKeyedArchiver.archivedData(withRootObject: credential)
        keychain[data: "spotify_credentials"] = data
        getSpotifyUserID()
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
    
    func testConnection() -> Bool{
        if let credential = retrieveCredentials(){
            return true
        }
        else{
            return false
        }
    }
    
    // functions to interact with spotify web client
    // use oauth
    
    private func getSpotifyUserID(){
        let url = URL(string: "https://api.spotify.com/v1/me")!
        request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { (response) in
            //print(response)
            let response = response.result.value as! [String: Any]
            let uri = response["uri"] as! String
            let id = uri.replacingOccurrences(of: "spotify:user:", with: "")
            UserDefaults.standard.set(id, forKey: "spotify-user")
        }
    }
    
    func createPlaylist(name: String, completion: @escaping (_ id: String)->()){
        let spotifyUserID = UserDefaults.standard.value(forKey: "spotify-user") as? String
        let url = URL(string: "https://api.spotify.com/v1/users/\(spotifyUserID!)/playlists")
        //print(url)
        let Parameters: [String: Any] = ["name": name, "public": false, "collaborative": true]
        let header = ["Content-Type": "application/json"]
        var final: String?
        request(url!, method: .post, parameters: Parameters, encoding: JSONEncoding.default, headers: header).validate().responseJSON { (response) in
            if response.result.isSuccess{
                let result = response.result.value as! [String: Any]
                final =  result["id"] as? String
            }else{
                print("Error: " + response.result.error!.localizedDescription)
            }
            completion(final!)
        }
        
    }
    
    func getTracksForPlaylist(userID: String, playlistID: String, completion: @escaping (_ tracks: [String]) -> ()){
        //let spotifyUserID = UserDefaults.standard.value(forKey: "spotify-user") as? String
        let url = URL(string: "https://api.spotify.com/v1/users/\(userID)/playlists/\(playlistID)/tracks")
        // can later specify parameters to only return specific parts of JSON
        request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { (response) in
            if response.result.isSuccess {
                let result = response.result.value as! [String: Any]
                var names: [String] = []
                let tracks = result["items"] as! [[String: Any]]
                //print(tracks)
                
                for track in tracks{
                    let inner = track["track"] as! [String: Any]
                    names.append(inner["name"] as! String)
                }
                //print(names)
                completion(names)
            }
            else{
                print("Error: Couldn't fetch Spotify Tracks")
            }
        }
    }
    
    func addSongToPlaylist(userID: String, playlistID: String, song: String){
        //let spotifyUserID = UserDefaults.standard.value(forKey: "spotify-user") as! String
        let url = URL(string: "https://api.spotify.com/v1/users/\(userID)/playlists/\(playlistID)/tracks?=uris=spotify%3Atrack%3A\(song)")
        //print(url)
        let header = ["Content-Type": "application/json"]
        // uris format: uris=spotify:track:4iV5W9uYEdYUVa79Axb7Rh, spotify:track:1301WleyT98MSxVHPZCA6M
        request(url!, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: header).validate().responseJSON { (response) in
            print(response)
        }
    }
    
    func search(songName: String, completion: @escaping (_ songs: [String], _ uris: [String])->()){
        let name = songName.replacingOccurrences(of: " ", with: "%20")
        let url = URL(string: "https://api.spotify.com/v1/search?q=\(name)&type=track")
        request(url!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).validate().responseJSON { (response) in
            let result = response.result.value as! [String: Any]
            let tracks = result["tracks"] as! [String: Any]
            let items = tracks["items"] as! [[String: Any]]
            var songs: [String] = []
            var uris: [String] = []
            for item in items{
                songs.append(item["name"] as! String)
                uris.append(item["uri"] as! String)
            }
            completion(songs, uris)
        }
    }
    
}

enum JSONError: Error {
    case parsing(String)
}
