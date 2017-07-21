//
//  EventsTableViewCell.swift
//  events
//
//  Created by Rhian Chavez on 7/13/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import AlamofireImage

protocol toDetailProtocol: class {
    func onTapFunction(event: Event)
}

class EventsTableViewCell: UITableViewCell {

    @IBOutlet weak var organizerPic: UIImageView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var organizerName: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    
    weak var delegate: toDetailProtocol?
    
    /*
    var eventname: String
    var totalcost: Float? //optional because may just be a free event
    var date: Date
    var coordinate: CLLocationCoordinate2D
    var radius: Double = 100
    var organizerID: String //uid of the organizer
    var guestlist: [String: Bool] // true if guest attended
    var photos: [String: String]
    var about: String //description of event, the description variable as unfortunately taken by Objective C
     */
 
    var event: Event?{
        didSet{
            // make user object
            let user = FirebaseDatabaseManager.shared.getSingleUser(id: (event?.organizerID)!) 
            // set orgainzer pic
            let url = URL(string: user.photoURLString)
            organizerPic.af_setImage(withURL: url!)
            // set eventTitle
            eventTitle.text = event?.eventname
            // set organizerName
            organizerName.text = user.name
            // set eeventDescription
            eventDescription.text = event?.description
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
    
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        delegate?.onTapFunction(event: event!)
    }
}
