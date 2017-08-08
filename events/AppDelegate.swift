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
import OAuthSwift
import UserNotifications
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        GMSServices.provideAPIKey("AIzaSyArsx5jQEJafCsAgFFw_4OiuCtrqmYA08Q")
        GMSPlacesClient.provideAPIKey("AIzaSyArsx5jQEJafCsAgFFw_4OiuCtrqmYA08Q")
       
        
        
        if Auth.auth().currentUser != nil && FBSDKAccessToken.current() != nil {
            AppUser.current = AppUser(user: Auth.auth().currentUser!, completion: nil)
        } else {
            let loginController = SignInViewController(nibName: "SignInViewController", bundle: nil)
            loginController.signInDelegate = self
            window?.rootViewController = loginController
        }
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            // Enable or disable features based on authorization.
        }
        application.registerForRemoteNotifications()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().toolbarTintColor = Colors.green
        
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.logout), name: BashNotifications.logout, object: nil)

        //OAuthSwiftManager.shared.logout()
        //OAuthSwiftManager.shared.refreshConnection()
        
        return true
    }
    
    func logout() {
        let loginController = SignInViewController(nibName: "SignInViewController", bundle: nil)
        loginController.signInDelegate = self
        window?.rootViewController = loginController
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // Spotify OAuth Management
        //SplitwiseAPIManger.shared.handle(url: url)
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
        UIApplication.shared.applicationIconBadgeNumber = 0
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
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
            print("error with facebook authentication: \(error.localizedDescription)")
            return
        }
        if result.isCancelled {
            return
        }

        let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
//        Auth.auth().signIn(withCustomToken: <#T##String#>, completion: <#T##AuthResultCallback?##AuthResultCallback?##(User?, Error?) -> Void#>)
        Auth.auth().signIn(with: credential) { (user: User?, error: Error?) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            let signInVC = self.window?.rootViewController as? SignInViewController
            signInVC?.startSpinner()
            AppUser.current = AppUser(user: user!) {
                signInVC?.stopSpinner()
                print("Welcome \(user!.displayName!)! 😊")
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                self.window?.rootViewController = storyboard.instantiateInitialViewController()!
            }
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        let loginController = SignInViewController(nibName: "SignInViewController", bundle: nil)
        loginController.signInDelegate = self
        self.window?.rootViewController = loginController
    }
}
