//
//  detailView0.swift
//  events
//
//  Created by Rhian Chavez on 7/24/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import AlamofireImage
import GoogleMaps

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
    @IBOutlet weak var topMap: GMSMapView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    
    var guests: [String] = []
    
    @IBAction func goingTap(_ sender: UIButton) {
    }
    
    @IBAction func notGoingTap(_ sender: UIButton) {
    }
    
    
    
    override func awakeFromNib() {
        // Initialization code
        self.tableView.dataSource = self
        self.tableView.delegate = self
        let bundle = Bundle(path: "/Users/xiuchen/Desktop/events/events/GuestsTableViewCell.swift")
        let nib1 = UINib(nibName: "GuestsTableViewCell", bundle: bundle)
        tableView.register(nib1, forCellReuseIdentifier: "userCell")
        
        // Setting invitiation button colors
        acceptButton.layer.cornerRadius = 5
        acceptButton.backgroundColor = UIColor(hexString: "#FEB2A4")
        declineButton.layer.cornerRadius = 5
        declineButton.backgroundColor = UIColor(hexString: "#FEB2A4")
    }

    var event: Event? {
        didSet {
            FirebaseDatabaseManager.shared.getSingleUser(id: (event?.organizerID)!) { (user: AppUser) in
                Utilities.setupGoogleMap(self.topMap)
                let camera = GMSCameraPosition.camera(withLatitude: self.event!.coordinate.latitude,
                                                      longitude: self.event!.coordinate.longitude,
                                                      zoom: Utilities.zoomLevel)
                self.topMap.camera = camera
                self.topMap.isUserInteractionEnabled = false
                
                let marker = GMSMarker()
                marker.position = self.event!.coordinate
                marker.map = self.topMap
                marker.isDraggable = false
                
                self.topMap.isHidden = false
                
                self.topMap.isHidden = false
                self.profileImage.layer.cornerRadius = 0.5*self.profileImage.frame.width
                self.profileImage.layer.masksToBounds = true
                
                // set orgainzer pic
                let url = URL(string: user.photoURLString)
                self.profileImage.af_setImage(withURL: url!)
                
                // set organizerlabel as well
                self.eventTitle.text = self.event!.title
                self.eventDescription.text = self.event!.about
                
                self.guests = Array(self.event!.guestlist.keys)
                self.tableView.reloadData()
                
                
                switch self.event!.myStatus {
                case .accepted:
                    self.acceptButton.setTitle("Accepted", for: .normal)
                    self.acceptButton.backgroundColor = UIColor(hexString: "#4ADB75")
                    self.acceptButton.isEnabled = false
                    self.acceptButton.sizeToFit()
                    self.declineButton.isEnabled = false
                    self.declineButton.backgroundColor = UIColor(hexString: "#95a5a6")
                    
                case .declined:
                    self.declineButton.setTitle("Declined", for: .normal)
                    self.declineButton.backgroundColor = UIColor(hexString: "#F46E79")
                    self.declineButton.isEnabled = false
                    self.declineButton.sizeToFit()
                    self.acceptButton.isEnabled = false
                    self.acceptButton.backgroundColor = UIColor(hexString: "#95a5a6")
                    
                default:
                    self.acceptButton.layer.cornerRadius = 5
                    self.acceptButton.backgroundColor = UIColor(hexString: "#FEB2A4")
                    self.declineButton.layer.cornerRadius = 5
                    self.declineButton.backgroundColor = UIColor(hexString: "#FEB2A4")
                }
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.guests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! GuestsTableViewCell
        FirebaseDatabaseManager.shared.getSingleUser(id: self.guests[indexPath.row]) { (user: AppUser) in
            cell.nameLabel.text = user.name
            let photoURLString = user.photoURLString
            let photoURL = URL(string: photoURLString)
            cell.guestImage.af_setImage(withURL: photoURL!)
            cell.guestImage.layer.cornerRadius = 0.5*cell.guestImage.frame.width
            cell.guestImage.layer.masksToBounds = true
        }
        return cell
    }
}
