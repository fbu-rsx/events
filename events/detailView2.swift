//
//  detailView2.swift
//  events
//
//  Created by Rhian Chavez on 7/24/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class detailView2: UIView, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var songs: [String] = []
    
    var event: Event?{
        didSet{
            if let ID = event!.spotifyID {
                OAuthSwiftManager.shared.getTracksForPlaylist(userID: event!.playlistCreatorID!, playlistID: ID, completion: { (songs) in
                    self.songs = songs
                    self.tableView.reloadData()
                })
            }else{
                print("Spotify not working")
            }
        }
    }
    
    var subView: songOverlayView?
    var added: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "SongTableViewCell", bundle: nil), forCellReuseIdentifier: "songCell")
        let nib = UINib(nibName: "songSearchResultsOverlay", bundle: nil)
        subView = nib.instantiate(withOwner: self, options: nil).first as! songOverlayView
        subView!.frame = CGRect(x: 0, y: 90, width: self.frame.width, height: self.frame.height - 90)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongTableViewCell
        cell.label.text = songs[indexPath.row]
        return cell
    }
    
    @IBAction func didTap(_ sender: Any) {
        self.endEditing(true)
    }
    
    @IBAction func editingChanged(_ sender: Any) {
        if searchField.text == ""{
            subView?.removeFromSuperview()
            added = false
        }
        else if added == true {
            // update subview text
            OAuthSwiftManager.shared.search(songName: searchField.text!, completion: { (songs) in
                self.subView?.Songs = songs
                self.subView?.tableView.reloadData()
            })
        }
        else{
            self.addSubview(subView!)
            added = true
            // update subview text
            OAuthSwiftManager.shared.search(songName: searchField.text!, completion: { (songs) in
                self.subView?.Songs = songs
                self.subView?.tableView.reloadData()
            })
        }
    }
    
}
