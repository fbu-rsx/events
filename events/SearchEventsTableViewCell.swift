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
    @IBOutlet weak var eventTime: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var event: Event! {
        didSet {
            nameLabel.text = event.eventname
            descriptionLabel.text = event.about
            eventTime.text = event.getDateStringOnly()
            let phototURL = URL(string: event.organizer.photoURLString)!
            profileImageView.af_setImage(withURL: phototURL)
            profileImageView.layer.cornerRadius = 0.5 * profileImageView.frame.width
            profileImageView.layer.masksToBounds = true
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
