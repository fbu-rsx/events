//
//  ViewController.swift
//  events
//
//  Created by Skyler Ruesga on 7/10/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces

class MapViewController: UIViewController {
    
    @IBAction func didHitLogOut(_ sender: Any) {
        FirebaseAuthManager.shared.signOut()
    }
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    // The currently selected place.
    var selectedPlace: GMSPlace?
    
    // A default location to use when location permission is not granted.
    let defaultLocation = CLLocation(latitude: -33.869405, longitude: 151.199)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        //        let camera = GMSCameraPosition.camera(withLatitude: 37.48, longitude: -122.14, zoom: 6.0)
        //        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        //        view = mapView
        
        
        
        
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        
        placesClient = GMSPlacesClient.shared()
        
        // Create a map.
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        
        // Add the map to the view, hide it until we've got a location update.
        view.addSubview(mapView)
        mapView.isHidden = true
        
        // Creates a marker in the center of the map.
        // ************** Testing how markers are created ***********
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 37.790696, longitude: -122.405603)
        
        
        //        let ping0 = UIImage(named: "ping0")
        //        let ping1 = UIImage(named: "ping1")
        //        //let ping2 = UIImage(named: "ping0")
        //
        //        let pingArray = [ping0, ping1, ping0]
        //        marker.icon = UIImage.animatedImage(with: pingArray as! [UIImage], duration: 0.5)
        
        marker.title = "Dragon's Gate"
        marker.snippet = "SF, California"
        marker.icon = GMSMarker.markerImage(with: .blue)
        marker.map = mapView
        
        
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

