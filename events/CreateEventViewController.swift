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
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var zoomButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var saveButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Background color
        self.view.backgroundColor = UIColor(hexString: "#f1c40f")
        // DISPLAY: Rounded buttons
        saveButton.layer.cornerRadius = 5
        saveButton.layer.borderWidth = 1
        saveButton.layer.borderColor = UIColor.white.cgColor
        saveButton.clipsToBounds = true
        
        self.mapView.showsUserLocation = true
        // Tracks the user's location
        self.mapView.setUserTrackingMode(.follow, animated: true)
        
        
        guard let coordinate = self.mapView.userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
        self.mapView.setRegion(region, animated: true)
        
        // Hide navigation bar
        navigationController?.setNavigationBarHidden(true, animated: true)
    }

    @IBAction func onBack(_ sender: Any) {
        performSegue(withIdentifier: "CreateEventTitleViewController", sender: nil)
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
        
    @IBAction func onZoomToCurrentLocation(_ sender: AnyObject) {
//        mapView.zoomToUserLocation()
        guard let coordinate = mapView.userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 100, 100)
        mapView.setRegion(region, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showGuestList" {
            CreateEventMaster.shared.event["location"] = [mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude]
        }
    }

}

