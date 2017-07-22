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
import UserNotifications
import SimpleTab


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FUIAuthDelegate {

    var window: UIWindow?
    static var aUI: FUIAuth?
    let locationManager = CLLocationManager()
    // Instantiate TabBarController
    var simpleTBC: SimpleTabBarController?

  
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Calls function to instantiate tab bar controller
        setupSimpleTab()
        
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
    
    func setupSimpleTab() {
        // Sets rootViewController as a SimpleTabBarController
        simpleTBC = self.window!.rootViewController as? SimpleTabBarController
        
        //# Set the View Transition to Crossfade
        simpleTBC?.viewTransition = CrossFadeViewTransition()
        
        //# Set Tab Bar Style to Elegant tabbar style
        //let style: SimpleTabBarStyle = PopTabBarStyle(tabBar: simpleTBC!.tabBar)
        let style: SimpleTabBarStyle = ElegantTabBarStyle(tabBar: simpleTBC!.tabBar)
        
        //# Set Tab Title attributes for selected and unselected (normal) states.
        style.setTitleTextAttributes(attributes: [NSFontAttributeName as NSObject : UIFont.systemFont(ofSize: 14),  NSForegroundColorAttributeName as NSObject: UIColor.lightGray], forState: .normal)
        style.setTitleTextAttributes(attributes: [NSFontAttributeName as NSObject : UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName as NSObject: colorWithHexString("4CB6BE")], forState: .selected)
        
        //Set Tab Icon colors for selected and unselected (normal) states.
        style.setIconColor(color: UIColor.lightGray, forState: UIControlState.normal)
        style.setIconColor(color: colorWithHexString("4CB6BE"), forState: UIControlState.selected)
        
        // Set Tab Icons
        simpleTBC?.tabBar.items?[0].image = UIImage(named: "fireworks.png")?.withRenderingMode(.alwaysOriginal)
        simpleTBC?.tabBar.items?[1].image = UIImage(named: "map.png")?.withRenderingMode(.alwaysOriginal)
        simpleTBC?.tabBar.items?[2].image = UIImage(named: "monthly-calendar.png")?.withRenderingMode(.alwaysOriginal)

        // Let the tab bar control know of the style
        simpleTBC?.tabBarStyle = style
    }
    
    
    func colorWithHexString (_ hexStr:String) -> UIColor {
        let hex = hexStr.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.characters.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return .clear
        }
        return UIColor(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
        
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
//        if region is CLCircularRegion {
//            handleEvent(forRegion: region)
//        }
        print("you're in a region of an event")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
//        if region is CLCircularRegion {
//            handleEvent(forRegion: region)
//        }
        print("exited event region")
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

