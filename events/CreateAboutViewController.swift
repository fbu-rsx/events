//
//  CreateEventMiscellaneousViewController.swift
//  events
//
//  Created by Xiu Chen on 7/17/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import MapKit

class CreateAboutViewController: UIViewController {
    var numberOfGuests = 0

    @IBOutlet weak var costPerPersonText: UILabel!
    @IBOutlet weak var totalCostText: UITextField!
    @IBOutlet weak var aboutText: UITextField!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var sendInvitesButton: UIButton!
    @IBOutlet weak var perPersonText: UILabel!
    @IBOutlet weak var dollarSignLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Event Title Label
        eventTitleLabel.textColor = UIColor(hexString: "#FEB2A4")
        eventTitleLabel.text = CreateEventMaster.shared.event[EventKey.name] as? String
        // Event Time Label
        eventTimeLabel.textColor = UIColor(hexString: "#484848")
        // Total Cost Text Field
        dollarSignLabel.textColor = UIColor(hexString: "#4CB6BE")
        totalCostText.textColor = UIColor(hexString: "#4CB6BE")
        totalCostText.setBottomBorder()
        // Cost Per Person Label
        costPerPersonText.textColor = UIColor(hexString: "#4CB6BE")
        perPersonText.textColor = UIColor(hexString: "#484848")
        // Notes about Event Text Field
        aboutText.textColor = UIColor(hexString: "#4CB6BE")
        aboutText.setBottomBorder()
        // Send Invites Button
        sendInvitesButton.layer.cornerRadius = 5
        sendInvitesButton.backgroundColor = UIColor(hexString: "#FEB2A4")
        // Hide tab bar controller
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func didTapToDismiss(_ sender: Any) {
          self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        numberOfGuests = CreateEventMaster.shared.guestlist.count
        let selected = CreateEventMaster.shared.event[EventKey.date] as! String
        let dateConverter = DateFormatter()
        dateConverter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let date = dateConverter.date(from: selected)!
            
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        eventTimeLabel.text = dateFormatter.string(from: date)

        // Show mapView with selected location
        let location = CreateEventMaster.shared.event[EventKey.location] as! [Double]
        let coordinate = CLLocationCoordinate2D(latitude: location[0], longitude: location[1])
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
        mapView.setRegion(region, animated: true)
        
    }
    
    @IBAction func calculateCostPerPerson(_ sender: Any) {
        let totalCost = Double(totalCostText.text!) ?? 0
        let totalAttendees = Double(numberOfGuests + 1)
        let costPerPerson = totalCost / totalAttendees
        costPerPersonText.text = String(format: "$%.2f", costPerPerson)
    }
    
    @IBAction func onCreate(_ sender: Any) {
        CreateEventMaster.shared.event[EventKey.cost] = Double(totalCostText.text ?? "")
        CreateEventMaster.shared.event[EventKey.about] = aboutText.text
        CreateEventMaster.shared.event[EventKey.guestlist] = CreateEventMaster.shared.guestlist
        let name = CreateEventMaster.shared.event[EventKey.name]
        OAuthSwiftManager.shared.createPlaylist(name: name as! String, completion: {id in
            CreateEventMaster.shared.event[EventKey.spotifyID] = id
            CreateEventMaster.shared.event[EventKey.playlistCreatorID] = UserDefaults.standard.value(forKey: "spotify-user") as! String
            CreateEventMaster.shared.delegate.createNewEvent(CreateEventMaster.shared.event)
            self.tabBarController?.selectedIndex = 0
            NotificationCenter.default.post(name: BashNotifications.refresh, object: nil)
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
