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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH.mm"
        let currTime = Float(dateFormatter.string(from: Date()))!
        let theme = currTime >= 18.00 || currTime <= 6.00 ? "dark" : "paper"
        
        mapView.isHidden = true
        mapView.settings.myLocationButton = false
        mapView.isMyLocationEnabled = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.mapType = .normal
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: theme, withExtension: "json") {
                mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    
    static func getDateFromString(dateString: String) -> Date {
        let dateConverter = DateFormatter()
        dateConverter.dateFormat = "yyyy-MM-dd HH:mm:ss zzz"
        return dateConverter.date(from: dateString)!
    }
    
    static func getDateString(date: Date) -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd, yyyy"
        return dateFormatterPrint.string(from: date)
    }
    
    static func getTimeString(date: Date) -> String {
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "h:mm a"
        return dateFormatterPrint.string(from: date)
    }
    
    static func getDateTimeString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, h:mm a"
        return dateFormatter.string(from: date)
    }

}

extension UIColor {
    func getUInt() -> UInt{
        // read colors to CGFloats and convert and position to proper bit positions in UInt32
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            
            var colorAsUInt : UInt = 0
            
            colorAsUInt += UInt(red * 255.0) << 16 +
                UInt(green * 255.0) << 8 +
                UInt(blue * 255.0)
            return colorAsUInt
        }
        return 0
    }
}
