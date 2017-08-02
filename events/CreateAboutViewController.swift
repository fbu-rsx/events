//
//  CreateEventMiscellaneousViewController.swift
//  events
//
//  Created by Xiu Chen on 7/17/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import AlamofireImage
import GoogleMaps
import AlamofireImage

class CreateAboutViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    var guests: [String] = []
    
    @IBOutlet weak var costPerPersonText: UILabel!
    @IBOutlet weak var totalCostText: UITextField!
    @IBOutlet weak var aboutText: UITextField!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var sendInvitesButton: UIButton!
     weak var dollarSignLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var gMapView: GMSMapView!
    @IBOutlet weak var leftArrowButton: UIButton!
    
    var gMarker: GMSMarker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Event Title Label
        eventTitleLabel.textColor = UIColor(hexString: "#FEB2A4")
        eventTitleLabel.text = CreateEventMaster.shared.event[EventKey.name] as? String
        // Event Time Label
        eventTimeLabel.textColor = UIColor(hexString: "#484848")
        // Total Cost Text Field
        totalCostText.textColor = UIColor(hexString: "#4CB6BE")
        totalCostText.setBottomBorder()
        // Cost Per Person Label
        costPerPersonText.textColor = UIColor(hexString: "#4CB6BE")
        // Notes about Event Text Field
        aboutText.textColor = UIColor(hexString: "#4CB6BE")
        aboutText.setBottomBorder()
        // Send Invites Button
        sendInvitesButton.layer.cornerRadius = 5
        sendInvitesButton.backgroundColor = UIColor(hexString: "#FEB2A4")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let photoURLString = AppUser.current.photoURLString
        let photoURL = URL(string: photoURLString)
        userImage.af_setImage(withURL: photoURL!)
        
        setupMap()

        // Show tab bar controller
        self.tabBarController?.tabBar.isHidden = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        eventTitleLabel.text = CreateEventMaster.shared.event[EventKey.name] as? String
        
        let datetime = CreateEventMaster.shared.event[EventKey.date] as! String
        let dateConverter = DateFormatter()
        dateConverter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        let date = dateConverter.date(from: datetime)!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        eventTimeLabel.text = dateFormatter.string(from: date)
        
        // Set guest list array
        self.guests = Array(CreateEventMaster.shared.guestlist.keys)
        self.collectionView.reloadData()
        
        
        //update marker  if necessary
        let location = CreateEventMaster.shared.event[EventKey.location] as! [Double]
        let coordinate = CLLocationCoordinate2D(latitude: location[0], longitude: location[1])
        gMarker.position = coordinate
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude,
                                              longitude: coordinate.longitude,
                                              zoom: Utilities.zoomLevel)
        gMapView.animate(to: camera)
        
        leftArrowButton.isEnabled = true
    }
    
    
    @IBAction func didTapToDismiss(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    
    func setupMap() {
        let location = CreateEventMaster.shared.event[EventKey.location] as! [Double]
        let coordinate = CLLocationCoordinate2D(latitude: location[0], longitude: location[1])
        Utilities.setupGoogleMap(gMapView)
        gMapView.isUserInteractionEnabled = false
        
        gMarker = GMSMarker()
        gMarker.map = gMapView
        gMarker.isDraggable = false
        
        gMapView.isHidden = false
    }
    
    @IBAction func calculateCostPerPerson(_ sender: Any) {
        let totalCost = Double(totalCostText.text!) ?? 0
        let totalAttendees = Double(self.guests.count + 1)
        let costPerPerson = totalCost / totalAttendees
        costPerPersonText.text = String(format: "$%.2f", costPerPerson)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.guests.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "invitedCell", for: indexPath) as! InvitedCollectionViewCell
        let id = self.guests[indexPath.row]
        var friend: FacebookFriend!
        for f in AppUser.current.facebookFriends {
            if f.id == id {
                friend = f
                break
            }
        }
        cell.invitedImage.af_setImage(withURL: friend.photo)
        cell.invitedImage.layer.cornerRadius = 0.5*cell.invitedImage.frame.width
        cell.invitedImage.layer.masksToBounds = true
        return cell
    }
    
    @IBAction func onCreate(_ sender: Any) {
        CreateEventMaster.shared.event[EventKey.cost] = Double(totalCostText.text ?? "")
        CreateEventMaster.shared.event[EventKey.about] = aboutText.text
        CreateEventMaster.shared.event[EventKey.guestlist] = CreateEventMaster.shared.guestlist
        let name = CreateEventMaster.shared.event[EventKey.name]
        OAuthSwiftManager.shared.createPlaylist(name: name as! String, completion: {id in
            CreateEventMaster.shared.event[EventKey.spotifyID] = id
            CreateEventMaster.shared.event[EventKey.playlistCreatorID] = UserDefaults.standard.value(forKey: "spotify-user") as! String
            let event = CreateEventMaster.shared.createNewEvent()
            NotificationCenter.default.post(name: BashNotifications.refresh, object: event)
            self.tabBarController?.selectedIndex = 0
        })
    }

    
    @IBAction func hitLeftArror(_ sender: Any) {
        leftArrowButton.isEnabled = false
        NotificationCenter.default.post(name: BashNotifications.swipeLeft, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
