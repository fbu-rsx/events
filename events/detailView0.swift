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
    
    
    var users: [String] = []
    var usersDic: [String: Bool] = [:]
    
    
    @IBAction func goingTap(_ sender: UIButton) {
    }
    
    @IBAction func notGoingTap(_ sender: UIButton) {
    }
    
    
    var event: Event?{
        didSet{
            print("entered")
            FirebaseDatabaseManager.shared.getSingleUser(id: (event?.organizerID)!) { (user: AppUser) in
                
                self.topMap.setCenter(self.event!.coordinate, animated: true)
                self.profileImage.layer.cornerRadius = 0.5*self.profileImage.frame.width
                self.profileImage.layer.masksToBounds = true
               
                // set orgainzer pic
                let url = URL(string: user.photoURLString)
                self.profileImage.af_setImage(withURL: url!)
                
                // set organizerlabel as well
                self.eventTitle.text = self.event!.title
                self.eventDescription.text = self.event!.about
            }
        }
    }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! userTableViewCell
        let user = users[indexPath.row]
        cell.label.text = user // TODO: FIX to user.name, get AppUser
        if usersDic[user]!{
        
        }
        else{
        
        }
        return cell
        }
        
}
