//
//  SearchEventsTableViewCell.swift
//  events
//
//  Created by Skyler Ruesga on 8/1/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class SearchEventsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var event: Event! {
        didSet {
            nameLabel.text = event.eventname + " by " + event.organizer.name
            descriptionLabel.text = event.about
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}
