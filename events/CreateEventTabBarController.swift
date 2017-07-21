//
//  CreateEventTabBarController.swift
//  events
//
//  Created by Skyler Ruesga on 7/19/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit
import SimpleTab

class CreateEventTabBarController: UITabBarController  {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tabBar.isHidden = true
//        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

//extension CreateEventTabBarController: UITabBarControllerDelegate {
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        
//        let fromView: UIView = self.selectedViewController!.view
//        let toView  : UIView = viewController.view
//        if fromView == toView {
//            return false
//        }
//        
//        UIView.transition(from: fromView, to: toView, duration: 1.0, options: UIViewAnimationOptions.transitionCrossDissolve) { (finished:Bool) in
//            
//        }
//        return true
//    }
//}

extension UIViewController {
    
    func presentDetail(_ viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        present(viewControllerToPresent, animated: false)
    }
    
    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        self.view.window!.layer.add(transition, forKey: kCATransition)
        
        dismiss(animated: false)
    }
}

