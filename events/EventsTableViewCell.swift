//
//  EventsTableViewCell.swift
//  events
//
//  Created by Rhian Chavez on 7/13/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class EventsTableViewCell: UITableViewCell {

    @IBOutlet weak var organizerPic: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var organizerName: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    
    var event: Event?
    // Need to first distinguish Event class properties, can then assign valus to cell's photos and labels (event class not yet defined)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
