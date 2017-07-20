//
//  AppDelegate.swift
//  events
//
//  Created by Skyler Ruesga on 7/10/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import Firebase
import Alamofire
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import CoreLocation
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FUIAuthDelegate {

    var window: UIWindow?
    static var aUI: FUIAuth?
    let locationManager = CLLocationManager() // Add this statement

  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        locationManager.delegate = self
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        
        AppDelegate.aUI = FUIAuth.defaultAuthUI()
        let authUI = AppDelegate.aUI
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
        authUI?.providers = providers

        
        if let user = Auth.auth().currentUser {
            AppUser.current = AppUser(user: user)
        }
        else{
            let authViewController = authUI!.authViewController()
            window?.rootViewController = authViewController
        }

        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
        UIApplication.shared.cancelAllLocalNotifications()
        
        return true
    }

    // FIREBASE
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else if let user = user {
            AppUser.current = AppUser(user: user)
            print("Welcome \(user.displayName!)! 😊")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "MapViewNavigationController")
            window?.rootViewController = controller
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        // Firebase OAuth Management
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        
        // Spotify OAuth Management
        if (url.host == "events://") {
            OAuthSwift.handle(url: url)
            return true
        }
        
        return false
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

extension AppDelegate: CLLocationManagerDelegate {
    
    //    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    //        self.mapView.showsUserLocation = (status == .authorizedAlways)
    //    }
    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        
//        // Sets current location the first element of list of all locations
//        let location = locations[0]
//        // Initiates the span of the view
//        let span: MKCoordinateSpan = MKCoordinateSpanMake(0.01, 0.01)
//        // Initiates the coordinates
//        let myLocation: CLLocationCoordinate2D = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)
//        // Sets the region to the span and coordinates
//        let region: MKCoordinateRegion = MKCoordinateRegionMake(myLocation, span)
//        mapView.setRegion(region, animated: true)
//        
//    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
    }
    // Helper functions
    func note(fromRegionIdentifier identifier: String) -> String? {
        let savedItems = UserDefaults.standard.array(forKey: PreferenceKeys.savedItems) as? [NSData]
        let events = savedItems?.map { NSKeyedUnarchiver.unarchiveObject(with: $0 as Data) as? Event }
        let index = events?.index { $0?.eventid == identifier }
        return index != nil ? events?[index!]?.about : nil
    }
    
    func handleEvent(forRegion region: CLRegion!) {
        // Show an alert if application is active
        if UIApplication.shared.applicationState == .active {
            guard let message = note(fromRegionIdentifier: region.identifier) else { return }
            window?.rootViewController?.showAlert(withTitle: nil, message: message)
        } else {
            // Otherwise present a local notification
            let notification = UILocalNotification()
            notification.alertBody = note(fromRegionIdentifier: region.identifier)
            notification.soundName = "Default"
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
        print("Geofence triggered!")
    }
}

