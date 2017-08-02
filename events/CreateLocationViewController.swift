//
//  CreateEventViewController.swift
//  events
//
//  Created by Skyler Ruesga on 7/12/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class CreateLocationViewController: UIViewController, UISearchControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var zoomToCurrentLocation: UIButton!
    @IBOutlet weak var leftArrowButton: UIButton!
    @IBOutlet weak var rightArrowButton: UIButton!
    
    // Search Variable Instantiations
    var searchController: UISearchController!
    var locationManager = CLLocationManager()
    var marker: GMSMarker!
    var placesClient: GMSPlacesClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        placesClient = GMSPlacesClient.shared()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        self.navigationItem.titleView = searchController.searchBar
        self.definesPresentationContext = true
        
        Utilities.setupGoogleMap(self.mapView)
        guard let coordinate = locationManager.location?.coordinate else { mapView.isHidden = false; return }
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude,
                                              longitude: coordinate.longitude,
                                              zoom: Utilities.zoomLevel)
        mapView.camera = camera
        marker = GMSMarker(position: coordinate)
        marker.isDraggable = true
        marker.map = mapView
        mapView.isHidden = false
        CreateEventMaster.shared.event[EventKey.location] = [coordinate.latitude, coordinate.longitude]
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        leftArrowButton.isEnabled = true
        rightArrowButton.isEnabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CreateEventMaster.shared.event[EventKey.location] = [marker.position.latitude, marker.position.longitude]
    }
    
    @IBAction func onZoomToCurrentLocation(_ sender: Any) {
        guard let coordinate = locationManager.location?.coordinate else { return }
        mapView.animate(toLocation: coordinate)
        mapView.animate(toZoom: Utilities.zoomLevel)
    }
    
    @IBAction func hitLeftArror(_ sender: Any) {
        leftArrowButton.isEnabled = false
        NotificationCenter.default.post(name: BashNotifications.swipeLeft, object: nil)
    }

    @IBAction func hitRightArrow(_ sender: Any) {
        rightArrowButton.isEnabled = false
        NotificationCenter.default.post(name: BashNotifications.swipeRight, object: nil)
    }
    
}

extension CreateLocationViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}





