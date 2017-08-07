//
//  DetailContainerViewController.swift
//  events
//
//  Created by Skyler Ruesga on 8/7/17.
//  Copyright © 2017 fbu-rsx. All rights reserved.
//

import UIKit

class DetailContainerViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    weak var event: Event?
    var imageDelegate: imagePickerDelegate2?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tabBarController?.tabBar.isHidden = false
        self.pageControl.currentPageIndicatorTintColor = UIColor(hexString: "4CB6BE")
        self.pageControl.pageIndicatorTintColor = UIColor(hexString: "F2F2F2")
        self.navigationController?.navigationBar.addSubview(pageControl)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.pageControl.removeFromSuperview()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let viewController = segue.destination as? DetailPageViewController {
            viewController.pageControlDelegate = self
            viewController.event = self.event
            viewController.imageDelegate = self.imageDelegate
        }
    }
}

extension DetailContainerViewController: DetailPageViewControllerDelegate {
    
    func eventPageController(_ eventPageController: DetailPageViewController,
                             didUpdatePageCount count: Int) {
        pageControl.numberOfPages = count
    }
    
    func eventPageController(_ eventPageController: DetailPageViewController,
                             didUpdatePageIndex index: Int) {
        pageControl.currentPage = index
    }
    
}
