//
//  AddPaymentViewController.swift
//  events
//
//  Created by Xiu Chen on 8/1/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class AddPaymentViewController: UIViewController {
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var walletImage: UIImageView!
    @IBOutlet weak var cardNumberText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.backgroundColor = UIColor(hexString: "#FEB2A4")
        saveButton.layer.cornerRadius = 5
        dismissButton.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        walletAnimation()
    }
    
    func walletAnimation() {
        UIView.animate(withDuration: 1, delay: 0.25, options: [.autoreverse, .repeat], animations: {
            self.walletImage.frame.origin.y -= 10
        })
        self.walletImage.frame.origin.y += 10
    }
    
    @IBAction func onSave(_ sender: Any) {
        let value = Double(cardNumberText.text!)
        FirebaseDatabaseManager.shared.updateWallet(id: AppUser.current.uid, withValue: AppUser.current.wallet + value!, completion: {})
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
