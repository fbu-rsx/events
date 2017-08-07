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
        
        let bundle = Bundle(path: "events/SearchViewControllers")
        let searchResultController = SearchPlacesViewController(nibName: "SearchPlacesViewController", bundle: bundle)
        searchController = UISearchController(searchResultsController: searchResultController)
        searchResultController.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = true
        self.navigationItem.titleView = searchController.searchBar
        self.definesPresentationContext = true
        
        
        let searchTextField: UITextField? = searchController.searchBar.value(forKey: "searchField") as? UITextField
        searchTextField?.placeholder = "Search for a location"
        
        Utilities.setupGoogleMap(self.mapView)
        guard let coordinate = locationManager.location?.coordinate else { mapView.isHidden = false; return }
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude,
                                              longitude: coordinate.longitude,
                                              zoom: Utilities.zoomLevel)
        mapView.camera = camera
        marker = GMSMarker(position: coordinate)
        marker.title = "Select a location"
        marker.snippet = "Hold and drag me!"
        mapView.selectedMarker = marker
        marker.isDraggable = true
        marker.map = mapView
        mapView.isHidden = false
        mapView.selectedMarker = marker
        CreateEventMaster.shared.event[EventKey.location] = [coordinate.latitude, coordinate.longitude]
        self.tabBarController?.tabBar.isHidden = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(CreateLocationViewController.changedTheme(_:)), name: BashNotifications.changedTheme, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        leftArrowButton.isUserInteractionEnabled = true
        rightArrowButton.isUserInteractionEnabled = true
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
        leftArrowButton.isUserInteractionEnabled = false
        NotificationCenter.default.post(name: BashNotifications.swipeLeft, object: nil)
    }
    
    @IBAction func hitRightArrow(_ sender: Any) {
        rightArrowButton.isUserInteractionEnabled = false
        NotificationCenter.default.post(name: BashNotifications.swipeRight, object: nil)
    }
    
    func changedTheme(_ notification: NSNotification) {
        Utilities.changeTheme(forMap: self.mapView)
    }
    
}

extension CreateLocationViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text
        let resultsVC = searchController.searchResultsController as! SearchPlacesViewController
        placeAutocomplete(text: text!, vc: resultsVC)
    }
    
    
    func didDismissSearchController(_ searchController: UISearchController) {
        let resultsVC = searchController.searchResultsController! as! SearchPlacesViewController
        if let prediction = resultsVC.selectedPrediction {
            resultsVC.selectedPrediction = nil
            placesClient.lookUpPlaceID(prediction.placeID!, callback: { (place: GMSPlace?, error: Error?) in
                if let error = error {
                    print("Error finding place by place ID: \(error.localizedDescription)")
                    return
                }
                self.mapView.animate(toLocation: place!.coordinate)
                self.mapView.animate(toZoom: 17.0)
                self.marker.position = place!.coordinate
                self.marker.appearAnimation = .pop
                self.marker.title = place!.name
                self.marker.snippet = place!.formattedAddress
                self.mapView.selectedMarker = self.marker
            })
        }
    }
    
    func placeAutocomplete(text: String, vc: SearchPlacesViewController) {
        let visibleRegion = mapView.projection.visibleRegion()
        let bounds = GMSCoordinateBounds(coordinate: visibleRegion.farLeft, coordinate: visibleRegion.nearRight)
        
        let filter = GMSAutocompleteFilter()
        filter.type = .noFilter
        placesClient.autocompleteQuery(text, bounds: bounds, filter: filter, callback: {(results, error) -> Void in
            if let error = error {
                print("Autocomplete error \(error)")
                return
            }
            if let results = results {
                vc.predictions = results
                vc.tableView.reloadData()
            }
        })
    }
    
}





