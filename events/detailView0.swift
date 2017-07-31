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
    @IBOutlet weak var acceptButton: UIButton!
    
    
    var guests: [String:Int] = [:]
    var usersDic: [String: Bool] = [:]
    
    
    @IBAction func goingTap(_ sender: UIButton) {
    }
    
    @IBAction func notGoingTap(_ sender: UIButton) {
    }
    
    
    var event: Event?{
        didSet{
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
                
                // Zoom map to event location
                let region = MKCoordinateRegionMakeWithDistance(self.event!.coordinate, 1000, 1000)
                self.topMap.setRegion(region, animated: true)
                
                for guest in self.event!.guestlist {
                    print("guest: \(guest)")
                }
                self.guests = self.event!.guestlist
                
//                print("here \(self.guests)")
            }
             self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.guests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell") as! userTableViewCell
//        FirebaseDatabaseManager.shared.getSingleUser(id: self.guests[indexPath.row]) { (user: AppUser) in
//            cell.user = user
//        }
        //let user = self.guests[indexPath.row]
        
        
                // cell.label.text = user // TODO: FIX to user.name, get AppUser
        //        if usersDic[user]!{
        //
        //        }
        //        else{
        //
        //        }
        return cell
    }
    
}
