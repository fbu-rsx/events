//
//  SignInViewController.swift
//  events
//
//  Created by Skyler Ruesga on 7/24/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import FBSDKLoginKit

protocol SignInDelegate: FBSDKLoginButtonDelegate {
}

class SignInViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    
    var signInDelegate: SignInDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activitySpinner.isHidden = true
        fbLoginButton.delegate = signInDelegate
        fbLoginButton.readPermissions = ["public_profile", "user_friends"]
        fbLoginButton.loginBehavior = .browser
        
        self.titleLabel.textColor = Colors.coral
    }
    
    // Bounce up-and-down animation for photo
    func mapAnimation () {
        UIView.animate(withDuration: 1, delay: 0.25, options: [.autoreverse, .repeat], animations: {
            self.logoImage.frame.origin.y -= 10
        })
        self.logoImage.frame.origin.y += 10
    }
    
    func startSpinner() {
        activitySpinner.startAnimating()
        activitySpinner.isHidden = false
    }
    
    func stopSpinner() {
        activitySpinner.stopAnimating()
        activitySpinner.isHidden = true
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        mapAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.logoImage.layer.removeAllAnimations()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
