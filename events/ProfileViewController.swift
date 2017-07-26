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
    
    @IBOutlet weak var barButtonView: ButtonBarView!
    
    override func viewDidLoad() {
        // change selected bar color
        settings.style.buttonBarBackgroundColor = UIColor(hexString: "#4CB6BE")
        settings.style.buttonBarItemBackgroundColor = UIColor(hexString: "#FEB2A4")
        settings.style.selectedBarBackgroundColor = UIColor(hexString: "#4CB6BE")
        settings.style.buttonBarItemFont = UIFont(name: "Futura", size: 20)!
        settings.style.selectedBarHeight = 4.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = UIColor(hexString: "#F5F5F5")
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor(hexString: "#484848")
            newCell?.label.textColor = UIColor(hexString: "#F5F5F5")
        }
        super.viewDidLoad()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let bundle_wallet = Bundle(path: "/Users/xiuchen/Desktop/events/events/WalletViewController.swift")
        let bundle_settings = Bundle(path: "/Users/xiuchen/Desktop/events/events/SettingsViewController.swift")
        let bundle_uploads = Bundle(path: "/Users/xiuchen/Desktop/events/events/MyUploadsViewController.swift")
        let wallet = WalletViewController(nibName: "WalletViewController", bundle: bundle_wallet)
        let settings = SettingsViewController(nibName: "SettingsViewController", bundle: bundle_settings)
        let uploads = MyUploadsViewController(nibName: "MyUploadsViewController", bundle: bundle_uploads)
        return [wallet, uploads, settings]
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
