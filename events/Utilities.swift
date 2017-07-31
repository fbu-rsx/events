//
//  Utilities.swift
//  events
//
//  Created by Xiu Chen on 7/13/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//
import UIKit
import GoogleMaps

// MAPS: Helper Extensions
extension UIViewController {
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

class Utilities {
    
    static var zoomLevel: Float = 15.0
    
    static func setupGoogleMap(_ mapView: GMSMapView) {
        mapView.isHidden = true
        mapView.settings.myLocationButton = false
        mapView.isMyLocationEnabled = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.mapType = .normal
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "paper", withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }

        
    }
}
