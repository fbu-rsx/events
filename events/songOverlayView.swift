//
//  songOverlayView.swift
//  events
//
//  Created by Rhian Chavez on 7/28/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

protocol addSongDelegate {
    func addSong(songIndex: Int)
}

class songOverlayView: UIView, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, tapped{

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var delegate: addSongDelegate?
    
    var Songs: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // initialization code
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SongTableViewCell", bundle: nil), forCellReuseIdentifier: "songCell")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as! SongTableViewCell
        cell.label.text = Songs[indexPath.row]
        cell.index = indexPath.row
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Songs.count
    }
    
    func wasTapped(songIndex: Int) {
        delegate?.addSong(songIndex: songIndex)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        wasTapped(songIndex: indexPath.row)
        print("recognized selection")
    }

}
