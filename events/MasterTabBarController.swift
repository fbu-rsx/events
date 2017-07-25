//
//  MasterTabBarController.swift
//  events
//
//  Created by Skyler Ruesga on 7/24/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import SimpleTab

class MasterTabBarController: SimpleTabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupSimpleTab()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupSimpleTab() {
        // Sets rootViewController as a SimpleTabBarController
        
        //# Set the View Transition to Crossfade
        self.viewTransition = CrossFadeViewTransition()
        
        //# Set Tab Bar Style to Elegant tabbar style
        //let style: SimpleTabBarStyle = PopTabBarStyle(tabBar: simpleTBC!.tabBar)
        let style: SimpleTabBarStyle = ElegantTabBarStyle(tabBar: self.tabBar)
        
        //# Set Tab Title attributes for selected and unselected (normal) states.
        style.setTitleTextAttributes(attributes: [NSFontAttributeName as NSObject : UIFont.systemFont(ofSize: 14),  NSForegroundColorAttributeName as NSObject: UIColor.lightGray], forState: .normal)
        style.setTitleTextAttributes(attributes: [NSFontAttributeName as NSObject : UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName as NSObject: UIColor(hexString: "4CB6BE")], forState: .selected)
        
        //Set Tab Icon colors for selected and unselected (normal) states.
        style.setIconColor(color: UIColor.lightGray, forState: UIControlState.normal)
        style.setIconColor(color: UIColor(hexString: "4CB6BE"), forState: UIControlState.selected)
        
        // Set Tab Icons
        self.tabBar.items?[0].image = UIImage(named: "fireworks")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[1].image = UIImage(named: "map")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[2].image = UIImage(named: "monthly-calendar")?.withRenderingMode(.alwaysOriginal)
        self.tabBar.items?[3].image = UIImage(named: "user1")?.withRenderingMode(.alwaysOriginal)
        
        // Let the tab bar control know of the style
        self.tabBarStyle = style
    }
    

}
