//
//  SongTableViewCell.swift
//  events
//
//  Created by Rhian Chavez on 7/28/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

protocol tapped {
    func wasTapped(songIndex: Int)
}

class SongTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var songName: UILabel!
    
    var index: Int?
    var delegate: tapped?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        songName.textColor = Colors.coral
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /*
    @IBAction func tapped(_ sender: UITapGestureRecognizer) {
        delegate?.wasTapped(songIndex: index!)
    }*/
    
}
