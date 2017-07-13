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

struct PreferencesKeys {
    static let savedItems = "savedItems"
}

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
//    @IBAction func didHitLogOut(_ sender: Any) {
//        FirebaseAuthManager.shared.signOut()
//    }
    
    var geoNotifications: [GeoNotification] = []
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set locationManager to view controller to receive delegate calls
        locationManager.delegate = self
        
        // Prompts user for authorization to use location services
        locationManager.requestAlwaysAuthorization()
        
        // Deserializes the list of geotifications from User Defaults to local array
        loadAllGeoNotifications()
    }
    
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "addGeoNotification" {
                let navigationController = segue.destination as! UINavigationController
                let vc = navigationController.viewControllers.first as! CreateEventViewController
                vc.delegate = self
            }
        }
    
    // MARK: Representation of geofence as a CLCircularRegion
    func region(withGeotification geotification: GeoNotification) -> CLCircularRegion {
        let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
        region.notifyOnEntry = true
        //region.notifyOnExit = !region.notifyOnEntry
        return region
    }
    
    // MARK: Start monitoring notification upon addition
    func startMonitoring(geotification: GeoNotification) {
        // 1: Checks if device has the necessary hardware for geomonitering, else quit
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
            return
        }
        // 2: Ensure that authorization access has been granted
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            showAlert(withTitle:"Warning", message: "Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.")
        }
        // 3: Creates a CLCircularRegion region
        let region = self.region(withGeotification: geotification)
        // 4: Registers the CLCircularRegion region with iOS Core Location
        locationManager.startMonitoring(for: region)
    }
    
    // MARK: Stop monitoring notification upon removal by user
    func stopMonitoring(geotification: GeoNotification) {
        
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification.identifier else { continue }
            locationManager.stopMonitoring(for: circularRegion)
        }
    }
  
    // MARK: Loading and saving functions
    func loadAllGeoNotifications() {
        geoNotifications = []
        guard let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedItems) else { return }
        for savedItem in savedItems {
            guard let geoNotification = NSKeyedUnarchiver.unarchiveObject(with: savedItem as! Data) as? GeoNotification else { continue }
            add(geoNotification: geoNotification)
        }
    }
    
    func saveAllGeoNotifications() {
        var items: [Data] = []
        for geoNotification in geoNotifications {
            let item = NSKeyedArchiver.archivedData(withRootObject: geoNotification)
            items.append(item)
        }
        UserDefaults.standard.set(items, forKey: PreferencesKeys.savedItems)
    }
    
    // MARK: Functions that update the model/associated views with geotification changes
    func add(geoNotification: GeoNotification) {
        geoNotifications.append(geoNotification)
        mapView.addAnnotation(geoNotification)
        addRadiusOverlay(forGeoNotification: geoNotification)
        updateGeoNotificationsCount()
    }
    
    func remove(geoNotification: GeoNotification) {
        if let indexInArray = geoNotifications.index(of: geoNotification) {
            geoNotifications.remove(at: indexInArray)
        }
        mapView.removeAnnotation(geoNotification)
        removeRadiusOverlay(forGeoNotification: geoNotification)
        updateGeoNotificationsCount()
    }
    
    func updateGeoNotificationsCount() {
        title = "Local Events (\(geoNotifications.count))"
        navigationItem.rightBarButtonItem?.isEnabled = (geoNotifications.count < 20)
    }

    // MARK: Map overlay functions
    func addRadiusOverlay(forGeoNotification geoNotification: GeoNotification) {
        mapView?.add(MKCircle(center: geoNotification.coordinate, radius: geoNotification.radius))
        print("here adding radius")
    }
    
    func removeRadiusOverlay(forGeoNotification geoNotification: GeoNotification) {
        // Find exactly one overlay which has the same coordinates & radius to remove
        guard let overlays = mapView?.overlays else { return }
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            let coord = circleOverlay.coordinate
            if coord.latitude == geoNotification.coordinate.latitude && coord.longitude == geoNotification.coordinate.longitude && circleOverlay.radius == geoNotification.radius {
                mapView?.remove(circleOverlay)
                break
            }
        }
    }
    
    // MARK: Other mapview functions
    @IBAction func zoomToCurrentLocation(sender: AnyObject) {
        mapView.zoomToUserLocation()
    }
}

// MARK: AddGeotificationViewControllerDelegate
extension MapViewController: CreateEventViewControllerDelegate {
    
    func createEventViewController(controller: CreateEventViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String) {
        controller.dismiss(animated: true, completion: nil)
        // 1: Ensrue that the radius is clamped to the max value of view possible
        let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
        let geoNotification = GeoNotification(coordinate: coordinate, radius: radius, identifier: identifier)
        add(geoNotification: geoNotification)
        // 2: Ensure that the newly created geotification is registered with CoreLocation
        startMonitoring(geotification: geoNotification)
        saveAllGeoNotifications()
    }
}

// MARK: - Location Manager Delegate
//
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        mapView.showsUserLocation = (status == .authorizedAlways)
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
}

// MARK: - MapView Delegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myGeotification"
        if annotation is GeoNotification {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true
                let removeButton = UIButton(type: .custom)
                removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
                removeButton.setImage(UIImage(named: "DeleteGeotification")!, for: .normal)
                annotationView?.leftCalloutAccessoryView = removeButton
            } else {
                annotationView?.annotation = annotation
            }
            return annotationView
        }
        return nil
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = .purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            print("drawing circle")
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // Delete geotification
        let geotification = view.annotation as! GeoNotification
        stopMonitoring(geotification: geotification)
        remove(geoNotification: geotification)
        saveAllGeoNotifications()
    }
    
}



    
    
    
    

