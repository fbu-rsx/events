//
//  CreateEventViewController.swift
//  events
//
//  Created by Skyler Ruesga on 7/12/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import MapKit



class CreateEventViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Background color
        self.view.backgroundColor = UIColor(hexString: "#f1c40f")
        
        self.mapView.showsUserLocation = true
        // Tracks the user's location
        self.mapView.setUserTrackingMode(.follow, animated: true)
        
        
        guard let coordinate = self.mapView.userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
        self.mapView.setRegion(region, animated: true)
        
        // Hide navigation bar
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

//        
//    @IBAction func onZoomToCurrentLocation(_ sender: AnyObject) {
////        mapView.zoomToUserLocation()
//        guard let coordinate = mapView.userLocation.location?.coordinate else { return }
//        let region = MKCoordinateRegionMakeWithDistance(coordinate, 100, 100)
//        mapView.setRegion(region, animated: true)
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapNext(_ sender: Any) {
        CreateEventMaster.shared.event[EventKey.location.rawValue] = [mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude]
        self.tabBarController?.selectedIndex = 2
    }
    
    @IBAction func didHitBackButton(_ sender: Any) {
        self.tabBarController?.selectedIndex = 0
        //        self.dismissDetail()
    }
}

