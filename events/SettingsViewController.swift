//
//  SettingsViewController.swift
//  events
//
//  Created by Xiu Chen on 7/26/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import XLPagerTabStrip

class SettingsViewController: UIViewController, IndicatorInfoProvider {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the current user's name
        nameLabel.text = AppUser.current.name
        
        // Set the current user's photo
        let photoURLString = AppUser.current.photoURLString
        let photoURL = URL(string: photoURLString)
        userImage.af_setImage(withURL: photoURL!)
        
        // Customize logout button
        logoutButton.layer.cornerRadius = 5
        logoutButton.backgroundColor = UIColor(hexString: "#FEB2A4")
    }

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Settings")
    }

    @IBAction func didLogout(_ sender: Any) {
        FirebaseDatabaseManager.shared.logout()
        FBSDKLoginManager().logOut()
//        let creds = URLCredentialStorage.shared.allCredentials
//        for (protectionSpace, userCredsDict) in creds {
//            for (_, cred) in userCredsDict {
//                print("DELETING CREDENTIAL")
//                URLCredentialStorage.shared.remove(cred, for: protectionSpace, options: ["NSURLCredentialStorageRemoveSynchronizableCredentials" : true])
//            }
//        }
//        URLCache.shared.removeAllCachedResponses()
//        if let cookies = HTTPCookieStorage.shared.cookies {
//            for cookie in cookies {
//                HTTPCookieStorage.shared.deleteCookie(cookie)
//            }
//        }
//        UserDefaults.standard.synchronize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "logout"), object: nil)
    }

}
