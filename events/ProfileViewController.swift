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
import XLPagerTabStrip

class ProfileViewController: ButtonBarPagerTabStripViewController {
    
    let purpleInspireColor = UIColor(red:0.13, green:0.03, blue:0.25, alpha:1.0)
    
    
    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = UIColor(hexString: "#4CB6BE")
        settings.style.buttonBarItemBackgroundColor = UIColor(hexString: "#4CB6BE")
        settings.style.selectedBarBackgroundColor = UIColor(hexString: "#4CB6BE")
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 14)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .white
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = self?.purpleInspireColor
        }
        super.viewDidLoad()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let bundle_wallet = Bundle(path: "/Users/xiuchen/Desktop/events/events/WalletViewController.swift")
        let bundle_settings = Bundle(path: "/Users/xiuchen/Desktop/events/events/SettingsViewController.swift")
        let wallet = WalletViewController(nibName: "WalletViewController", bundle: bundle_wallet)
        let settings = SettingsViewController(nibName: "SettingsViewController", bundle: bundle_settings)
        return [wallet, settings]
    }
    
}






// ******************************************************************************************
//class ProfileViewController: UIViewController, SJFluidSegmentedControlDataSource {
//
//
//    @IBOutlet weak var segmentedController: SJFluidSegmentedControl!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Set Profile Picture
//        
////        nameLabel.text = AppUser.current.name
//        
//        segmentedController.dataSource = self
//        segmentedController.backgroundColor = UIColor(hexString: "#4CB6BE")
//        segmentedController.selectorViewColor = UIColor(hexString: "#FEB2A4")
//        //segmentedController.textFont = .custom(ofSize: 16, weight: UIFontWeightSemibold)
//
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
////        segmentedControl(segmentedController, didScrollWithXOffset: 0)
//        
//        // Set the current segment upon loading programatically
//         segmentedController.currentSegment = 1
//    }
//    
//    
//    // Setting the number segments in segmentedController
//    func numberOfSegmentsInSegmentedControl(_ segmentedControl: SJFluidSegmentedControl) -> Int {
//        return 3
//    }
//    
//    // Setting text of each segmentedController
//    func segmentedControl(_ segmentedControl: SJFluidSegmentedControl,
//                          titleForSegmentAtIndex index: Int) -> String? {
//        if index == 0 {
//            return "Events"
//        } else if index == 1 {
//            return "Wallet"
//        }
//        return "Uploads"
//    }
//    
//    
//    
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//}
