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

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, FUIAuthDelegate {

    var window: UIWindow?
    
    let locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // MAPS: Sets location manager, enables notifications, clears notifications
        locationManager.delegate = (self as! CLLocationManagerDelegate)
        locationManager.requestAlwaysAuthorization()
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: nil))
        UIApplication.shared.cancelAllLocalNotifications()
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true

        
        let authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI?.delegate = self
        let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
        authUI?.providers = providers

        
        if Auth.auth().currentUser == nil {
            let authViewController = authUI!.authViewController()
            window?.rootViewController = authViewController
        }

        return true
    }
    
    // MAPS
    func handleEvent(forRegion region: CLRegion!) {
        // Show an alert if application is active
        if UIApplication.shared.applicationState == .active {
//            guard let message = note(fromRegionIdentifier: region.identifier) else { return }
//            window?.rootViewController?.showAlert(withTitle: nil, message: message)
            
        } else {
            // Otherwise present a local notification
            let notification = UILocalNotification()
//            notification.alertBody = note(fromRegionIdentifier: region.identifier)
            notification.soundName = "Default"
            UIApplication.shared.presentLocalNotificationNow(notification)
        }
    }
    
//    func note(fromRegionIdentifier identifier: String) -> String? {
//        let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedItems) as? [NSData]
//        let geoNotifications = savedItems?.map { NSKeyedUnarchiver.unarchiveObject(with: $0 as Data) as? GeoNotification }
//        let index = geoNotifications?.index { $0?.identifier == identifier }
//        return index != nil ? geoNotifications?[index!]?.note : nil
//    }
//    
    // FIREBASE
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else if let user = user {
            AppUser.current = AppUser(user: user)
            print("Welcome \(user.displayName!)! 😊")
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "MapViewController")
            window?.rootViewController = controller
        }
    }
    
//    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
//        return CustomAuthPickerViewController(authUI: authUI)
//    }
//
//    func emailEntryViewController(for authUI: FUIAuth) -> FUIEmailEntryViewController {
//        return CustomEmailEntryViewController(authUI: authUI)
//    }
//    
//    func passwordSignInViewController(for authUI: FUIAuth, email: String) -> FUIPasswordSignInViewController {
//        return CustomPasswordSignInViewController(authUI: authUI, email: email)
//    }
//    
//    func passwordSignUpViewController(for authUI: FUIAuth, email: String) -> FUIPasswordSignUpViewController {
//        return CustomPasswordSignUpViewController(authUI: authUI, email: email)
//    }
//    
//    func passwordRecoveryViewController(for authUI: FUIAuth, email: String) -> FUIPasswordRecoveryViewController {
//        return CustomPasswordRecoveryViewController(authUI: authUI, email: email)
//    }
//    
//    func passwordVerificationViewController(for authUI: FUIAuth, email: String, newCredential: AuthCredential) -> FUIPasswordVerificationViewController {
//        return CustomPasswordVerificationViewController(authUI: authUI, email: email, newCredential: newCredential)
//    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
//    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
//        if (url.host == "oauth-callback") {
//            OAuthSwift.handle(url: url)
//        }
//        return true
//    }

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
        FirebaseAuthManager.shared.signOut()
        print("Goodbye!")
    }

}

// MAPS: Extensions
extension AppDelegate: CLLocationManagerDelegate {
    
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
}


