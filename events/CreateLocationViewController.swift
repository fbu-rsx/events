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
    @IBOutlet weak var searchBar: UISearchBar!
    
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
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CreateEventMaster.shared.event[EventKey.location] = [marker.position.latitude, marker.position.longitude]
    }
    
    @IBAction func onZoomToCurrentLocation(_ sender: Any) {
        let controller = GMSAutocompleteViewController()
        present(controller, animated: true, completion: nil)
//        guard let coordinate = locationManager.location?.coordinate else { return }
//        mapView.animate(toLocation: coordinate)
//        mapView.animate(toZoom: Utilities.zoomLevel)
    }
}

extension CreateLocationViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}





