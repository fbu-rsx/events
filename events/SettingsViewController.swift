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
        let loginController = SignInViewController(nibName: "SignInViewController", bundle: nil)
        loginController.signInDelegate = UIApplication.shared.delegate! as! AppDelegate
        self.present(loginController, animated: true, completion: nil)
    }

}
