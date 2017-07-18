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
    
/*    var eventid: String
 var eventname: String
 var totalcost: Double? //optional because may just be a free event
 var location: [Double]
 var organizerID: String //uid of the organizer
 var guestlist: [String: Bool]
 var photos: [String: String]
 var eventDictionary: [String: Any]*/
 
    var event: Event?{
        didSet{
            // set organizerPic
            eventTitle.text = event?.eventname
            // set organizerName
            // set eeventDescription
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
