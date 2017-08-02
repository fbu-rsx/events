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
        
        // Checking if time is between 20:00 and 3:00 (8 pm and 3 am)
        let now = Date()
        let eightPM = now.dateAt(hours: 20, minutes: 0)
        let threeAM = now.dateAt(hours: 3, minutes: 0)
        
        if now >= eightPM && now <= threeAM {
            do {
                // Set the map style by passing the URL of the local file.
                if let styleURL = Bundle.main.url(forResource: "day", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find style.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        } else {
            do {
                // Set the map style by passing the URL of the local file.
                if let styleURL = Bundle.main.url(forResource: "night", withExtension: "json") {
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    NSLog("Unable to find style.json")
                }
            } catch {
                NSLog("One or more of the map styles failed to load. \(error)")
            }
        }
        
        
      

        
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

extension Date
{
    
    func dateAt(hours: Int, minutes: Int) -> Date
    {
        let calendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
        
        //get the month/day/year componentsfor today's date.
        
        
        var date_components = calendar.components(
            [NSCalendar.Unit.year,
             NSCalendar.Unit.month,
             NSCalendar.Unit.day],
            from: self)
        
        //Create an NSDate for the specified time today.
        date_components.hour = hours
        date_components.minute = minutes
        date_components.second = 0
        
        let newDate = calendar.date(from: date_components)!
        return newDate
    }
}
