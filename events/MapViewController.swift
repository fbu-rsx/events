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
import Firebase

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    // Creates an instance of Core Location class
    let locationManager = CLLocationManager()
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Sets current location the first element of list of all locations
        let location = locations[0]
        // Initiates the span of the view
        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
        // Initiates the coordinates
        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
        // Sets the region to the span and coordinates
        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
        mapView.setRegion(region, animated: true)
        //   mapView.showsUserLocation = true
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        // Sets the desired accuracy to the most precise data possible
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Always request the user for permission to track locations
        locationManager.requestWhenInUseAuthorization()
        //mapView.showsUserLocation = true
        // Calls the locationManager didUpdateLocations function
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func onZoomtoCurrent(_ sender: Any) {
        mapView.zoomToUserLocation()
    }
    
    
    @IBAction func onLogout(_ sender: Any) {
        FirebaseAuthManager.shared.signOut()
    }
    
    
}

    
