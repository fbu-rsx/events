//
//  ProfileViewController.swift
//  events
//
//  Created by Xiu Chen on 7/25/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import SJFluidSegmentedControl
import AlamofireImage

class ProfileViewController: UIViewController, SJFluidSegmentedControlDataSource {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var segmentedController: SJFluidSegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Profile Picture
        
//        nameLabel.text = AppUser.current.name
        
        segmentedController.dataSource = self
        segmentedController.backgroundColor = UIColor(hexString: "#4CB6BE")
        segmentedController.selectorViewColor = UIColor(hexString: "#FEB2A4")
//        segmentedController.textFont = .custom(ofSize: 16, weight: UIFontWeightSemibold)

        // Do any additional setup after loading the view.
    }
    
    // Setting the number segments in segmentedController
    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
        return 3
    }
    
    // Setting text of each segmentedController
    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
                          titleForSegmentAtIndex index: Int) -> String? {
        if index == 0 {
            return "Events"
        } else if index == 1 {
            return "Wallet"
        }
        return "Uploads"
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
