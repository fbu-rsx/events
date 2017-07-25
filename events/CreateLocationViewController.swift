//
//  CreateEventViewController.swift
//  events
//
//  Created by Skyler Ruesga on 7/12/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class CreateLocationViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var zoomToCurrentLocation: UIButton!
    @IBOutlet weak var selectLocationButton: UIButton!
   
    // Search Variable Instantiations
    var resultSearchController: UISearchController? = nil
    var selectedPin:MKPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.showsUserLocation = true
        // Tracks the user's location
        self.mapView.setUserTrackingMode(.follow, animated: true)
        guard let coordinate = self.mapView.userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 1000, 1000)
        self.mapView.setRegion(region, animated: true)
    
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Select Location button styling
        selectLocationButton.layer.cornerRadius = 5
        selectLocationButton.backgroundColor = UIColor(hexString: "#C9C9C9")
        
        // SEARCH
        // Programmatically instantiating the locationSearchTable TableViewController
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
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

    }
    
    @IBAction func onSelected(_ sender: Any) {
        selectLocationButton.backgroundColor = UIColor(hexString: "#FEB2A4")
        CreateEventMaster.shared.event[EventKey.location.rawValue] = [mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude]
        CreateEventMaster.shared.event[EventKey.coordinate.rawValue] = mapView.centerCoordinate
    }
    
//    @IBAction func loadNextPage(_ sender: Any) {
//        let parentViewController = self.parent as! CreateEventPageController
//        parentViewController.setViewControllers([parentViewController.orderedViewControllers[2]],
//                                                direction: .forward,
//                                                animated: true,
//                                                completion: nil)
//        
//    }
//    
    
    @IBAction func onZoomToCurrentLocation(_ sender: Any) {
        guard let coordinate = mapView.userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegionMakeWithDistance(coordinate, 100, 100)
        mapView.setRegion(region, animated: true)
    }
}
    

    

// SEARCH extension
extension CreateLocationViewController: HandleMapSearch {
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
        mapView.addAnnotation(annotationView.annotation!)
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}


