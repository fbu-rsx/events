//
//  EventsTableViewCell.swift
//  events
//
//  Created by Rhian Chavez on 7/13/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import AlamofireImage
import FoldingCell

class EventsTableViewCell: FoldingCell {
    
    
    @IBOutlet weak var view1topConstraint: NSLayoutConstraint!
    @IBOutlet weak var view1: RotatedView!
    @IBOutlet weak var view2: RotatedView!
    @IBOutlet weak var view2topConstraint: NSLayoutConstraint!
    
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
            
        }
    }
    
    override func awakeFromNib() {
        // Initialization code
        foregroundView = view1
        foregroundViewTop = view1topConstraint
        containerView = view2
        containerViewTop = view2topConstraint
        itemCount = 3
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        
        // durations count equal it itemCount
        let durations = [0.33, 0.26, 0.26] // timing animation for each view
        return durations[itemIndex]
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
