//
//  EventContainerViewController.swift
//  events
//
//  Created by Skyler Ruesga on 7/21/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class EventContainerViewController: UIViewController {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tabBarController?.tabBar.isHidden = false
        self.pageControl.currentPageIndicatorTintColor = UIColor(hexString: "4CB6BE")
        self.pageControl.pageIndicatorTintColor = UIColor(hexString: "F2F2F2")
        self.pageControl.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let eventPageViewController = segue.destination as? CreateEventPageController {
            eventPageViewController.pageControlDelegate = self
        }
    }
}

extension EventContainerViewController: CreateEventPageControllerDelegate {
    
    func eventPageController(_ eventPageController: CreateEventPageController,
                             didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func eventPageController(_ eventPageController: CreateEventPageController,
                             didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
}
