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
    
    @IBOutlet weak var totalCostText: UITextField!
    @IBOutlet weak var aboutText: UITextView!
    @IBOutlet weak var eventTitleLabel: UILabel!
    @IBOutlet weak var eventTimeLabel: UILabel!
    @IBOutlet weak var sendInvitesButton: UIButton!
     weak var dollarSignLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var gMapView: GMSMapView!
    @IBOutlet weak var leftArrowButton: UIButton!
    @IBOutlet weak var invitationsLabel: UILabel!
    
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
        // Send Invites Button
        sendInvitesButton.layer.cornerRadius = 5
        sendInvitesButton.backgroundColor = UIColor(hexString: "#FEB2A4")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let photoURLString = AppUser.current.photoURLString
        let photoURL = URL(string: photoURLString)
        userImage.af_setImage(withURL: photoURL!)
        userImage.layer.cornerRadius = 0.5*userImage.frame.width
        userImage.layer.masksToBounds = true
        
        aboutText.delegate = self
        aboutText.text = "enter description of event 💬📝"
        aboutText.textColor = .lightGray
        
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
        
        // Hide "invitations" text if no guest selected
        if self.guests.count == 0 {
            invitationsLabel.isHidden = true
        } else {
            invitationsLabel.isHidden = false
        }
        
        //update marker  if necessary
        let location = CreateEventMaster.shared.event[EventKey.location] as! [Double]
        let coordinate = CLLocationCoordinate2D(latitude: location[0], longitude: location[1])
        gMarker.position = coordinate
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude,
                                              longitude: coordinate.longitude,
                                              zoom: Utilities.zoomLevel)
        gMapView.animate(to: camera)
   
        
        leftArrowButton.isUserInteractionEnabled = true
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
            let event = CreateEventMaster.shared.createNewEvent() //adds to appuser and firebase, calls AppUser.current.createEvent
            NotificationCenter.default.post(name: BashNotifications.reload, object: event)
            self.tabBarController?.selectedIndex = 0
        })
    }

    
    @IBAction func hitLeftArror(_ sender: Any) {
        leftArrowButton.isUserInteractionEnabled = false
        NotificationCenter.default.post(name: BashNotifications.swipeLeft, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension CreateAboutViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if (textView.text == "enter description of event 💬📝")
        {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder() //Optional
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if (textView.text == "")
        {
            textView.text = "description of event"
            textView.textColor = .lightGray
        }
        textView.resignFirstResponder()
    }
}
