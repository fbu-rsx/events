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
import CoreLocation
import OAuthSwift
import UserNotifications
import FBSDKCoreKit
import FBSDKLoginKit


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    //    static var aUI: FUIAuth?
    var locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.activityType = .fitness

        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        
        if Auth.auth().currentUser != nil && FBSDKAccessToken.current() != nil {
            AppUser.current = AppUser(user: Auth.auth().currentUser!)
        } else {
            let loginController = SignInViewController(nibName: "SignInViewController", bundle: nil)
            loginController.signInDelegate = self
            window?.rootViewController = loginController
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.logout), name: BashNotifications.logout, object: nil)

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        application.registerForRemoteNotifications()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        //OAuthSwiftManager.shared.logout()
        return true
    }
    
    func logout() {
        let loginController = SignInViewController(nibName: "SignInViewController", bundle: nil)
        loginController.signInDelegate = self
        window?.rootViewController = loginController
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Spotify OAuth Management
        
        OAuthSwift.handle(url: url)
        
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
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

extension AppDelegate: SignInDelegate {
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
        
        if FBSDKAccessToken.current() != nil {
            loginButton.isHidden = true
        } else {
            loginButton.isHidden = false
        }
        
        if let error = error {
            print(error.localizedDescription)
            return
        }
        if result.isCancelled {
            return
        }

        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)

        Auth.auth().signIn(with: credential) { (user: User?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            AppUser.current = AppUser(user: user!)
            print("Welcome \(user!.displayName!)! 😊")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            self.window?.rootViewController = storyboard.instantiateInitialViewController()!
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        let loginController = SignInViewController(nibName: "SignInViewController", bundle: nil)
        loginController.signInDelegate = self
        self.window?.rootViewController = loginController
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
//        print("you're in a region of an event")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region is CLCircularRegion {
            handleEvent(forRegion: region)
        }
//        print("exited event region")
    }
    // Helper functions
    func note(fromRegionIdentifier identifier: String) -> String {
        let savedItems = UserDefaults.standard.array(forKey: PreferenceKeys.savedItems) as! [Data]
        let events = savedItems.map { NSKeyedUnarchiver.unarchiveObject(with: $0 as Data) as! Event }
        let index = events.index { $0.eventid == identifier }
        return "Would you like to check in to \"\(events[index!].title!)\"?"
    }
    
    func handleEvent(forRegion region: CLRegion!) {
        // Show an alert if application is active
        if UIApplication.shared.applicationState == .active {
            let message = note(fromRegionIdentifier: region.identifier)
            window?.rootViewController?.showAlert(withTitle: nil, message: message)
        } else {
            // Otherwise present a local notification
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "You're near a location", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: note(fromRegionIdentifier: region.identifier), arguments: nil)
            content.sound = UNNotificationSound.default()
            content.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber;
            content.categoryIdentifier = "com.elonchan.localNotification"
            // Deliver the notification in five seconds.
            let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 60.0, repeats: true)
            let request = UNNotificationRequest.init(identifier: "FiveSecond", content: content, trigger: trigger)
            
            // Schedule the notification.
            let center = UNUserNotificationCenter.current()
            center.add(request)
        }
//        print("Geofence triggered!")
    }
}

