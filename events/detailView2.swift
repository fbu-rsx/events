//
//  detailView2.swift
//  events
//
//  Created by Rhian Chavez on 7/24/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class detailView2: UIView, UITableViewDelegate, UITableViewDataSource, addSongDelegate, UITextFieldDelegate{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    
    var songs: [String] = []
    var searchedSongNames: [String] = []
    var searchedSongsURIS: [String] = []
    
    var event: Event?{
        didSet{
            getTracks()
        }
    }
    
    var subView: songOverlayView?
    var added: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tableView.dataSource = self
        tableView.delegate = self
        let nib1 = UINib(nibName: "SongTableViewCell", bundle: nil)
        tableView.register(nib1, forCellReuseIdentifier: "songCell")
        let nib = UINib(nibName: "songSearchResultsOverlay", bundle: nil)
        subView = (nib.instantiate(withOwner: self, options: nil).first as! songOverlayView)
        subView!.frame = CGRect(x: 8, y: 89, width: self.frame.width, height: self.frame.height - 92)
        subView?.delegate = self
        searchField.delegate = self
        searchField.setBottomBorder()
        self.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.separatorInset = .zero
        tableView.separatorColor = Colors.coral
        tableView.layoutMargins = .zero
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.resignFirstResponder()
        //getTracks()
        return true
    }
    
    func getTracks(){
        if let ID = event!.spotifyID {
            OAuthSwiftManager.shared.getTracksForPlaylist(userID: event!.playlistCreatorID!, playlistID: ID, completion: { (songs) in
                self.songs = songs
                self.songs.sort()
                self.tableView.reloadData()
            })
        }else{
            print("Spotify not working")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongTableViewCell
        cell.label.text = songs[indexPath.row]
        cell.preservesSuperviewLayoutMargins = false
        cell.separatorInset = UIEdgeInsets.zero
        cell.layoutMargins = UIEdgeInsets.zero
        cell.isUserInteractionEnabled = false
        return cell
    }
    
    @IBAction func editingChanged(_ sender: Any){
        if searchField.text == ""{
            subView?.removeFromSuperview()
            added = false
        }
        else if added == true {
            // update subview text
            OAuthSwiftManager.shared.search(songName: searchField.text!, completion: { (songs, uris) in
                self.searchedSongNames = songs
                self.searchedSongsURIS = uris
                self.subView?.Songs = songs
                self.subView?.tableView.reloadData()
            })
        }
        else{
            self.addSubview(subView!)
            added = true
            // update subview text
            OAuthSwiftManager.shared.search(songName: searchField.text!, completion: { (songs, uris) in
                self.searchedSongNames = songs
                self.searchedSongsURIS = uris
                self.subView?.Songs = songs
                self.subView?.tableView.reloadData()
            })
        }
    }
    
    func addSong(songIndex: Int) {
        let song = searchedSongsURIS[songIndex].replacingOccurrences(of: "spotify:track:", with: "")
        FirebaseDatabaseManager.shared.addQueuedSong(event: event!, songID: song)
        songs.append(searchedSongNames[songIndex])
        songs.sort()
        tableView.reloadData()
        searchField.text = nil
        subView?.removeFromSuperview()
        added = false
        textFieldShouldReturn(searchField)
        // inform user that song was added
        let songName = searchedSongNames[songIndex]
        let alertController = UIAlertController(title: "Song Request Made", message: "\(songName) has been requested", preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(OKAction)
        var rootViewController = UIApplication.shared.keyWindow?.rootViewController
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        rootViewController?.present(alertController, animated: true, completion: nil)
    }
    
}
