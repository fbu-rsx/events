//
//  CreateEventViewController.swift
//  events
//
//  Created by Skyler Ruesga on 7/12/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import MapKit

protocol CreateEventViewControllerDelegate {
    func createEventViewController(controller: CreateEventViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String)
}


class CreateEventViewController: UIViewController {
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var zoomButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    
    var delegate: CreateEventViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [addButton, zoomButton]

    }

    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func onAdd(_ sender: AnyObject) {
        let coordinate = mapView.centerCoordinate
        // 805 meters = half a mile
        let radius = 100.00
        let identifier = NSUUID().uuidString
        delegate?.createEventViewController(controller: self, didAddCoordinate: coordinate, radius: radius, identifier: identifier)
    }
    
    @IBAction func onZoomToCurrentLocation(_ sender: AnyObject) {
//        mapView.zoomToUserLocation()
        guard let coordinate = mapView.userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 10000, 10000)
        mapView.setRegion(region, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
