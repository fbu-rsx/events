//
//  ViewController.swift
//  events
//
//  Created by Skyler Ruesga on 7/10/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import OAuthSwift
import FBSDKLoginKit
import AlamofireImage
import UserNotifications
import GoogleMaps
import GooglePlaces

struct Colors {
    static let coral = UIColor(hexString: "#EF5B5B")
    static let lightBlue = UIColor(hexString: "#B6E7EF")
    static let green = UIColor(hexString: "#4CB6BE")
    static let orange = UIColor(hexString: "#FF9D00")
}

protocol HandleMapSearch: class {
    func dropPinZoomIn(placemark:MKPlacemark)
}

protocol LoadEventsDelegate: class {
    func fetchEvents(completion: @escaping () -> Void)
}

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var currentLocation: CLLocation?
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    // Search Variable Instantiations
    var resultSearchController: UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    var lastTimeStamp = Date()
    
    
    // Creates an instance of Core Location class
    var locationManager = CLLocationManager()
    var events: [Event] = []
    
    var delegate: LoadEventsDelegate!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = true
        
        placesClient = GMSPlacesClient.shared()
        
//        mapView.delegate = self
//        mapView.showsUserLocation = true
//        mapView.setUserTrackingMode(.follow, animated: true)
        
//        // SEARCH
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
//        locationSearchTable.mapView = mapView
//        locationSearchTable.handleMapSearchDelegate = self
        
        // Programatically embedding the search bar in Navigation Controller
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search"
        navigationItem.titleView = resultSearchController?.searchBar
        // NavBar does not disappear when search results are shown
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        // When search bar is selected, modal overlay has a semi-transparent overlay
        resultSearchController?.dimsBackgroundDuringPresentation = true
        // Limit the overlap area just to View Controller, not blocking the Navigation bar
        definesPresentationContext = true
        
        // Ask for Authorization from the User
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            mapView.settings.myLocationButton = false
            mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            mapView.isMyLocationEnabled = true
            mapView.isHidden = true
            mapView.mapType = .normal
            do {
                // Set the map style by passing the URL of the local file.
                if let styleURL = Bundle.main.url(forResource: "paper", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find style.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }

        }
        
        self.delegate = AppUser.current
        delegate.fetchEvents() {
//            self.loadAllEvents()
            print("MapViewController Events: \(self.events)")
        }
        CreateEventMaster.shared.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(MapViewController.inviteAdded(_:)), name: BashNotifications.invite, object: nil)
        
        // Automatically zooms to the user's location upon VC loading
        //        guard let coordinate = self.mapView.userLocation.location?.coordinate else { return }
        //        let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
        //        self.mapView.setRegion(region, animated: true)
    }
    
    func inviteAdded(_ notification: NSNotification) {
        let event = notification.object as! Event
        self.add(event: event)
        print("invited added")
        print("Invite events: \(self.events)")
        
        // Pop-Up alert when others first invite you to an event
        
        let alertController = UIAlertController(title: "You've Been Invited!", message: "\(event.eventname)", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Show More Details", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.tabBarController?.selectedIndex = 2
        })
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
    @IBAction func onZoomtoCurrent(_ sender: Any) {
//        mapView.zoomToUserLocation()
    }
    
    
    // MARK: Add an event to the mapView
    func add(event: Event) {
        self.events.append(event)
//        mapView.addAnnotation(event)
        addRadiusOverlay(forEvent: event)
    }
    
    func remove(event: Event) {
        if let indexInArray = events.index(of: event) {
            events.remove(at: indexInArray)
        }
//        mapView.removeAnnotation(event)
        removeRadiusOverlay(forEvent: event)
    }
    
    // MARK: Map overlay functions
    func addRadiusOverlay(forEvent event: Event) {
//        mapView.add(MKCircle(center: event.coordinate, radius: event.radius))
    }
    
    func removeRadiusOverlay(forEvent event: Event) {
        // Find exactly one overlay which has the same coordinates & radius to remove
//        for overlay in mapView.overlays {
//            guard let circleOverlay = overlay as? MKCircle else { continue }
//            let coord = circleOverlay.coordinate
//            if coord.latitude == event.coordinate.latitude && coord.longitude == event.coordinate.longitude && circleOverlay.radius == event.radius {
//                mapView.remove(circleOverlay)
//                break
//            }
//        }
    }
    
    func loadAllEvents() {
        for event in AppUser.current.events {
            add(event: event)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myEvent"
        if let event = annotation as? Event {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                let data = try! Data(contentsOf: event.organizerURL)
                let image = UIImage(data: data)!
                annotationView?.image =  image.af_imageRoundedIntoCircle()
                annotationView?.canShowCallout = true
                let frame = annotationView!.frame
                annotationView?.frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: 35.0, height: 35.0)
                // Check button on annotation callout
                let checkInButton = UIButton(type: .custom)
                checkInButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                checkInButton.setImage(UIImage(named: "CheckInEvent")!, for: .normal)
                // Remove button on annotation callout
                let removeButton = UIButton(type: .custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(UIImage(named: "DeleteEvent")!, for: .normal)
                if event.organizerID == AppUser.current.uid {
                    annotationView?.leftCalloutAccessoryView = removeButton
                } else {
                    annotationView?.rightCalloutAccessoryView = checkInButton
                }
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        var event: Event!
        for e in events {
            if e.coordinate.latitude == overlay.coordinate.latitude &&
                e.coordinate.longitude == overlay.coordinate.longitude {
                event = e
                break
            }
        }
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.5
            let color: UIColor!
            switch event.myStatus {
            case .accepted:
                color = Colors.green
            case .declined:
                color = Colors.coral
            default:
                color = Colors.orange
            }
            circleRenderer.strokeColor = color
            circleRenderer.fillColor = color.withAlphaComponent(0.3)
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Delete event
        let event = view.annotation as! Event
        if control == view.leftCalloutAccessoryView {
            remove(event: event)
            NotificationCenter.default.post(name: BashNotifications.delete, object: event)
        } else {
            NotificationCenter.default.post(name: BashNotifications.accept, object: event)
        }
    }
}


extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        updateGoogleMaps(location)
        guard location.timestamp.timeIntervalSince(self.lastTimeStamp) > 3 else { return }
        self.lastTimeStamp = location.timestamp
        guard AppUser.current.events.count > 0 else { return }
        var closest: Event!
        var closestDistance = DBL_MAX
        for event in AppUser.current.events {
            let coordinate = CLLocation(latitude: event.coordinate.latitude, longitude: event.coordinate.longitude)
            let dist = location.distance(from: coordinate)
            if dist < closestDistance {
                closestDistance = dist
                closest = event
            }
        }
        print(closestDistance)
        if closestDistance <= 50.0 {
            handleEvent(closest)
        }
    }
    
    func updateGoogleMaps(_ location: CLLocation) {
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
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


extension MapViewController: CreateEventMasterDelegate {
    func createNewEvent(_ dict: [String: Any]) {
        print("CREATING NEW EVENT")
        let event = AppUser.current.createEvent(dict)
        add(event: event)
        print("new event added")
        CreateEventMaster.shared.clear()
    }
}

// SEARCH extension
extension MapViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark) {
        // cache the pin
        selectedPin = placemark
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = "\(city), \(state)"
        }
        // Custom pin view
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "placeholder")
        annotationView.image = UIImage(named: "placeholder.png")
//        mapView.addAnnotation(annotationView.annotation!)
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
//        mapView.setRegion(region, animated: true)
    }
}
