//
//  detailView0.swift
//  events
//
//  Created by Rhian Chavez on 7/24/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import MapKit

class detailView0: UIView, UITableViewDelegate, UITableViewDataSource {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var tableViewCell: UITableViewCell!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var eventDescription: UILabel!
    @IBOutlet weak var topMap: MKMapView!
    @IBOutlet weak var profileImage: UIImageView!
    
    
    var users: [String: Bool]?
    
    
    @IBAction func goingTap(_ sender: UIButton) {
    }
    
    @IBAction func notGoingTap(_ sender: UIButton) {
    }
    /*
    var event: Event?{
        didSet{
            topMap.setCenter(event!.coordinate, animated: true)
            profileImage.layer.cornerRadius = 0.5*profileImage.frame.width
            profileImage.layer.masksToBounds = true
            //centerImage.image = event?.organizerID
            let user = FirebaseDatabaseManager.shared.getSingleUser(id: (event?.organizerID)!)
            // set orgainzer pic
            let url = URL(string: user.photoURLString)
            profileImage.af_setImage(withURL: url!)
            // set organizerlabel as well
            eventTitle.text = event!.title
            
        }
    }*/
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableViewCell
    }
    
}
