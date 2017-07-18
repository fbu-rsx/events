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
import FirebaseAuthUI

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    // Creates an instance of Core Location class
    let locationManager = CLLocationManager()
    var geotifications = [Geotification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        // Displays user's current location
        self.mapView.showsUserLocation = true
        // Allows user's location tracking
        self.mapView.setUserTrackingMode(.follow, animated: true)
        
        // Automatically zooms to the user's location upon VC loading
        guard let coordinate = self.mapView.userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
        self.mapView.setRegion(region, animated: true)
        
        //        locationManager.delegate = self
        //        // Sets the desired accuracy to the most precise data possible
        //        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //        // Always request the user for permission to track locations
        //        locationManager.requestWhenInUseAuthorization()
        //        // Calls the locationManager didUpdateLocations function
        //        locationManager.startUpdatingLocation()
        
        
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
//        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            loadAllGeotifications()
        }
        
//        geotifications = eventsToGeotifications(AppUser.current.events)
    }
    
    
    @IBAction func onZoomtoCurrent(_ sender: Any) {
        mapView.zoomToUserLocation()
    }
    
    
    @IBAction func onLogout(_ sender: Any) {
        FirebaseDatabaseManager.shared.logout()
        let authViewController = AppDelegate.aUI!.authViewController()
        self.present(authViewController, animated: true, completion: nil)
    }
    
    @IBAction func testTransition(_ sender: Any) {
        performSegue(withIdentifier: "test", sender: nil)
    }
    
    
    func region(withGeotification geotification: Geotification) -> CLCircularRegion {
        // 1
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        // 2
        region.notifyOnEntry = (geotification.eventType == .onEntry)
        region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    func startMonitoring(geotification: Geotification) {
        // 1
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        // 2
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            showAlert(withTitle:"Warning", message: "Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.")
        }
        // 3
        let region = self.region(withGeotification: geotification)
        // 4
        locationManager.startMonitoring(for: region)
    }
    
    
    func stopMonitoring(geotification: Geotification) {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
    
    func loadAllGeotifications() {
        
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        self.mapView.showsUserLocation = (status == .authorizedAlways)
//    }
    
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
        
    }
}

