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
import BetterSegmentedControl

class SettingsViewController: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var addPaymentButton: UIButton!
    @IBOutlet weak var themeSwitch: BetterSegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the current user's name
        nameLabel.text = AppUser.current.name
        
        // Set the current user's photo
        let photoURLString = AppUser.current.photoURLString
        let photoURL = URL(string: photoURLString)
        userImage.layer.cornerRadius = userImage.frame.width/2
        userImage.layer.masksToBounds = true
        userImage.af_setImage(withURL: photoURL!)
        
        // Switch to toggle between "day" and "night" theme
        themeSwitch.titles = ["Day", "Night"]
        themeSwitch.backgroundColor = Colors.coral
        themeSwitch.indicatorViewBackgroundColor = Colors.green
        themeSwitch.titleFont = UIFont(name: "Futura", size: 20.0)!
        themeSwitch.selectedTitleFont = UIFont(name: "Futura", size: 20.0)!
        themeSwitch.selectedTitleColor = UIColor.white
        var index: UInt = 0
        if Utilities.theme == "night" {
            index = 1
        }
        do {
            try themeSwitch.setIndex(index, animated: true)
        } catch {
            NSLog("Unable to switch index")
        }
        
        
        
        // Customize payment method button
        addPaymentButton.layer.cornerRadius = 5
        addPaymentButton.backgroundColor = UIColor(hexString: "#FEB2A4")
        
        // Customize logout button
        logoutButton.layer.cornerRadius = 5
        logoutButton.backgroundColor = UIColor(hexString: "#FEB2A4")
    }
    
    
    @IBAction func onAddPayment(_ sender: Any) {
        let addPaymentVC = AddPaymentViewController(nibName: "AddPaymentViewController", bundle: nil)
        self.present(addPaymentVC, animated: true, completion: nil)
    }
    
    
    @IBAction func themeSwitchValueChanged(_ sender: BetterSegmentedControl) {
        if sender.index == 0 {
            Utilities.theme = "day"
            NotificationCenter.default.post(name: BashNotifications.changedTheme, object: nil)
        } else {
            Utilities.theme = "night"
            NotificationCenter.default.post(name: BashNotifications.changedTheme, object: nil)
        }
        UserDefaults.standard.set(Utilities.theme, forKey: "theme")
        UserDefaults.standard.synchronize()
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
        NotificationCenter.default.post(name: BashNotifications.logout, object: nil)
    }
    
    @IBAction func play(_ sender: Any) {
        OAuthSwiftManager.shared.startMusic(creatorUserID: nil, playlistID: nil)
        
    }
    
    
    @IBAction func pause(_ sender: Any) {
        
        OAuthSwiftManager.shared.pauseMusic()
    }
    
}
