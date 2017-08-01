//
//  ViewController.swift
//  events
//
//  Created by Skyler Ruesga on 7/10/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import CoreLocation
import OAuthSwift
import FBSDKLoginKit
import AlamofireImage
import UserNotifications
import GoogleMaps
import SCLAlertView

struct Colors {
    static let coral = UIColor(hexString: "#EF5B5B")
    static let lightBlue = UIColor(hexString: "#B6E7EF")
    static let green = UIColor(hexString: "#4CB6BE")
    static let orange = UIColor(hexString: "#FF9D00")
    static let greenAccepted =  UIColor(hexString: "4ADB75")
    static let pendingBlue = UIColor(hexString: "#76E5FC")
    static let redDeclined = UIColor(hexString: "#F46E79")
}


class MapViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    let spotifyAlert = UIAlertController(title: "Spotify Login", message:  "Please login to Spotify", preferredStyle: .alert)
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { action in
        // ...
    }
    
    let OKAction = UIAlertAction(title: "OK", style: .default) { action in
        // ...
        OAuthSwiftManager.shared.spotifyLogin(success: {}, failure: {_ in })
    }
    
    var currentLocation: CLLocation!
    
    // Search Variable Instantiations
    var searchController: UISearchController!
    var lastTimeStamp = Date()
    
    
    // Creates an instance of Core Location class
    var locationManager = CLLocationManager()
    var events: [Event] = []
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 5
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        self.navigationItem.titleView = searchController.searchBar
        self.definesPresentationContext = true
        
        mapView.delegate = self
        // Ask for Authorization from the User
        if CLLocationManager.locationServicesEnabled() {
            print("updating")
            locationManager.startUpdatingLocation()
            Utilities.setupGoogleMap(self.mapView)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.inviteAdded(_:)), name: BashNotifications.invite, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.eventsLoaded(_:)), name: BashNotifications.eventsLoaded, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.refresh(_:)), name: BashNotifications.refresh, object: nil)
        
        spotifyAlert.addAction(cancelAction)
        spotifyAlert.addAction(OKAction)
        OAuthSwiftManager.shared.getSpotifyUserID()
    }
    
    func inviteAdded(_ notification: NSNotification) {
        let event = notification.object as! Event
        add(event: event)
        print("invited added")
        print("Invite events: \(self.events)")
        
        // Pop-Up alert when others first invite you to an event
        let alertView = SCLAlertView()
        alertView.addButton("Show More Details") {
            self.tabBarController?.selectedIndex = 2
        }
        alertView.showInfo("You've Been Invited!", subTitle: event.eventname)

//        let alertController = UIAlertController(title: "You've Been Invited!", message: "\(event.eventname)", preferredStyle: UIAlertControllerStyle.alert)
//        alertController.addAction(UIAlertAction(title: "Show More Details", style: UIAlertActionStyle.default) {
//            UIAlertAction in
//            self.tabBarController?.selectedIndex = 2
//        })
//        self.present(alertController, animated: true, completion: nil)
        
    }
    

    func eventsLoaded(_ notification: NSNotification) {
        self.loadAllEvents()
        print("MapViewController Events: \(self.events)")
    }
    
    func refresh(_ notification: NSNotification) {
        let event = notification.object as! Event
        add(event: event)
        print("new event added")
    }
    

    @IBAction func onZoomtoCurrent(_ sender: Any) {
        mapView.animate(toLocation: currentLocation.coordinate)
        mapView.animate(toZoom: Utilities.zoomLevel)
    }
    
    // MARK: Add an event to the mapView
    func add(event: Event) {
        self.events.append(event)
        //for google maps marker
        event.title = event.eventname
        event.snippet = event.about.isEmpty ? "No description." : event.about
        event.position = event.coordinate
        let data = try! Data(contentsOf: event.organizerURL)
        let image = UIImage(data: data)!.af_imageScaled(to: CGSize(width: 45.0, height: 45.0))
        event.icon = image.af_imageRoundedIntoCircle()
        event.groundAnchor = CGPoint(x: event.groundAnchor.x, y: event.groundAnchor.y / 2.0)
        //        mapView.addAnnotation(event)
        addCircle(forEvent: event)
        event.map = mapView
    }
    
    func remove(event: Event) {
        event.map = nil
        if let indexInArray = events.index(of: event) {
            events.remove(at: indexInArray)
        }
        //        mapView.removeAnnotation(event)
        event.circle?.map = nil
    }
    
    // MARK: Map overlay functions
    private func addCircle(forEvent event: Event) {
        let circle = GMSCircle(position: event.coordinate, radius: event.radius)
        circle.strokeWidth = 1.5
        let color: UIColor!
        switch event.myStatus {
        case .accepted:
            color = Colors.green
        case .declined:
            color = Colors.coral
        default:
            color = Colors.orange
        }
        circle.strokeColor = color
        circle.fillColor = color.withAlphaComponent(0.3)
        circle.map = mapView
        event.circle = circle
    }
    
    func loadAllEvents() {
        for event in AppUser.current.events {
            add(event: event)
        }
    }
}

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        self.tabBarController?.selectedIndex = 2
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        if let event = eventWithinCoordinate(coordinate) {

            showAlert(for: event)
        }
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        showAlert(for: marker as! Event)
    }

    func showAlert(for event: Event) {
        let alertView = SCLAlertView()
        if event.organizerID == AppUser.current.uid {
            alertView.addButton("Delete") {
                NotificationCenter.default.post(name: BashNotifications.delete, object: event)
                
            }
        } else {
            if event.myStatus == InviteStatus.noResponse {
                alertView.addButton("Accept") {
                    NotificationCenter.default.post(name: BashNotifications.accept, object: event)

                }
                alertView.addButton("Decline") {
                    print("Still need to add a decline notification")
                }
            }
        }
        alertView.showTitle(event.eventname, subTitle: event.getDateTimeString(), style: SCLAlertViewStyle.info, closeButtonTitle: "Not now", duration: 0, colorStyle: Colors.lightBlue.getUInt(), colorTextButton: UIColor.white.getUInt(), circleIconImage: nil, animationStyle: .topToBottom)
    }

    func eventWithinCoordinate(_ coordinate: CLLocationCoordinate2D) -> Event? {
        guard self.events.count > 0 else { return nil}
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        var closest: Event!
        var closestDist = Double.greatestFiniteMagnitude
        for event in self.events {
            let loc = CLLocation(latitude: event.coordinate.latitude, longitude: event.coordinate.longitude)
            let dist = location.distance(from: loc)
            if dist < closestDist {
                closestDist = dist
                closest = event
            }
        }
        if closestDist < 3 * closest.radius {
            return closest
        }
        return nil
    }
}


extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        //        print("New location: \(location)")
        updateGoogleMaps(location)
        currentLocation = location
        guard location.timestamp.timeIntervalSince(self.lastTimeStamp) > 3 else { return }
        self.lastTimeStamp = location.timestamp
        guard AppUser.current.events.count > 0 else { return }
        var closest: Event!
        var closestDistance = Double.greatestFiniteMagnitude
        for event in AppUser.current.events {
            let coordinate = CLLocation(latitude: event.coordinate.latitude, longitude: event.coordinate.longitude)
            let dist = location.distance(from: coordinate)
            if dist < closestDistance {
                closestDistance = dist
                closest = event
            }
        }
        if closestDistance <= closest.radius {
            handleEvent(closest)
        }
    }
    
    func updateGoogleMaps(_ location: CLLocation) {
        // print("Location: \(location)")
        guard mapView.isHidden else { return }
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: Utilities.zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }
    
    func handleEvent(_ event: Event) {
        switch UIApplication.shared.applicationState {
        case .active:
            let message = "Would you like to check in to \"\(event.eventname)\"?"
            self.showAlert(withTitle: "Check In", message: message)
        case .inactive: fallthrough
        case .background:
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "Check In", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: "You're near \(event.eventname)!", arguments: nil)
            content.sound = UNNotificationSound.default()
            content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber;
            content.categoryIdentifier = "com.sruesga.localNotification"
            let request = UNNotificationRequest.init(identifier: "invitation", content: content, trigger: nil)
            
            let center = UNUserNotificationCenter.current()
            center.add(request)
        }
    }
}

extension MapViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}
